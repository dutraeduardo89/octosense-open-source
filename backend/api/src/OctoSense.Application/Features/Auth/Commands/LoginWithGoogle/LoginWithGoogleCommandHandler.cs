using DotRMediator;
using OctoSense.Domain.Auth;
using OctoSense.Domain.Results;

namespace OctoSense.Application.Features.Auth.Commands.LoginWithGoogle;

/// <summary>
/// Handles LoginWithGoogleCommand: validates the Google token, upserts the user, issues OctoSense tokens.
/// </summary>
/// <param name="googleValidator">Google ID token validator.</param>
/// <param name="users">User repository.</param>
/// <param name="tokens">JWT issuer.</param>
public sealed class LoginWithGoogleCommandHandler(
    IGoogleTokenValidator googleValidator,
    IUserRepository users,
    IJwtTokenService tokens)
    : IRequestHandler<LoginWithGoogleCommand, Result<AuthTokens>>
{
    private readonly IGoogleTokenValidator _googleValidator = googleValidator;
    private readonly IUserRepository _users = users;
    private readonly IJwtTokenService _tokens = tokens;

    public async Task<Result<AuthTokens>> Handle(
        LoginWithGoogleCommand request,
        CancellationToken cancellationToken)
    {
        var info = await _googleValidator.ValidateAsync(request.IdToken, cancellationToken);
        if (info is null)
        {
            return Result<AuthTokens>.Failure(
                Error.Validation(nameof(request.IdToken), "Google token is invalid or expired."));
        }

        var now = DateTimeOffset.UtcNow;

        var user = await _users.GetByEmailAsync(info.Email, cancellationToken);

        if (user is null)
        {
            user = new User(
                Guid.NewGuid(),
                info.Email,
                request.DisplayName ?? info.DisplayName,
                now,
                now);

            await _users.CreateAsync(user, cancellationToken);
        }
        else
        {
            await _users.UpdateLastLoginAsync(user.Id, now, cancellationToken);
            user = user with { LastLoginAt = now };
        }

        var authTokens = await _tokens.IssueAsync(user, cancellationToken);
        return Result<AuthTokens>.Success(authTokens);
    }
}
