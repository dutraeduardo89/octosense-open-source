using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;

namespace OctoSense.Api.Tests;

/// <summary>
/// Test host que aponta a API para um banco Mongo efêmero e substitui
/// o esquema JwtBearer real por um handler de autenticação de teste.
/// </summary>
/// <remarks>
/// Toda configuração obrigatória (Jwt:Secret, connection string, etc) é
/// injetada via UseSetting ANTES de Program.cs rodar. Isso torna os testes
/// auto-suficientes: não dependem de appsettings.Development.json (que é
/// gitignored e não existe no CI).
/// </remarks>
public sealed class CustomWebApplicationFactory : WebApplicationFactory<Program>
{
    /// <summary>
    /// Segredo HMAC usado APENAS em testes. Nunca vai pra produção.
    /// Precisa ter >= 32 bytes (256 bits) pro HMAC-SHA256 do JwtBearer.
    /// </summary>
    private const string TestJwtSecret =
        "test-only-secret-for-hmac-sha256-64-bytes-minimum-abcdefghijklmnop";

    /// <summary>
    /// Connection string do Mongo efêmero (Testcontainers).
    /// </summary>
    private readonly string _connectionString;

    /// <summary>
    /// Nome de banco único gerado para esta instância de factory.
    /// </summary>
    private readonly string _testDatabaseName;

    /// <summary>
    /// Cria uma factory ligada a uma connection string Mongo.
    /// </summary>
    /// <param name="connectionString">Mongo efêmero vindo do fixture compartilhado.</param>
    public CustomWebApplicationFactory(string connectionString)
    {
        _connectionString = connectionString;
        _testDatabaseName = $"octosense_test_{Guid.NewGuid():N}";
    }

    /// <inheritdoc />
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        // ---- Config obrigatória (antes do Program.cs) ----

        // Mongo (Testcontainers)
        builder.UseSetting("ConnectionStrings:MongoDb", _connectionString);
        builder.UseSetting("Mongo:DatabaseName", _testDatabaseName);

        // Google Health sync desligado (não vamos chamar Google nos testes)
        builder.UseSetting("GoogleHealth:Enabled", "false");

        // JWT — obrigatório: Program.cs joga InvalidOperationException
        // se Jwt:Secret estiver ausente.
        builder.UseSetting("Jwt:Secret", TestJwtSecret);
        builder.UseSetting("Jwt:Issuer", "octosense-test");
        builder.UseSetting("Jwt:Audience", "octosense-test-app");
        builder.UseSetting("Jwt:AccessTokenMinutes", "15");
        builder.UseSetting("Jwt:RefreshTokenDays", "30");

        // Google OAuth (login + health). Os testes não chamam Google de verdade.
        builder.UseSetting(
            "GoogleAuth:ClientIds:0",
            "test-client-id.apps.googleusercontent.com");
        builder.UseSetting(
            "GoogleHealth:ClientId",
            "test-health-client-id.apps.googleusercontent.com");
        builder.UseSetting("GoogleHealth:ClientSecret", "test-client-secret");
        builder.UseSetting(
            "GoogleHealth:RedirectUri",
            "http://localhost:5137/auth/google/health/callback");
        builder.UseSetting("GoogleHealth:SyncInterval", "00:00:20");

        // ---- Substituição do esquema de auth ----
        //
        // ConfigureTestServices roda DEPOIS de todo o Program.cs. Aqui
        // trocamos o esquema padrão (JwtBearer) por um handler que
        // autentica toda request como usr_test_001.
        builder.ConfigureTestServices(services =>
        {
            services
                .AddAuthentication(TestAuthHandler.SchemeName)
                .AddScheme<AuthenticationSchemeOptions, TestAuthHandler>(
                    TestAuthHandler.SchemeName,
                    _ => { });
        });
    }
}
