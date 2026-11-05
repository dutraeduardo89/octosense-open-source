using DotRMediator;
using OctoSense.Domain.Results;

namespace OctoSense.Application.Features.Readings.Queries.GetDailySummary;

/// <summary>
/// Query that returns per-day aggregated summaries for a user over a date range.
/// </summary>
/// <param name="UserId">Owner user id.</param>
/// <param name="From">Inclusive start date (UTC).</param>
/// <param name="To">Inclusive end date (UTC).</param>
public sealed record GetDailySummaryQuery(string UserId, DateOnly From, DateOnly To)
    : IRequest<Result<PeriodSummaryResponse>>;