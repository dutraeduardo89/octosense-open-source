using MongoDB.Bson.Serialization.Attributes;

namespace OctoSense.Infrastructure.Persistence.Mongo;

/// <summary>
/// Mongo document for a linked Google Health account.
/// </summary>
/// <remarks>
/// Upserts leave an auto-generated <c>_id</c>; extra BSON elements are ignored on read.
/// Tokens are persisted but must never be logged.
/// </remarks>
[BsonIgnoreExtraElements]
public sealed class GoogleHealthLinkDocument
{
    /// <summary>
    /// OctoSense user id that owns the Google link.
    /// </summary>
    public string UserId { get; set; } = string.Empty;

    /// <summary>
    /// Google OAuth refresh token.
    /// </summary>
    public string RefreshToken { get; set; } = string.Empty;

    /// <summary>
    /// Cached Google OAuth access token.
    /// </summary>
    public string? AccessToken { get; set; }

    /// <summary>
    /// UTC expiry of <see cref="AccessToken"/>.
    /// </summary>
    public DateTimeOffset? AccessTokenExpiresAt { get; set; }

    /// <summary>
    /// When the account was linked.
    /// </summary>
    public DateTimeOffset LinkedAt { get; set; }
}
