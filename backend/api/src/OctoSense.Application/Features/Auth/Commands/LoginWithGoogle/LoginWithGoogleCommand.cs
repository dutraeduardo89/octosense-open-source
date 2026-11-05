using DotRMediator;
using OctoSense.Domain.Auth;
using OctoSense.Domain.Results;

namespace OctoSense.Application.Features.Auth.Commands.LoginWithGoogle;

/// <summary>
/// Logs a user in with a Google ID token. Creates the user on first login.
/// </summary>
/// <param name="IdToken">Google ID token emitted by the mobile/web client.</param>
/// <param name="DisplayName">Optional display name override.</param>
public sealed record LoginWithGoogleCommand(
    string IdToken,
    string? DisplayName = null
) : IRequest<Result<AuthTokens>>;
