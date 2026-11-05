using System.Security.Claims;

namespace OctoSense.Api.Extensions;

/// <summary>
/// Helpers para ler o email do usuário autenticado a partir do JWT.
/// </summary>
/// <remarks>
/// O JwtTokenService emite o claim "email" (JwtRegisteredClaimNames.Email).
/// Dependendo da configuração do JwtBearer, o ASP.NET Core pode remapear
/// esse claim para ClaimTypes.Email. Esta extensão cobre os dois casos.
///
/// Null-safe: retorna null se o principal for null (ex: testes unitários
/// que instanciam o controller sem HttpContext).
/// </remarks>
public static class ClaimsPrincipalExtensions
{
    /// <summary>
    /// Retorna o email autenticado, ou null se não houver.
    /// </summary>
    public static string? GetAuthenticatedEmail(this ClaimsPrincipal? principal)
    {
        if (principal is null)
        {
            return null;
        }

        var raw = principal.FindFirst("email")?.Value;
        if (!string.IsNullOrWhiteSpace(raw))
        {
            return raw;
        }

        var mapped = principal.FindFirst(ClaimTypes.Email)?.Value;
        return string.IsNullOrWhiteSpace(mapped) ? null : mapped;
    }
}
