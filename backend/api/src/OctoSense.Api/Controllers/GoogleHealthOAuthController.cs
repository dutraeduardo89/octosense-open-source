using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using OctoSense.Domain.GoogleHealth;
using OctoSense.Infrastructure.GoogleHealth;

namespace OctoSense.Api.Controllers;

/// <summary>
/// OAuth endpoints that link the Google account used in the mobile app.
/// </summary>
/// <param name="googleHealthClient">Google OAuth/client port.</param>
/// <param name="linkRepository">Persists refresh tokens keyed by Google email.</param>
/// <param name="options">Google Health configuration.</param>
/// <remarks>
/// The app opens Google consent; this API only exchanges the code and stores tokens. Does not log tokens.
/// </remarks>
[Route("auth/google/health")]
[ApiController]
public sealed class GoogleHealthOAuthController(
    IGoogleHealthClient googleHealthClient,
    IGoogleHealthLinkRepository linkRepository,
    IOptions<GoogleHealthOptions> options) : ControllerBase
{
    private readonly IGoogleHealthClient _googleHealthClient = googleHealthClient;
    private readonly IGoogleHealthLinkRepository _linkRepository = linkRepository;
    private readonly GoogleHealthOptions _options = options.Value;

    /// <summary>
    /// Returns the Google authorization URL for the mobile app to open.
    /// </summary>
    /// <returns>JSON with <c>authorizationUrl</c>, or 400 when ClientId is missing.</returns>
    /// <remarks>
    /// Does not redirect the browser to Google. The Flutter client launches the URL.
    /// </remarks>
    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public IActionResult Start()
    {
        if (string.IsNullOrWhiteSpace(_options.ClientId))
        {
            return BadRequest(new { error = "GoogleHealth ClientId is not configured." });
        }

        return Ok(new { authorizationUrl = _googleHealthClient.BuildAuthorizationUrl() });
    }

    /// <summary>
    /// Returns the most recently linked Google account.
    /// </summary>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>200 with user id (email), or 404 when nobody is linked.</returns>
    /// <remarks>
    /// Educational single-user helper so the app can store the Google email after consent.
    /// </remarks>
    [HttpGet("active")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Active(CancellationToken cancellationToken)
    {
        var link = await _linkRepository.GetMostRecentlyLinkedAsync(cancellationToken);
        if (link is null)
        {
            return NotFound();
        }

        return Ok(new { userId = link.UserId, linked = true });
    }

    /// <summary>
    /// OAuth callback that exchanges the code, reads the Google email, and stores the refresh token.
    /// </summary>
    /// <param name="code">Authorization code from Google.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>HTML that opens the OctoSense app, or 400 on failure.</returns>
    /// <remarks>
    /// Refresh tokens are never written to logs. The OctoSense user id is the Google email.
    /// The page immediately hands control back to the app via <c>octosense://oauth/linked</c>.
    /// </remarks>
    [HttpGet("callback")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Callback(
        [FromQuery] string? code,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(code))
        {
            return BadRequest(new { error = "code is required." });
        }

        try
        {
            var tokens = await _googleHealthClient.ExchangeCodeAsync(code, cancellationToken);
            if (string.IsNullOrWhiteSpace(tokens.RefreshToken))
            {
                return BadRequest(new { error = "Google did not return a refresh token. Re-consent with prompt=consent." });
            }

            var profile = await _googleHealthClient.GetUserProfileAsync(tokens.AccessToken, cancellationToken);
            await _linkRepository.UpsertAsync(
                new GoogleHealthLink(
                    profile.Email,
                    tokens.RefreshToken,
                    tokens.AccessToken,
                    DateTimeOffset.UtcNow.AddSeconds(tokens.ExpiresIn),
                    DateTimeOffset.UtcNow),
                cancellationToken);

            return LinkedAppHtml(profile.Email);
        }
        catch
        {
            return BadRequest(new { error = "Failed to exchange Google authorization code." });
        }
    }

    /// <summary>
    /// Removes the Google Health link for a user and stops sync.
    /// </summary>
    /// <param name="userId">OctoSense user id (Google email).</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>204 when deleted, 404 when absent.</returns>
    /// <remarks>
    /// Satisfies the exclusion requirement for real health data.
    /// </remarks>
    [HttpDelete("{userId}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Unlink(string userId, CancellationToken cancellationToken)
    {
        var deleted = await _linkRepository.DeleteAsync(userId, cancellationToken);
        return deleted ? NoContent() : NotFound();
    }

    /// <summary>
    /// Builds the HTML bounce page that returns Chrome to the OctoSense app.
    /// </summary>
    /// <param name="email">Linked Google account email.</param>
    /// <returns>HTML content with a custom-scheme and Android intent fallback.</returns>
    /// <remarks>
    /// Chrome often blocks a silent custom-scheme navigation; the visible button covers that case.
    /// </remarks>
    private static ContentResult LinkedAppHtml(string email)
    {
        const string appLink = "octosense://oauth/linked";
        const string intentLink =
            "intent://oauth/linked#Intent;scheme=octosense;package=com.dutraeduardo.octosense;end";
        var safeEmail = System.Net.WebUtility.HtmlEncode(email);
        var intentJson = System.Text.Json.JsonSerializer.Serialize(intentLink);
        var appJson = System.Text.Json.JsonSerializer.Serialize(appLink);
        var html =
            "<!DOCTYPE html><html lang=\"pt-BR\"><head><meta charset=\"utf-8\">"
            + "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
            + $"<meta http-equiv=\"refresh\" content=\"0;url={appLink}\">"
            + "<title>OctoSense</title></head>"
            + "<body style=\"font-family:sans-serif;padding:2rem;max-width:32rem\">"
            + "<h1>Conta vinculada</h1>"
            + $"<p>Abrindo o OctoSense para <strong>{safeEmail}</strong>…</p>"
            + $"<p><a id=\"open-app\" href=\"{intentLink}\" "
            + "style=\"display:inline-block;padding:0.9rem 1.25rem;background:#1a73e8;color:#fff;"
            + "text-decoration:none;border-radius:8px;font-weight:600\">Abrir OctoSense</a></p>"
            + "<script>(function(){var open=document.getElementById('open-app');"
            + "if(open){open.click();}"
            + $"setTimeout(function(){{window.location.replace({intentJson});}},200);"
            + $"setTimeout(function(){{window.location.replace({appJson});}},700);"
            + "})();</script></body></html>";

        return new ContentResult
        {
            Content = html,
            ContentType = "text/html",
            StatusCode = StatusCodes.Status200OK
        };
    }
}
