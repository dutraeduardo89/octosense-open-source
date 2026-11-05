using DotRMediator;
using OctoSense.Domain.Readings;
using OctoSense.Domain.Results;

namespace OctoSense.Application.Features.Readings.Queries.GetReadingsByUser;

/// <summary>
/// Query that lists readings owned by a user.
/// </summary>
/// <param name="UserId">Owner user id.</param>
public sealed record GetReadingsByUserQuery(string UserId)
    : IRequest<Result<IReadOnlyList<HealthReading>>>;
