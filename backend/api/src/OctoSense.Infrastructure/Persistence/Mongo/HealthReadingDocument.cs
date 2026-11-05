using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace OctoSense.Infrastructure.Persistence.Mongo;

/// <summary>
/// Mongo document used to persist a domain health reading.
/// </summary>
/// <remarks>
/// Identity is a generated ObjectId. Extra BSON elements are ignored on read.
/// </remarks>
[BsonIgnoreExtraElements]
public sealed class HealthReadingDocument
{
    /// <summary>
    /// Mongo document identity.
    /// </summary>
    /// <remarks>
    /// Generated on insert. Must not be null, or Mongo treats every insert as <c>_id: null</c>.
    /// </remarks>
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; } = string.Empty;

    /// <summary>
    /// Owner of the reading.
    /// </summary>
    public string UserId { get; set; } = string.Empty;

    /// <summary>
    /// Source device identifier.
    /// </summary>
    public string DeviceId { get; set; } = string.Empty;

    /// <summary>
    /// Device platform or vendor label.
    /// </summary>
    public string DeviceSource { get; set; } = string.Empty;

    /// <summary>
    /// Instant when the measurement was captured.
    /// </summary>
    public DateTimeOffset RecordedAt { get; set; }

    /// <summary>
    /// Optional Google DataPoint name used for idempotency.
    /// </summary>
    public string? ExternalId { get; set; }

    /// <summary>
    /// Physiological metrics nested under the reading.
    /// </summary>
    public HealthReadingMetrics? Metrics { get; set; }

    /// <summary>
    /// Optional operational metadata.
    /// </summary>
    public HealthReadingMetadata? Metadata { get; set; }
}
