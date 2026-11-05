using OctoSense.Domain.Results;

namespace OctoSense.Domain.Readings;

/// <summary>
/// Health reading ingested from a wearable, Google Health sync, or simulator.
/// </summary>
/// <remarks>
/// Rich domain entity. Educational data only; it does not represent a medical diagnosis.
/// Invariants are enforced by <see cref="Create"/>. There is no public constructor.
/// </remarks>
public sealed class HealthReading
{
    /// <summary>
    /// Initializes a reading that already passed invariants.
    /// </summary>
    /// <param name="userId">Owner of the reading.</param>
    /// <param name="deviceId">Source device identifier.</param>
    /// <param name="deviceSource">Device platform or vendor label.</param>
    /// <param name="recordedAt">Instant when the measurement was captured.</param>
    /// <param name="metrics">Physiological metrics nested under the reading.</param>
    /// <param name="metadata">Optional operational metadata.</param>
    /// <param name="externalId">Optional external idempotency key (e.g. Google DataPoint name).</param>
    /// <remarks>
    /// Callers must use <see cref="Create"/>. Direct construction is reserved for a valid state.
    /// </remarks>
    private HealthReading(
        string userId,
        string deviceId,
        string deviceSource,
        DateTimeOffset recordedAt,
        HealthReadingMetrics metrics,
        HealthReadingMetadata? metadata,
        string? externalId)
    {
        UserId = userId;
        DeviceId = deviceId;
        DeviceSource = deviceSource;
        RecordedAt = recordedAt;
        Metrics = metrics;
        Metadata = metadata;
        ExternalId = externalId;
    }

    /// <summary>
    /// Owner of the reading.
    /// </summary>
    /// <remarks>
    /// Required and non-whitespace after a successful <see cref="Create"/>.
    /// </remarks>
    public string UserId { get; }

    /// <summary>
    /// Source device identifier.
    /// </summary>
    /// <remarks>
    /// Required and non-whitespace after a successful <see cref="Create"/>.
    /// </remarks>
    public string DeviceId { get; }

    /// <summary>
    /// Device platform or vendor label.
    /// </summary>
    /// <remarks>
    /// Required and non-whitespace after a successful <see cref="Create"/>.
    /// </remarks>
    public string DeviceSource { get; }

    /// <summary>
    /// Instant when the measurement was captured.
    /// </summary>
    public DateTimeOffset RecordedAt { get; }

    /// <summary>
    /// Physiological metrics nested under the reading.
    /// </summary>
    public HealthReadingMetrics Metrics { get; }

    /// <summary>
    /// Optional operational metadata.
    /// </summary>
    /// <remarks>
    /// Null when the client omitted both sync mode and battery level.
    /// </remarks>
    public HealthReadingMetadata? Metadata { get; }

    /// <summary>
    /// Optional external idempotency key such as a Google Health DataPoint name.
    /// </summary>
    /// <remarks>
    /// Null for HTTP ingestions that do not carry an external identifier.
    /// </remarks>
    public string? ExternalId { get; }

    /// <summary>
    /// Creates a reading when identity, sparse metrics, and optional metadata satisfy invariants.
    /// </summary>
    /// <param name="userId">Owner of the reading. Required and non-empty.</param>
    /// <param name="deviceId">Source device identifier. Required and non-empty.</param>
    /// <param name="deviceSource">Device platform or vendor label. Required and non-empty.</param>
    /// <param name="recordedAt">Instant when the measurement was captured.</param>
    /// <param name="heartRateBpm">Optional heart rate. When present, must be greater than zero.</param>
    /// <param name="steps">Optional step count. When present, must be greater than or equal to zero.</param>
    /// <param name="sleepDuration">Optional sleep duration. When present, must be greater than zero.</param>
    /// <param name="oxygenSaturationPercent">Optional SpO2. When present, must be 0–100.</param>
    /// <param name="totalCaloriesKcal">Optional calories. When present, must be greater than or equal to zero.</param>
    /// <param name="syncMode">Optional device synchronization mode.</param>
    /// <param name="batteryLevel">Optional battery percentage in the inclusive range 0–100.</param>
    /// <param name="externalId">Optional external idempotency key. When present, must be non-empty.</param>
    /// <returns>Success with the reading, or aggregated validation errors.</returns>
    /// <remarks>
    /// Application handlers must persist only the success payload. Do not new the entity.
    /// </remarks>
    public static Result<HealthReading> Create(
        string userId,
        string deviceId,
        string deviceSource,
        DateTimeOffset recordedAt,
        double? heartRateBpm = null,
        int? steps = null,
        TimeSpan? sleepDuration = null,
        double? oxygenSaturationPercent = null,
        double? activeCaloriesKcal = null,
        double? totalCaloriesKcal = null,
        string? syncMode = null,
        int? batteryLevel = null,
        string? externalId = null)
    {
        var errors = new List<Error>();

        if (string.IsNullOrWhiteSpace(userId))
        {
            errors.Add(Error.Validation(nameof(UserId), "UserId is required."));
        }

        if (string.IsNullOrWhiteSpace(deviceId))
        {
            errors.Add(Error.Validation(nameof(DeviceId), "DeviceId is required."));
        }

        if (string.IsNullOrWhiteSpace(deviceSource))
        {
            errors.Add(Error.Validation(nameof(DeviceSource), "DeviceSource is required."));
        }

        if (externalId is not null && string.IsNullOrWhiteSpace(externalId))
        {
            errors.Add(Error.Validation(nameof(ExternalId), "ExternalId must be non-empty when provided."));
        }

        var metricsResult = HealthReadingMetrics.Create(
            heartRateBpm,
            steps,
            sleepDuration,
            oxygenSaturationPercent,
            activeCaloriesKcal,
            totalCaloriesKcal);
        if (metricsResult.IsFailure)
        {
            errors.AddRange(metricsResult.Errors);
        }

        var metadataResult = HealthReadingMetadata.CreateOptional(syncMode, batteryLevel);
        if (metadataResult.IsFailure)
        {
            errors.AddRange(metadataResult.Errors);
        }

        if (errors.Count > 0)
        {
            return Result<HealthReading>.Failure(errors);
        }

        return Result<HealthReading>.Success(
            new HealthReading(
                userId,
                deviceId,
                deviceSource,
                recordedAt,
                metricsResult.Value!,
                metadataResult.Value,
                externalId));
    }
}
