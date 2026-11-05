using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using OctoSense.Domain.GoogleHealth;

namespace OctoSense.Infrastructure.GoogleHealth;

/// <summary>
/// HttpClient adapter for Google OAuth and Health DataPoints API.
/// </summary>
/// <param name="httpClient">Named or typed HTTP client.</param>
/// <param name="options">Google Health configuration.</param>
/// <param name="logger">Logs Google Health HTTP failures without tokens.</param>
/// <remarks>
/// Does not log tokens or clinical payloads.
/// </remarks>
public sealed class GoogleHealthClient(
    HttpClient httpClient,
    IOptions<GoogleHealthOptions> options,
    ILogger<GoogleHealthClient> logger) : IGoogleHealthClient
{
    private static readonly string[] Scopes =
    [
        "openid",
        "email",
        "https://www.googleapis.com/auth/googlehealth.activity_and_fitness.readonly",
        "https://www.googleapis.com/auth/googlehealth.health_metrics_and_measurements.readonly",
        "https://www.googleapis.com/auth/googlehealth.sleep.readonly"
    ];

    private readonly HttpClient _httpClient = httpClient;
    private readonly GoogleHealthOptions _options = options.Value;
    private readonly ILogger<GoogleHealthClient> _logger = logger;

    /// <inheritdoc />
    public string BuildAuthorizationUrl()
    {
        var scope = Uri.EscapeDataString(string.Join(' ', Scopes));
        return "https://accounts.google.com/o/oauth2/v2/auth"
            + $"?client_id={Uri.EscapeDataString(_options.ClientId)}"
            + $"&redirect_uri={Uri.EscapeDataString(_options.RedirectUri)}"
            + "&response_type=code"
            + "&access_type=offline"
            + "&prompt=consent"
            + $"&scope={scope}"
            + "&state=octosense-mobile";
    }

    /// <inheritdoc />
    public async Task<GoogleUserProfile> GetUserProfileAsync(
        string accessToken,
        CancellationToken cancellationToken = default)
    {
        using var request = new HttpRequestMessage(
            HttpMethod.Get,
            "https://openidconnect.googleapis.com/v1/userinfo");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);

        using var response = await _httpClient.SendAsync(request, cancellationToken);
        response.EnsureSuccessStatusCode();

        var payload = await response.Content.ReadFromJsonAsync<GoogleUserInfoResponse>(
            cancellationToken: cancellationToken)
            ?? throw new InvalidOperationException("Google userinfo response was empty.");

        if (string.IsNullOrWhiteSpace(payload.Email))
        {
            throw new InvalidOperationException("Google userinfo did not include an email.");
        }

        return new GoogleUserProfile(payload.Email.Trim().ToLowerInvariant());
    }

    /// <inheritdoc />
    public async Task<GoogleOAuthTokens> ExchangeCodeAsync(
        string code,
        CancellationToken cancellationToken = default)
    {
        using var content = new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["code"] = code,
            ["client_id"] = _options.ClientId,
            ["client_secret"] = _options.ClientSecret,
            ["redirect_uri"] = _options.RedirectUri,
            ["grant_type"] = "authorization_code"
        });

        using var response = await _httpClient.PostAsync(
            "https://oauth2.googleapis.com/token",
            content,
            cancellationToken);
        response.EnsureSuccessStatusCode();

        var payload = await response.Content.ReadFromJsonAsync<GoogleTokenResponse>(
            cancellationToken: cancellationToken)
            ?? throw new InvalidOperationException("Google token response was empty.");

        return new GoogleOAuthTokens(payload.AccessToken, payload.RefreshToken, payload.ExpiresIn);
    }

    /// <inheritdoc />
    public async Task<GoogleOAuthTokens> RefreshAccessTokenAsync(
        string refreshToken,
        CancellationToken cancellationToken = default)
    {
        using var content = new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["refresh_token"] = refreshToken,
            ["client_id"] = _options.ClientId,
            ["client_secret"] = _options.ClientSecret,
            ["grant_type"] = "refresh_token"
        });

        using var response = await _httpClient.PostAsync(
            "https://oauth2.googleapis.com/token",
            content,
            cancellationToken);
        response.EnsureSuccessStatusCode();

        var payload = await response.Content.ReadFromJsonAsync<GoogleTokenResponse>(
            cancellationToken: cancellationToken)
            ?? throw new InvalidOperationException("Google token refresh response was empty.");

        return new GoogleOAuthTokens(
            payload.AccessToken,
            payload.RefreshToken ?? refreshToken,
            payload.ExpiresIn);
    }

    /// <inheritdoc />
    public async Task<IReadOnlyList<GoogleHealthDataPoint>> ListDataPointsAsync(
        string accessToken,
        string dataType,
        DateTimeOffset since,
        CancellationToken cancellationToken = default)
    {
        if (dataType == "total-calories")
        {
            return await ListDailyCaloriesAsync(accessToken, since, cancellationToken);
        }

        var results = new List<GoogleHealthDataPoint>();
        string? pageToken = null;
        var rawCount = 0;

        do
        {
            var filter = BuildFilter(dataType, since);
            var url =
                $"https://health.googleapis.com/v4/users/me/dataTypes/{Uri.EscapeDataString(dataType)}/dataPoints"
                + $"?filter={Uri.EscapeDataString(filter)}"
                + (pageToken is null ? string.Empty : $"&pageToken={Uri.EscapeDataString(pageToken)}");

            using var request = new HttpRequestMessage(HttpMethod.Get, url);
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);

            using var response = await _httpClient.SendAsync(request, cancellationToken);
            if (!response.IsSuccessStatusCode)
            {
                var error = await response.Content.ReadAsStringAsync(cancellationToken);
                _logger.LogWarning(
                    "Google Health list {DataType} failed with {StatusCode}: {Error}",
                    dataType,
                    (int)response.StatusCode,
                    TrimError(error));
                throw new HttpRequestException(
                    $"Google Health list {dataType} failed: {(int)response.StatusCode}. {TrimError(error)}");
            }

            await using var stream = await response.Content.ReadAsStreamAsync(cancellationToken);
            using var document = await JsonDocument.ParseAsync(stream, cancellationToken: cancellationToken);

            if (document.RootElement.TryGetProperty("dataPoints", out var points)
                && points.ValueKind == JsonValueKind.Array)
            {
                foreach (var point in points.EnumerateArray())
                {
                    rawCount++;
                    var mapped = GoogleHealthDataPointMapper.TryMapListItem(point, dataType);
                    if (mapped is not null)
                    {
                        results.Add(mapped);
                    }
                    else
                    {
                        if (rawCount <= 3)
                        {
                            _logger.LogWarning(
                                "Mapper rejected {DataType} point #{Index}. Payload: {Payload}",
                                dataType,
                                rawCount,
                                TrimError(point.GetRawText()));
                        }
                    }
                }
            }

            pageToken = document.RootElement.TryGetProperty("nextPageToken", out var token)
                && token.ValueKind == JsonValueKind.String
                    ? token.GetString()
                    : null;
        }
        while (!string.IsNullOrWhiteSpace(pageToken));

        _logger.LogInformation(
            "Google Health {DataType}: raw={RawCount}, mapped={MappedCount}",
            dataType,
            rawCount,
            results.Count);

        return results;
    }

    /// <summary>
    /// Loads daily total-calorie rollups. That data type is not listable.
    /// </summary>
    /// <param name="accessToken">Google access token.</param>
    /// <param name="since">Inclusive lower bound used to build the civil-time range.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>One point per civil day that has a <c>kcalSum</c>.</returns>
    /// <remarks>
    /// Matches the Google Health home card "Calorias gastas". Maximum range is 14 days.
    /// </remarks>
    private async Task<IReadOnlyList<GoogleHealthDataPoint>> ListDailyCaloriesAsync(
        string accessToken,
        DateTimeOffset since,
        CancellationToken cancellationToken)
    {
        var start = DateOnly.FromDateTime(since.UtcDateTime);
        var endExclusive = DateOnly.FromDateTime(DateTime.UtcNow.Date.AddDays(1));
        if (endExclusive <= start)
        {
            endExclusive = start.AddDays(1);
        }

        if (endExclusive.DayNumber - start.DayNumber > 14)
        {
            start = endExclusive.AddDays(-14);
        }

        var url = "https://health.googleapis.com/v4/users/me/dataTypes/total-calories/dataPoints:dailyRollUp";
        using var request = new HttpRequestMessage(HttpMethod.Post, url);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        request.Content = JsonContent.Create(new
        {
            range = new
            {
                start = CivilDate(start),
                end = CivilDate(endExclusive)
            },
            windowSizeDays = 1
        });

        using var response = await _httpClient.SendAsync(request, cancellationToken);
        if (!response.IsSuccessStatusCode)
        {
            var error = await response.Content.ReadAsStringAsync(cancellationToken);
            _logger.LogWarning(
                "Google Health dailyRollUp total-calories failed with {StatusCode}: {Error}",
                (int)response.StatusCode,
                TrimError(error));
            throw new HttpRequestException(
                $"Google Health dailyRollUp total-calories failed: {(int)response.StatusCode}. {TrimError(error)}");
        }

        await using var stream = await response.Content.ReadAsStreamAsync(cancellationToken);
        using var document = await JsonDocument.ParseAsync(stream, cancellationToken: cancellationToken);
        var results = new List<GoogleHealthDataPoint>();
        if (!document.RootElement.TryGetProperty("rollupDataPoints", out var points)
            || points.ValueKind != JsonValueKind.Array)
        {
            return results;
        }

        foreach (var point in points.EnumerateArray())
        {
            var mapped = GoogleHealthDataPointMapper.TryMapTotalCaloriesRollup(point);
            if (mapped is not null)
            {
                results.Add(mapped);
            }
        }

        return results;
    }

    /// <summary>
    /// Builds the AIP-160 filter for a list query.
    /// </summary>
    private static string BuildFilter(string dataType, DateTimeOffset since)
    {
        var iso = since.UtcDateTime.ToString("yyyy-MM-dd'T'HH:mm:ss'Z'");
        return dataType switch
        {
            "heart-rate" or "oxygen-saturation" =>
                $"{ToFilterPrefix(dataType)}.sample_time.physical_time >= \"{iso}\"",
            "sleep" =>
                $"sleep.interval.end_time >= \"{iso}\"",
            _ =>
                $"{ToFilterPrefix(dataType)}.interval.start_time >= \"{iso}\""
        };
    }

    private static string ToFilterPrefix(string dataType) =>
        dataType.Replace('-', '_');

    private static object CivilDate(DateOnly day) => new
    {
        date = new { year = day.Year, month = day.Month, day = day.Day },
        time = new { hours = 0, minutes = 0, seconds = 0, nanos = 0 }
    };

    private static string TrimError(string error) =>
        error.Length <= 300 ? error : error[..300];

    private sealed class GoogleTokenResponse
    {
        [JsonPropertyName("access_token")]
        public string AccessToken { get; set; } = string.Empty;

        [JsonPropertyName("refresh_token")]
        public string? RefreshToken { get; set; }

        [JsonPropertyName("expires_in")]
        public int ExpiresIn { get; set; }
    }

    private sealed class GoogleUserInfoResponse
    {
        [JsonPropertyName("email")]
        public string? Email { get; set; }
    }
}