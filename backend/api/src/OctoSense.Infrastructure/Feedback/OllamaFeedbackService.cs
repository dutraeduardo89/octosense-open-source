using System.Net.Http.Json;
using System.Text.Json.Serialization;
using OctoSense.Application.Features.Feedback;
using OctoSense.Domain.Readings;
using OctoSense.Domain.Results;

namespace OctoSense.Infrastructure.Feedback;

public sealed class OllamaFeedbackService(
    HttpClient httpClient,
    IHealthReadingRepository repository) : IFeedbackService
{
    private static readonly TimeSpan AggregationOffset = TimeSpan.FromHours(-3);

    public async Task<Result<FeedbackResponse>> GenerateAsync(
        string userId,
        string period,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Result<FeedbackResponse>.Failure(
                Error.Validation(nameof(userId), "UserId is required."));
        }

        if (!string.Equals(period, "7d", StringComparison.OrdinalIgnoreCase))
        {
            return Result<FeedbackResponse>.Failure(
                Error.Validation(nameof(period), "Only the 7d period is supported."));
        }

        var today = DateOnly.FromDateTime(DateTimeOffset.UtcNow.ToOffset(AggregationOffset).DateTime);
        var from = new DateTimeOffset(today.AddDays(-6).ToDateTime(TimeOnly.MinValue), AggregationOffset);
        var to = new DateTimeOffset(today.AddDays(1).ToDateTime(TimeOnly.MinValue), AggregationOffset);

        var readings = await repository.ListByUserAndPeriodAsync(userId, from, to, cancellationToken);
        var heartRates = readings.Where(x => x.Metrics.HeartRateBpm is not null).Select(x => x.Metrics.HeartRateBpm!.Value).ToList();
        var oxygen = readings.Where(x => x.Metrics.OxygenSaturationPercent is not null).Select(x => x.Metrics.OxygenSaturationPercent!.Value).ToList();
        var steps = readings.Sum(x => x.Metrics.Steps ?? 0);
        var calories = readings.Sum(x => x.Metrics.TotalCaloriesKcal ?? 0);
        var activeCalories = readings.Sum(x => x.Metrics.ActiveCaloriesKcal ?? 0);
        var sleepMinutes = readings.Where(x => x.Metrics.SleepDuration is not null).Sum(x => x.Metrics.SleepDuration!.Value.TotalMinutes);

        var prompt = $"""
Você é o OctoSense, um coach de saúde. Escreva UMA frase curta em português.

Formato exato (SEM aspas em volta):
Você andou 19763 passos nesta semana. Continue assim.
Você somou 358 kcal ativas hoje. Bom trabalho.
Você manteve 8523 passos por dia. Siga firme.

Agora use os dados reais:
Passos totais da semana: {steps}
Calorias ativas totais: {activeCalories:F0} kcal

Escreva sua frase:
""";

        var request = new OllamaGenerateRequest(
            "llama3.2:3b",
            prompt,
            false,
            new OllamaOptions(0.2));

        try
        {
            using var response = await httpClient.PostAsJsonAsync("api/generate", request, cancellationToken);
            if (!response.IsSuccessStatusCode)
            {
                return Result<FeedbackResponse>.Failure(
                    Error.Failure($"Local AI service returned HTTP {(int)response.StatusCode}."));
            }

            var payload = await response.Content.ReadFromJsonAsync<OllamaGenerateResponse>(cancellationToken: cancellationToken);
            var insight = payload?.Response?.Trim();
            if (string.IsNullOrWhiteSpace(insight))
            {
                return Result<FeedbackResponse>.Failure(
                    Error.Failure("Local AI service returned an empty insight."));
            }

            return Result<FeedbackResponse>.Success(
                new FeedbackResponse(insight, "7d", DateTimeOffset.UtcNow));
        }
        catch (HttpRequestException)
        {
            return Result<FeedbackResponse>.Failure(
                Error.Failure("Local AI service is unavailable."));
        }
        catch (TaskCanceledException) when (!cancellationToken.IsCancellationRequested)
        {
            return Result<FeedbackResponse>.Failure(
                Error.Failure("Local AI service timed out."));
        }
    }

    private sealed record OllamaGenerateRequest(
        string Model,
        string Prompt,
        bool Stream,
        OllamaOptions Options);

    private sealed record OllamaOptions(double Temperature);

    private sealed record OllamaGenerateResponse(
        [property: JsonPropertyName("response")] string? Response);
}
