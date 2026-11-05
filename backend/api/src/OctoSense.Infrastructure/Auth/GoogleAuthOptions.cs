namespace OctoSense.Infrastructure.Auth;

/// <summary>
/// Google OAuth configuration for token validation.
/// </summary>
public sealed class GoogleAuthOptions
{
    public const string SectionName = "GoogleAuth";

    /// <summary>
    /// Accepted client ids. A single backend must accept tokens
    /// from multiple clients (Android, iOS, Web).
    /// </summary>
    public string[] ClientIds { get; set; } = [];
}
