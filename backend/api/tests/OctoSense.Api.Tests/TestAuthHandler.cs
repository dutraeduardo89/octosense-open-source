using System.Security.Claims;
using System.Text.Encodings.Web;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace OctoSense.Api.Tests;

/// <summary>
/// Handler de autenticação usado apenas em testes de integração.
/// Substitui o esquema JwtBearer real para que endpoints protegidos
/// por [Authorize] possam ser exercitados sem gerar tokens JWT reais.
/// </summary>
/// <remarks>
/// Toda request é autenticada como o mesmo usuário sintético.
/// Inclui os claims "email" e ClaimTypes.Email para que o BOLA fix
/// (comparação email do JWT x userId da URL) funcione em testes.
/// </remarks>
public sealed class TestAuthHandler : AuthenticationHandler<AuthenticationSchemeOptions>
{
    public const string SchemeName = "TestScheme";

    /// <summary>Usuário sintético. Usado como email e userId nos testes.</summary>
    public const string TestUserId = "usr_test_001";

    public TestAuthHandler(
        IOptionsMonitor<AuthenticationSchemeOptions> options,
        ILoggerFactory logger,
        UrlEncoder encoder)
        : base(options, logger, encoder)
    {
    }

    protected override Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, TestUserId),
            new Claim(ClaimTypes.Name, "test-user"),
            new Claim("email", TestUserId),
            new Claim(ClaimTypes.Email, TestUserId),
        };

        var identity = new ClaimsIdentity(claims, SchemeName);
        var principal = new ClaimsPrincipal(identity);
        var ticket = new AuthenticationTicket(principal, SchemeName);

        return Task.FromResult(AuthenticateResult.Success(ticket));
    }
}
