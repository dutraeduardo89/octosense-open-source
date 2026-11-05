namespace OctoSense.Domain.Auth;

/// <summary>
/// Refresh token stored server-side to allow session revocation (LGPD).
/// </summary>
public sealed record RefreshToken(
    string Token,
    Guid UserId,
    DateTimeOffset CreatedAt,
    DateTimeOffset ExpiresAt);
