using DotRMediator;
using OctoSense.Domain.Readings;
using OctoSense.Domain.Results;

namespace OctoSense.Application.Features.Readings.Queries.GetDailySummary;

/// <summary>
/// Aggregates readings into per-day summaries.
/// </summary>
/// <param name="repository">Reading persistence port.</param>
public sealed class GetDailySummaryQueryHandler(IHealthReadingRepository repository)
    : IRequestHandler<GetDailySummaryQuery, Result<PeriodSummaryResponse>>
{
    private readonly IHealthReadingRepository _repository = repository;

    /// <summary>
    /// Brazil offset used to bucket readings into calendar days.
    /// </summary>
    /// <remarks>
    /// Google Health aggregates by local day (UTC-3). Both the repository range
    /// and the group-by bucket must use the same offset, otherwise the query
    /// window overlaps neighboring days.
    /// TODO: derive from the user's profile once auth includes a timezone.
    /// </remarks>
    private static readonly TimeSpan AggregationOffset = TimeSpan.FromHours(-3);

    public async Task<Result<PeriodSummaryResponse>> Handle(
        GetDailySummaryQuery request,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.UserId))
        {
            return Result<PeriodSummaryResponse>.Failure(
                Error.Validation(nameof(request.UserId), "UserId is required."));
        }

        if (request.To < request.From)
        {
            return Result<PeriodSummaryResponse>.Failure(
                Error.Validation(nameof(request.To), "'To' must be greater than or equal to 'From'."));
        }

        var fromInclusive = new DateTimeOffset(
            request.From.ToDateTime(TimeOnly.MinValue),
            AggregationOffset);
        var toExclusive = new DateTimeOffset(
            request.To.AddDays(1).ToDateTime(TimeOnly.MinValue),
            AggregationOffset);

        var readings = await _repository.ListByUserAndPeriodAsync(
            request.UserId,
            fromInclusive,
            toExclusive,
            cancellationToken);

        var summaries = Aggregate(readings);

        return Result<PeriodSummaryResponse>.Success(
            new PeriodSummaryResponse(request.UserId, request.From, request.To, summaries));
    }

    private static IReadOnlyList<DailySummaryResponse> Aggregate(IReadOnlyList<HealthReading> readings)
    {
        var summaries = readings
            .GroupBy(reading => DateOnly.FromDateTime(
                reading.RecordedAt.ToOffset(AggregationOffset).DateTime))
            .OrderBy(group => group.Key)
            .Select(group =>
            {
                var totalSteps = group.Sum(r => r.Metrics.Steps ?? 0);
                var totalCalories = group.Sum(r => r.Metrics.TotalCaloriesKcal ?? 0.0);
                var activeCalories = group.Sum(r => r.Metrics.ActiveCaloriesKcal ?? 0.0);
                var totalSleepTicks = group
                    .Where(r => r.Metrics.SleepDuration is not null)
                    .Sum(r => r.Metrics.SleepDuration!.Value.Ticks);

                var heartRates = group
                    .Where(r => r.Metrics.HeartRateBpm is not null)
                    .Select(r => r.Metrics.HeartRateBpm!.Value)
                    .ToList();

                var oxygenReadings = group
                    .Where(r => r.Metrics.OxygenSaturationPercent is not null)
                    .Select(r => r.Metrics.OxygenSaturationPercent!.Value)
                    .ToList();

                return new DailySummaryResponse(
                    group.Key,
                    totalSteps,
                    activeCalories,
                    totalCalories,
                    heartRates.Count > 0 ? heartRates.Average() : null,
                    totalSleepTicks > 0 ? TimeSpan.FromTicks(totalSleepTicks) : null,
                    oxygenReadings.Count > 0 ? oxygenReadings.Average() : null,
                    group.Count());
            })
            .ToList();

        return summaries;
    }
}