namespace OctoSense.Domain.GoogleHealth;

/// <summary>
/// Google account identity returned after OAuth.
/// </summary>
/// <param name="Email">Verified email used as the OctoSense user id.</param>
/// <remarks>
/// The mobile app has no separate login; this email is the owner of readings and the Health link.
/// </remarks>
public sealed record GoogleUserProfile(string Email);
