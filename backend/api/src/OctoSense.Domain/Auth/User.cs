namespace OctoSense.Domain.Auth;

/// <summary>
/// User account owned by a person (identified by Google).
/// </summary>
/// <param name="Id">Stable internal identifier (GUID).</param>
/// <param name="Email">Normalized email from Google. Unique in the system.</param>
/// <param name="DisplayName">Optional display name from Google.</param>
/// <param name="CreatedAt">UTC timestamp of first login.</param>
/// <param name="LastLoginAt">UTC timestamp of most recent login.</param>
/// <remarks>
/// The user is the center of the product. Devices are sources. Email is the natural key.
/// </remarks>
public sealed record User(
    Guid Id,
    string Email,
    string? DisplayName,
    DateTimeOffset CreatedAt,
    DateTimeOffset LastLoginAt);