using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace OctoSense.Infrastructure.Persistence.Mongo;

/// <summary>
/// Mongo document for a refresh token.
/// </summary>
public sealed class RefreshTokenDocument
{
    [BsonId]
    [BsonElement("token")]
    public string Token { get; set; } = string.Empty;

    [BsonElement("userId")]
    [BsonRepresentation(BsonType.String)]
    public Guid UserId { get; set; }

    [BsonElement("createdAt")]
    public DateTimeOffset CreatedAt { get; set; }

    [BsonElement("expiresAt")]
    public DateTimeOffset ExpiresAt { get; set; }
}
