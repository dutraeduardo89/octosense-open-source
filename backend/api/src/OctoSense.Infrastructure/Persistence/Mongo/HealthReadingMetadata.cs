namespace OctoSense.Infrastructure.Persistence.Mongo;

/// <summary>
/// BSON subdocument for operational device metadata.
/// </summary>
/// <remarks>
/// Not clinical data. Null on the parent document when the client omitted both fields.
/// </remarks>
public sealed class HealthReadingMetadata
{
    /// <summary>
    /// Optional synchronization mode reported by the device.
    /// </summary>
    public string? SyncMode { get; set; }

    /// <summary>
    /// Optional battery percentage in the inclusive range 0–100.
    /// </summary>
    public int? BatteryLevel { get; set; }
}
