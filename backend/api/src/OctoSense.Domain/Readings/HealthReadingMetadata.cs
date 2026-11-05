using OctoSense.Domain.Results;

namespace OctoSense.Domain.Readings;

/// <summary>
/// Operational, non-clinical device metadata.
/// </summary>
/// <remarks>
/// Value object. Omitted from the reading when both sync mode and battery are null.
/// </remarks>
public sealed class HealthReadingMetadata
{
    /// <summary>
    /// Initializes metadata that already passed invariants.
    /// </summary>
    /// <param name="syncMode">Optional synchronization mode.</param>
    /// <param name="batteryLevel">Optional battery percentage.</param>
    /// <remarks>
    /// Callers must use <see cref="CreateOptional"/>. Direct construction is reserved for a valid state.
    /// </remarks>
    public HealthReadingMetadata()
    {
    }

    private HealthReadingMetadata(string? syncMode, int? batteryLevel)
    {
        SyncMode = syncMode;
        BatteryLevel = batteryLevel;
    }

    /// <summary>
    /// Optional synchronization mode reported by the device.
    /// </summary>
    public string? SyncMode { get; set; }

    /// <summary>
    /// Optional battery percentage in the inclusive range 0–100.
    /// </summary>
    public int? BatteryLevel { get; set; }

    /// <summary>
    /// Creates metadata or returns null when the client omitted both fields.
    /// </summary>
    /// <param name="syncMode">Optional synchronization mode.</param>
    /// <param name="batteryLevel">Optional battery percentage. When present, must be 0–100.</param>
    /// <returns>Success with metadata, success with null, or a validation error.</returns>
    /// <remarks>
    /// Null payload is a valid domain outcome, not a failure.
    /// </remarks>
    public static Result<HealthReadingMetadata?> CreateOptional(string? syncMode, int? batteryLevel)
    {
        if (syncMode is null && batteryLevel is null)
        {
            return Result<HealthReadingMetadata?>.Success(null);
        }

        if (batteryLevel is { } level && (level < 0 || level > 100))
        {
            return Result<HealthReadingMetadata?>.Failure(
                Error.Validation(nameof(BatteryLevel), "BatteryLevel must be between 0 and 100."));
        }

        return Result<HealthReadingMetadata?>.Success(new HealthReadingMetadata(syncMode, batteryLevel));
    }
}
