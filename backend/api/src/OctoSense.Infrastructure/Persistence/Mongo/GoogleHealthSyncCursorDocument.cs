using MongoDB.Bson.Serialization.Attributes;

namespace OctoSense.Infrastructure.Persistence.Mongo;

/// <summary>
/// Mongo document representing the last synced time per data type.
/// </summary>
/// <remarks>
/// Upserts leave an auto-generated <c>_id</c>; extra BSON elements are ignored on read.
/// </remarks>
[BsonIgnoreExtraElements]
public sealed class GoogleHealthSyncCursorDocument
{
    /// <summary>
    /// OctoSense user id.
    /// </summary>
    public string UserId { get; set; } = string.Empty;

    /// <summary>
    /// Google Health data type key, such as <c>heart-rate</c>.
    /// </summary>
    public string DataType { get; set; } = string.Empty;

    /// <summary>
    /// Upper bound of the last successful sync window.
    /// </summary>
    public DateTimeOffset LastSyncedAt { get; set; }
}
