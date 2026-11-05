using DotRMediator;
using OctoSense.Domain.Readings;
using OctoSense.Domain.Results;

namespace OctoSense.Application.Features.Readings.Commands.CreateHealthReading;

/// <summary>
/// Creates a new health reading from a wearable or manual ingestion.
/// </summary>
/// <param name="UserId">Owner of the reading.</param>
/// <param name="DeviceId">Source device identifier.</param>
/// <param name="DeviceSource">Device platform or vendor label.</param>
/// <param name="RecordedAt">Measurement timestamp.</param>
/// <param name="HeartRateBpm">Optional heart rate.</param>
/// <param name="Steps">Optional steps count.</param>
/// <param name="SleepDuration">Optional sleep duration.</param>
/// <param name="OxygenSaturationPercent">Optional blood oxygen.</param>
/// <param name="TotalCaloriesKcal">Optional calories.</param>
/// <param name="SyncMode">Optional sync mode.</param>
/// <param name="BatteryLevel">Optional battery percentage.</param>
/// <param name="ExternalId">Optional external idempotency key.</param>
public sealed record CreateHealthReadingCommand(
    string UserId,
    string DeviceId,
    string DeviceSource,
    DateTimeOffset RecordedAt,
    double? HeartRateBpm = null,
    int? Steps = null,
    TimeSpan? SleepDuration = null,
    double? OxygenSaturationPercent = null,
    double? ActiveCaloriesKcal = null,
    double? TotalCaloriesKcal = null,
    string? SyncMode = null,
    int? BatteryLevel = null,
    string? ExternalId = null
) : IRequest<Result<HealthReading>>;
