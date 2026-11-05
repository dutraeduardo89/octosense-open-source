using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using OctoSense.Domain.Auth;

namespace OctoSense.Infrastructure.Auth;

/// <summary>
/// Issues OctoSense-issued JWTs and stores refresh tokens in Mongo.
/// </summary>
public sealed class JwtTokenService(
    IOptions<JwtOptions> options,
    IRefreshTokenRepository refreshTokens) : IJwtTokenService
{
    private readonly JwtOptions _options = options.Value;
    private readonly IRefreshTokenRepository _refreshTokens = refreshTokens;

    public async Task<AuthTokens> IssueAsync(
        User user,
        CancellationToken cancellationToken = default)
    {
        var now = DateTimeOffset.UtcNow;
        var accessExpiresAt = now.AddMinutes(_options.AccessTokenMinutes);
        var refreshExpiresAt = now.AddDays(_options.RefreshTokenDays);

        var accessToken = BuildAccessToken(user, now, accessExpiresAt);
        var refreshToken = BuildRefreshToken();

        await _refreshTokens.SaveAsync(
            new RefreshToken(refreshToken, user.Id, now, refreshExpiresAt),
            cancellationToken);

        return new AuthTokens(accessToken, refreshToken, accessExpiresAt, refreshExpiresAt);
    }

    public Guid? TryGetUserId(string accessToken)
    {
        try
        {
            var handler = new JwtSecurityTokenHandler();
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_options.Secret));

            var principal = handler.ValidateToken(accessToken, new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidIssuer = _options.Issuer,
                ValidateAudience = true,
                ValidAudience = _options.Audience,
                ValidateLifetime = true,
                IssuerSigningKey = key,
                ClockSkew = TimeSpan.FromMinutes(1),
            }, out _);

            var sub = principal.FindFirst(JwtRegisteredClaimNames.Sub)?.Value
                ?? principal.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            return Guid.TryParse(sub, out var id) ? id : null;
        }
        catch
        {
            return null;
        }
    }

    private string BuildAccessToken(User user, DateTimeOffset now, DateTimeOffset expiresAt)
    {
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_options.Secret));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.Email, user.Email),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
        };

        var token = new JwtSecurityToken(
            issuer: _options.Issuer,
            audience: _options.Audience,
            claims: claims,
            notBefore: now.UtcDateTime,
            expires: expiresAt.UtcDateTime,
            signingCredentials: credentials);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    private static string BuildRefreshToken()
    {
        var bytes = RandomNumberGenerator.GetBytes(64);
        return Convert.ToBase64String(bytes).Replace("+", "-").Replace("/", "_").TrimEnd('=');
    }
}
