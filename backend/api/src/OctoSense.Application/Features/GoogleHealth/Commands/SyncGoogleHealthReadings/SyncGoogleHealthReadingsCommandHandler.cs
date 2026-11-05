using DotRMediator;
using Microsoft.Extensions.Logging;
using OctoSense.Domain.GoogleHealth;
using OctoSense.Domain.Readings;
using OctoSense.Domain.Results;

namespace OctoSense.Application.Features.GoogleHealth.Commands.SyncGoogleHealthReadings;

/// <summary>
/// Imports Google Health DataPoints as sparse <see cref="HealthReading"/> instances.
/// </summary>
/// <param name="googleHealthClient">Google Health API port.</param>
/// <param name="linkRepository">Linked account store.</param>
/// <param name="cursorRepository">Per-dataType sync cursors.</param>
/// <param name="readingRepository">Health reading persistence.</param>
/// <param name="logger">Logs per-dataType sync failures without tokens.</param>
/// <remarks>
/// Refreshes the access token on demand for this user only. Does not reconstruct domain invariants.
/// </remarks>
public sealed class SyncGoogleHealthReadingsCommandHandler(
    IGoogleHealthClient googleHealthClient,
    IGoogleHealthLinkRepository linkRepository,
    IGoogleHealthSyncCursorRepository cursorRepository,
    IHealthReadingRepository readingRepository,
    ILogger<SyncGoogleHealthReadingsCommandHandler> logger)
    : IRequestHandler<SyncGoogleHealthReadingsCommand, Result<SyncGoogleHealthReadingsResult>>
{
    /// <summary>
    /// Google data types imported by this handler.
    /// </summary>
    public static readonly string[] DataTypes =
    [
        "heart-rate",
        "steps",
        "sleep",
        "oxygen-saturation",
        "active-energy-burned",
        "total-calories"
    ];

    private static readonly TimeSpan DefaultLookback = TimeSpan.FromDays(7);

    /// <summary>
    /// Overlap window for incremental sync. Google consolidates data with a delay
    /// of up to ~24h, so the cursor is only used as a lower bound when it is
    /// more recent than this window. The externalId dedup avoids duplicates.
    /// </summary>
    private static readonly TimeSpan OverlapWindow = TimeSpan.FromDays(2);

    private readonly IGoogleHealthClient _googleHealthClient = googleHealthClient;
    private readonly IGoogleHealthLinkRepository _linkRepository = linkRepository;
    private readonly IGoogleHealthSyncCursorRepository _cursorRepository = cursorRepository;
    private readonly IHealthReadingRepository _readingRepository = readingRepository;
    private readonly ILogger<SyncGoogleHealthReadingsCommandHandler> _logger = logger;

    public async Task<Result<SyncGoogleHealthReadingsResult>> Handle(
        SyncGoogleHealthReadingsCommand request,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.UserId))
        {
            return Result<SyncGoogleHealthReadingsResult>.Failure(
                Error.Validation(nameof(request.UserId), "UserId is required."));
        }

        var link = await _linkRepository.GetByUserIdAsync(request.UserId, cancellationToken);
        if (link is null)
        {
            return Result<SyncGoogleHealthReadingsResult>.Failure(
                Error.Validation(nameof(request.UserId), "Google Health link not found."));
        }

        string accessToken;
        try
        {
            accessToken = await EnsureAccessTokenAsync(link, cancellationToken);
        }
        catch (Exception exception)
        {
            return Result<SyncGoogleHealthReadingsResult>.Failure(
                Error.Validation(
                    "GoogleHealth",
                    $"Failed to refresh Google Health access token: {exception.Message}"));
        }

        var imported = 0;
        var skipped = 0;

        foreach (var dataType in DataTypes)
        {
            var cursor = await _cursorRepository.GetAsync(request.UserId, dataType, cancellationToken);

            // Overlap de 2 dias: garante que dados consolidados com atraso
            // nao se percam mesmo se o cursor ja avancou. O dedup por
            // externalId evita duplicar o que ja esta persistido.
            var minLookback = DateTimeOffset.UtcNow.Subtract(OverlapWindow);
            var cursorSince = cursor?.LastSyncedAt
                ?? DateTimeOffset.UtcNow.Subtract(DefaultLookback);
            var since = cursorSince < minLookback ? cursorSince : minLookback;
            var windowEnd = DateTimeOffset.UtcNow;

            IReadOnlyList<GoogleHealthDataPoint> points;
            try
            {
                points = await _googleHealthClient.ListDataPointsAsync(
                    accessToken,
                    dataType,
                    since,
                    cancellationToken);
            }
            catch (Exception exception)
            {
                _logger.LogWarning(
                    exception,
                    "Failed to list Google Health {DataType} for user {UserId}.",
                    dataType,
                    request.UserId);
                continue;
            }

            var typeImported = 0;
            var typeRejected = 0;
            var typeDuplicated = 0;

            foreach (var point in points)
            {
                var readingResult = HealthReading.Create(
                    request.UserId,
                    point.DeviceId,
                    point.DeviceSource,
                    point.RecordedAt,
                    point.HeartRateBpm,
                    point.Steps,
                    point.SleepDuration,
                    point.OxygenSaturationPercent,
                    point.TotalCaloriesKcal,
                    syncMode: "GoogleHealthSync",
                    batteryLevel: null,
                    externalId: point.Name);

                if (readingResult.IsFailure)
                {
                    if (typeRejected < 3)
                    {
                        _logger.LogWarning(
                            "Google Health {DataType} REJECTED: {Errors}",
                            dataType,
                            string.Join("; ", readingResult.Errors.Select(e => e.Message)));
                    }
                    typeRejected++;
                    skipped++;
                    continue;
                }

                var inserted = await _readingRepository.SaveIfNewExternalIdAsync(
                    readingResult.Value!,
                    cancellationToken);
                if (inserted)
                {
                    typeImported++;
                    imported++;
                }
                else
                {
                    if (typeDuplicated < 3)
                    {
                        _logger.LogWarning(
                            "Google Health {DataType} DUPLICATE externalId={ExternalId}",
                            dataType,
                            point.Name);
                    }
                    typeDuplicated++;
                    skipped++;
                }
            }

            _logger.LogWarning(
                "Google Health {DataType} SUMMARY: fetched={Fetched}, imported={Imported}, rejected={Rejected}, duplicated={Duplicated}",
                dataType,
                points.Count,
                typeImported,
                typeRejected,
                typeDuplicated);

            await _cursorRepository.UpsertAsync(
                new GoogleHealthSyncCursor(request.UserId, dataType, windowEnd),
                cancellationToken);
        }

        return Result<SyncGoogleHealthReadingsResult>.Success(
            new SyncGoogleHealthReadingsResult(imported, skipped));
    }

    private async Task<string> EnsureAccessTokenAsync(
        GoogleHealthLink link,
        CancellationToken cancellationToken)
    {
        if (!string.IsNullOrWhiteSpace(link.AccessToken)
            && link.AccessTokenExpiresAt is { } expiresAt
            && expiresAt > DateTimeOffset.UtcNow.AddMinutes(1))
        {
            return link.AccessToken;
        }

        var tokens = await _googleHealthClient.RefreshAccessTokenAsync(
            link.RefreshToken,
            cancellationToken);

        var refreshed = link with
        {
            AccessToken = tokens.AccessToken,
            AccessTokenExpiresAt = DateTimeOffset.UtcNow.AddSeconds(tokens.ExpiresIn),
            RefreshToken = string.IsNullOrWhiteSpace(tokens.RefreshToken)
                ? link.RefreshToken
                : tokens.RefreshToken
        };

        await _linkRepository.UpsertAsync(refreshed, cancellationToken);
        return tokens.AccessToken;
    }
}