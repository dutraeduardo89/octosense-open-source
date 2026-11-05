using System.Threading.RateLimiting;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi;
using OctoSense.Infrastructure.Auth;
using OctoSense.Api.Exceptions;
using OctoSense.Application;
using OctoSense.Infrastructure;
using OctoSense.Infrastructure.Persistence.Mongo;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
builder.Services.AddProblemDetails();
builder.Services.AddControllers();
// CORS removido: cliente Flutter e nativo (nao envia Origin).
// Adicionar politica restritiva quando existir versao web.
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("octosense", new OpenApiInfo
    {
        Title = "OctoSense API",
        Description = "Health data service for OctoSense readings and Health Connect synchronization.",
        Version = "1.0"
    });
});
builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);
// JWT authentication
var jwtSection = builder.Configuration.GetSection(JwtOptions.SectionName);
var jwtSecret = jwtSection["Secret"]
    ?? throw new InvalidOperationException("Jwt:Secret não configurado.");
var jwtIssuer = jwtSection["Issuer"] ?? "octosense";
var jwtAudience = jwtSection["Audience"] ?? "octosense-app";

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = jwtIssuer,
            ValidateAudience = true,
            ValidAudience = jwtAudience,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret)),
            ClockSkew = TimeSpan.FromMinutes(1),
        };
    });
builder.Services.AddAuthorization();

// Health Connect is the canonical product ingestion path.
// The legacy Google Health worker is intentionally not registered.


// -----------------------------------------------------------------------------
// Rate limiting global (by IP ou X-Forwarded-For se vier de tunnel)
// 120 requests/min por IP. Suficiente para uso normal; barra abuso.
// -----------------------------------------------------------------------------
builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
    options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(context =>
    {
        var forwarded = context.Request.Headers["X-Forwarded-For"].FirstOrDefault();
        var ip = !string.IsNullOrWhiteSpace(forwarded)
            ? forwarded.Split(',')[0].Trim()
            : context.Connection.RemoteIpAddress?.ToString() ?? "unknown";

        return RateLimitPartition.GetFixedWindowLimiter(ip, _ =>
            new FixedWindowRateLimiterOptions
            {
                Window = TimeSpan.FromMinutes(1),
                PermitLimit = 120,
                QueueLimit = 0,
                QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
            });
    });
});

var app = builder.Build();

app.UseExceptionHandler();
app.UseRateLimiter();
app.UseAuthentication();
app.UseAuthorization();
app.UseSwagger();
app.UseSwaggerUI(options =>
{
    options.SwaggerEndpoint("/swagger/octosense/swagger.json", "OctoSense API");
    options.RoutePrefix = "swagger";
});

using (var scope = app.Services.CreateScope())
{
    var mongoDb = scope.ServiceProvider.GetRequiredService<MongoDbContext>();
    MongoIndexInitializer.EnsureIndexesAsync(mongoDb).GetAwaiter().GetResult();
}

app.MapControllers();

app.Run();

/// <summary>
/// ASP.NET composition root marker used by integration tests.
/// </summary>
/// <remarks>
/// Partial so <c>WebApplicationFactory&lt;Program&gt;</c> can discover the entry point.
/// </remarks>
public partial class Program
{
}
