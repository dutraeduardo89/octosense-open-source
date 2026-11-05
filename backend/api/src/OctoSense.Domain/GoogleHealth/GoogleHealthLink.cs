namespace OctoSense.Domain.GoogleHealth;

/// <summary>
/// Linked Google Health account for a local OctoSense user.
/// </summary>
/// <param name="UserId">OctoSense user id.</param>
/// <param name="RefreshToken">Google refresh token.</param>
/// <param name="AccessToken">Cached access token.</param>
/// <param name="AccessTokenExpiresAt">UTC expiry of the access token.</param>
/// <param name="LinkedAt">When the link was created.</param>
/// <remarks>
/// Stored by Infrastructure; Domain only defines the shape via the repository port.
/// </remarks>
public sealed record GoogleHealthLink(
    string UserId,
    string RefreshToken,
    string? AccessToken,
    DateTimeOffset? AccessTokenExpiresAt,
    DateTimeOffset LinkedAt);
