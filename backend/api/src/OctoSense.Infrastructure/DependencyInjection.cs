using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using MongoDB.Driver;
using OctoSense.Domain.Auth;
using OctoSense.Domain.GoogleHealth;
using OctoSense.Domain.Readings;
using OctoSense.Infrastructure.Auth;
using OctoSense.Application.Features.Feedback;
using OctoSense.Infrastructure.GoogleHealth;
using OctoSense.Infrastructure.Feedback;
using OctoSense.Infrastructure.Persistence.Mongo;

namespace OctoSense.Infrastructure;

/// <summary>
/// Registers Mongo persistence and Google Health adapters for the composition root.
/// </summary>
/// <remarks>
/// Keeps connection details and HTTP clients out of the Application layer.
/// </remarks>
public static class DependencyInjection
{
    /// <summary>
    /// Adds Mongo, Google Health client, and repository adapters.
    /// </summary>
    /// <param name="services">DI collection of the composition root.</param>
    /// <param name="configuration">Host configuration for connection string and Google Health options.</param>
    /// <returns>The same collection for chaining.</returns>
    /// <remarks>
    /// Fallback Mongo connection is the local instance on port 27017.
    /// </remarks>
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var mongoConnectionString = configuration.GetConnectionString("MongoDb")
            ?? "mongodb://localhost:27017/";
        var mongoDatabaseName = configuration["Mongo:DatabaseName"] ?? "octosense";

        services.Configure<GoogleHealthOptions>(configuration.GetSection(GoogleHealthOptions.SectionName));

        services.AddSingleton<IMongoClient>(_ => new MongoClient(mongoConnectionString));
        services.AddScoped(serviceProvider =>
            new MongoDbContext(
                serviceProvider.GetRequiredService<IMongoClient>(),
                mongoDatabaseName));
        services.AddScoped<IHealthReadingRepository, MongoHealthReadingRepository>();
        services.AddScoped<IGoogleHealthLinkRepository, MongoGoogleHealthLinkRepository>();
        services.AddScoped<IGoogleHealthSyncCursorRepository, MongoGoogleHealthSyncCursorRepository>();

        services.Configure<JwtOptions>(configuration.GetSection(JwtOptions.SectionName));
        services.Configure<GoogleAuthOptions>(configuration.GetSection(GoogleAuthOptions.SectionName));

        services.AddScoped<IUserRepository, MongoUserRepository>();
        services.AddScoped<IRefreshTokenRepository, MongoRefreshTokenRepository>();
        services.AddScoped<IGoogleTokenValidator, GoogleTokenValidator>();
        services.AddScoped<IJwtTokenService, JwtTokenService>();

        services.AddHttpClient<IGoogleHealthClient, GoogleHealthClient>();

        services.AddHttpClient<IFeedbackService, OllamaFeedbackService>(client =>
        {
            var baseUrl = configuration["Ollama:BaseUrl"] ?? "http://ollama:11434/";
            client.BaseAddress = new Uri(baseUrl.EndsWith('/') ? baseUrl : baseUrl + "/");
            client.Timeout = TimeSpan.FromSeconds(45);
        });

        return services;
    }
}
