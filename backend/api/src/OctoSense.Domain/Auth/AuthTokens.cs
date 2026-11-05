namespace OctoSense.Domain.Auth;

/// <summary>
/// Pair of tokens issued to a client after successful login.
/// </summary>
public sealed record AuthTokens(
    string AccessToken,
    string RefreshToken,
    DateTimeOffset AccessExpiresAt,
    DateTimeOffset RefreshExpiresAt);
