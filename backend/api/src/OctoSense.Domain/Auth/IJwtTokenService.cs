namespace OctoSense.Domain.Auth;

/// <summary>
/// Issues and validates OctoSense JWT access tokens.
/// </summary>
public interface IJwtTokenService
{
    /// <summary>
    /// Creates a fresh token pair for the user and stores the refresh token.
    /// </summary>
    Task<AuthTokens> IssueAsync(User user, CancellationToken cancellationToken = default);

    /// <summary>
    /// Reads the user id from a valid access token. Returns null when expired or invalid.
    /// </summary>
    Guid? TryGetUserId(string accessToken);
}
