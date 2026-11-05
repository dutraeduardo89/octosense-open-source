namespace OctoSense.Infrastructure.GoogleHealth;

/// <summary>
/// Configuration for Google Health OAuth and sync.
/// </summary>
/// <remarks>
/// Bound from the <c>GoogleHealth</c> configuration section. Secrets must come from env or user-secrets.
/// </remarks>
public sealed class GoogleHealthOptions
{
    /// <summary>
    /// Configuration section name.
    /// </summary>
    public const string SectionName = "GoogleHealth";

    /// <summary>
    /// OAuth client id from Google Cloud.
    /// </summary>
    public string ClientId { get; set; } = string.Empty;

    /// <summary>
    /// OAuth client secret from Google Cloud.
    /// </summary>
    public string ClientSecret { get; set; } = string.Empty;

    /// <summary>
    /// OAuth redirect URI registered in Google Cloud.
    /// </summary>
    public string RedirectUri { get; set; } = "http://localhost:5137/auth/google/health/callback";

    /// <summary>
    /// Background sync interval.
    /// </summary>
    public TimeSpan SyncInterval { get; set; } = TimeSpan.FromMinutes(15);

    /// <summary>
    /// When false, the background service does not poll Google.
    /// </summary>
    public bool Enabled { get; set; } = true;
}
