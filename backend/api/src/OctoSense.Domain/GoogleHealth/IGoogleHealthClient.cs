namespace OctoSense.Domain.GoogleHealth;

/// <summary>
/// Port for Google Health OAuth and DataPoint listing.
/// </summary>
/// <remarks>
/// Implemented in Infrastructure with HttpClient. Domain has no HTTP dependency.
/// </remarks>
public interface IGoogleHealthClient
{
    /// <summary>
    /// Builds the OAuth authorization URL for the mobile consent flow.
    /// </summary>
    /// <returns>Absolute authorization URL.</returns>
    /// <remarks>
    /// Uses offline access so a refresh token can be stored. Identity comes from Google userinfo, not from <c>state</c>.
    /// </remarks>
    string BuildAuthorizationUrl();

    /// <summary>
    /// Exchanges an authorization code for OAuth tokens.
    /// </summary>
    /// <param name="code">Authorization code from the callback.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Access and optional refresh tokens.</returns>
    /// <remarks>
    /// Throws on HTTP failure; callers must not persist partial state.
    /// </remarks>
    Task<GoogleOAuthTokens> ExchangeCodeAsync(string code, CancellationToken cancellationToken = default);

    /// <summary>
    /// Refreshes an access token using a stored refresh token.
    /// </summary>
    /// <param name="refreshToken">Stored Google refresh token.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>New access token (and possibly rotated refresh token).</returns>
    /// <remarks>
    /// Call on-demand per user; do not batch-refresh all users.
    /// </remarks>
    Task<GoogleOAuthTokens> RefreshAccessTokenAsync(
        string refreshToken,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Reads the Google account email for the current access token.
    /// </summary>
    /// <param name="accessToken">Bearer access token.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>The Google user profile.</returns>
    /// <remarks>
    /// Requires the <c>email</c> OIDC scope. The email becomes the OctoSense user id.
    /// </remarks>
    Task<GoogleUserProfile> GetUserProfileAsync(
        string accessToken,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Lists data points for a data type since the given instant.
    /// </summary>
    /// <param name="accessToken">Bearer access token.</param>
    /// <param name="dataType">Google data type id.</param>
    /// <param name="since">Inclusive lower bound for the query window.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Mapped data points ready for domain creation.</returns>
    /// <remarks>
    /// Empty lists are valid (no-op for the sync handler).
    /// </remarks>
    Task<IReadOnlyList<GoogleHealthDataPoint>> ListDataPointsAsync(
        string accessToken,
        string dataType,
        DateTimeOffset since,
        CancellationToken cancellationToken = default);
}
