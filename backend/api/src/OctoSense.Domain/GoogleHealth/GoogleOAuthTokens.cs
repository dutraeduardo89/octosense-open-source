namespace OctoSense.Domain.GoogleHealth;

/// <summary>
/// OAuth token pair issued by Google for a connected Health account.
/// </summary>
/// <param name="AccessToken">Short-lived bearer token.</param>
/// <param name="RefreshToken">Rotated or stored refresh token.</param>
/// <param name="ExpiresIn">Token lifetime in seconds.</param>
public sealed record GoogleOAuthTokens(string AccessToken, string? RefreshToken, int ExpiresIn);
