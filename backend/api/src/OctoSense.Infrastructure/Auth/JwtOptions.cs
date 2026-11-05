namespace OctoSense.Infrastructure.Auth;

/// <summary>
/// Configuration for OctoSense-issued JWTs.
/// </summary>
public sealed class JwtOptions
{
    public const string SectionName = "Jwt";

    public string Secret { get; set; } = string.Empty;
    public string Issuer { get; set; } = "octosense";
    public string Audience { get; set; } = "octosense-app";
    public int AccessTokenMinutes { get; set; } = 15;
    public int RefreshTokenDays { get; set; } = 30;
}
