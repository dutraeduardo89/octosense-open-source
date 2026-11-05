using DotRMediator;
using OctoSense.Domain.Readings;
using OctoSense.Domain.Results;

namespace OctoSense.Application.Features.Readings.Commands.CreateHealthReading;

/// <summary>
/// Handles <see cref="CreateHealthReadingCommand"/> by creating a rich-domain reading and persisting it.
/// </summary>
/// <param name="repository">Persistence port for health readings.</param>
/// <remarks>
/// Replaces the previous application service. No extra service type is required for this feature.
/// </remarks>
public sealed class CreateHealthReadingCommandHandler(
    IHealthReadingRepository repository)
    : IRequestHandler<CreateHealthReadingCommand, Result<HealthReading>>
{
    /// <summary>
    /// Persistence port used after <see cref="HealthReading.Create"/> succeeds.
    /// </summary>
    /// <remarks>
    /// Mock this in unit tests. Do not mock <see cref="HealthReading"/>.
    /// </remarks>
    private readonly IHealthReadingRepository _repository = repository;

    /// <summary>
    /// Creates and stores a health reading.
    /// </summary>
    /// <param name="request">Validated create command.</param>
    /// <param name="cancellationToken">Token used to cancel persistence.</param>
    /// <returns>Success with the stored reading, or the errors returned by the domain factory.</returns>
    /// <remarks>
    /// The handler does not reconstruct invariants. Metadata omission is decided by <see cref="HealthReading.Create"/>.
    /// </remarks>
    public async Task<Result<HealthReading>> Handle(
        CreateHealthReadingCommand request,
        CancellationToken cancellationToken)
    {
        var readingResult = HealthReading.Create(
            request.UserId,
            request.DeviceId,
            request.DeviceSource,
            request.RecordedAt,
            request.HeartRateBpm,
            request.Steps,
            request.SleepDuration,
            request.OxygenSaturationPercent,
            request.ActiveCaloriesKcal,
            request.TotalCaloriesKcal,
            request.SyncMode,
            request.BatteryLevel,
            request.ExternalId);

        if (readingResult.IsFailure)
        {
            return readingResult;
        }

        await _repository.SaveAsync(readingResult.Value!, cancellationToken);
        return readingResult;
    }
}
