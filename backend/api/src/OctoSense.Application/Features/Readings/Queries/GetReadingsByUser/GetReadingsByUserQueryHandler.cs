using DotRMediator;
using OctoSense.Domain.Readings;
using OctoSense.Domain.Results;

namespace OctoSense.Application.Features.Readings.Queries.GetReadingsByUser;

/// <summary>
/// Returns all readings for a user in descending recorded time order.
/// </summary>
/// <param name="repository">Reading persistence port.</param>
public sealed class GetReadingsByUserQueryHandler(IHealthReadingRepository repository)
    : IRequestHandler<GetReadingsByUserQuery, Result<IReadOnlyList<HealthReading>>>
{
    private readonly IHealthReadingRepository _repository = repository;

    public async Task<Result<IReadOnlyList<HealthReading>>> Handle(
        GetReadingsByUserQuery request,
        CancellationToken cancellationToken
    )
    {
        if (string.IsNullOrWhiteSpace(request.UserId))
        {
            return Result<IReadOnlyList<HealthReading>>.Failure(
                Error.Validation(nameof(request.UserId), "UserId is required.")
            );
        }

        var readings = await _repository.ListByUserIdAsync(request.UserId, cancellationToken);
        return Result<IReadOnlyList<HealthReading>>.Success(readings);
    }
}
