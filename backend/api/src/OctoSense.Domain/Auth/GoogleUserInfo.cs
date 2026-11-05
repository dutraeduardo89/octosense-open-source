namespace OctoSense.Domain.Auth;

/// <summary>
/// Identity extracted from a validated Google ID Token.
/// </summary>
public sealed record GoogleUserInfo(
    string Subject,
    string Email,
    string? DisplayName);
