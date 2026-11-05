using DotRMediator;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OctoSense.Api.Extensions;
using OctoSense.Application.Features.Auth.Commands.DeleteAccount;
using OctoSense.Application.Features.Auth.Commands.LoginWithGoogle;
using OctoSense.Domain.Auth;

namespace OctoSense.Api.Controllers;

/// <summary>
/// HTTP adapter for authentication.
/// </summary>
/// <param name="sender">Mediator sender.</param>
[Route("auth")]
public sealed class AuthController(ISender sender) : BaseApiController(sender)
{
    /// <summary>
    /// Exchanges a Google ID token for OctoSense JWT tokens.
    /// </summary>
    /// <param name="request">Google ID token payload.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>200 with tokens, or 400 when token is invalid.</returns>
    [HttpPost("google")]
    [ProducesResponseType(typeof(AuthTokens), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IResult> LoginWithGoogleAsync(
        [FromBody] LoginWithGoogleRequest request,
        CancellationToken cancellationToken)
    {
        var result = await Sender.Send(
            new LoginWithGoogleCommand(request.IdToken, request.DisplayName),
            cancellationToken);

        return result.ToHttpResult(tokens => TypedResults.Ok(tokens));
    }

    /// <summary>
    /// Deletes the authenticated user account and all associated data.
    /// </summary>
    /// <remarks>
    /// Requer JWT. Apaga user + readings + refresh tokens. Irreversivel.
    /// </remarks>
    [HttpDelete("me")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IResult> DeleteMeAsync(CancellationToken cancellationToken)
    {
        var email = User.GetAuthenticatedEmail();
        if (string.IsNullOrWhiteSpace(email))
        {
            return Results.Unauthorized();
        }

        var result = await Sender.Send(
            new DeleteAccountByEmailCommand(email),
            cancellationToken);

        return result.ToHttpResult(_ => Results.NoContent());
    }
}

/// <summary>
/// Request payload for Google login.
/// </summary>
/// <param name="IdToken">Google ID token.</param>
/// <param name="DisplayName">Optional display name.</param>
public sealed record LoginWithGoogleRequest(string IdToken, string? DisplayName = null);
