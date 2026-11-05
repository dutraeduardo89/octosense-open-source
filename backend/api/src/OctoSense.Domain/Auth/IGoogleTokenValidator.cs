namespace OctoSense.Domain.Auth;

/// <summary>
/// Validates Google ID tokens emitted by Google Sign-In.
/// </summary>
public interface IGoogleTokenValidator
{
    /// <summary>
    /// Validates signature, issuer, audience and expiry.
    /// </summary>
    /// <returns>User info, or null when the token is invalid.</returns>
    Task<GoogleUserInfo?> ValidateAsync(string idToken, CancellationToken cancellationToken = default);
}
