using Google.Apis.Auth;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using OctoSense.Domain.Auth;

namespace OctoSense.Infrastructure.Auth;

/// <summary>
/// Validates Google ID tokens using the official Google.Apis.Auth library.
/// </summary>
public sealed class GoogleTokenValidator(
    IOptions<GoogleAuthOptions> options,
    ILogger<GoogleTokenValidator> logger) : IGoogleTokenValidator
{
    private readonly GoogleAuthOptions _options = options.Value;
    private readonly ILogger<GoogleTokenValidator> _logger = logger;

    public async Task<GoogleUserInfo?> ValidateAsync(
        string idToken,
        CancellationToken cancellationToken = default)
    {
        _logger.LogInformation(
            "[GoogleTokenValidator] Validando idToken. Audience(s) esperada(s): [{Clients}]",
            string.Join(", ", _options.ClientIds));

        try
        {
            var settings = new GoogleJsonWebSignature.ValidationSettings
            {
                Audience = _options.ClientIds,
            };

            var payload = await GoogleJsonWebSignature.ValidateAsync(idToken, settings);

            _logger.LogInformation(
                "[GoogleTokenValidator] Token OK. email={Email} sub={Sub} aud={Aud} iss={Iss}",
                payload.Email, payload.Subject, payload.Audience, payload.Issuer);

            if (string.IsNullOrWhiteSpace(payload.Email))
            {
                return null;
            }

            return new GoogleUserInfo(
                payload.Subject,
                payload.Email.Trim().ToLowerInvariant(),
                payload.Name);
        }
        catch (InvalidJwtException ex)
        {
            _logger.LogError(
                ex,
                "[GoogleTokenValidator] InvalidJwtException: {Reason}",
                ex.Message);
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "[GoogleTokenValidator] Exceção inesperada validando idToken.");
            return null;
        }
    }
}
