using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace OctoSense.Infrastructure.Persistence.Mongo;

/// <summary>
/// Mongo document for a user account.
/// </summary>
/// <remarks>
/// Collection is <c>users</c>. Email is the natural unique key.
/// </remarks>
public sealed class UserDocument
{
    [BsonId]
    [BsonRepresentation(BsonType.String)]
    public Guid Id { get; set; }

    [BsonElement("email")]
    public string Email { get; set; } = string.Empty;

    [BsonElement("displayName")]
    public string? DisplayName { get; set; }

    [BsonElement("createdAt")]
    public DateTimeOffset CreatedAt { get; set; }

    [BsonElement("lastLoginAt")]
    public DateTimeOffset LastLoginAt { get; set; }
}
