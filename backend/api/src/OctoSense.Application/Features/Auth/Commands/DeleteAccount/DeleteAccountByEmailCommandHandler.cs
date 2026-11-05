using DotRMediator;
using OctoSense.Domain.Auth;
using OctoSense.Domain.Readings;
using OctoSense.Domain.Results;

namespace OctoSense.Application.Features.Auth.Commands.DeleteAccount;

/// <summary>
/// Apaga user + readings + refresh tokens em cascata.
/// </summary>
/// <remarks>
/// Idempotente: se o user não existe, retorna sucesso. Isso permite
/// que o cliente chame DELETE /auth/me múltiplas vezes sem erro.
/// </remarks>
public sealed class DeleteAccountByEmailCommandHandler(
    IUserRepository users,
    IHealthReadingRepository readings,
    IRefreshTokenRepository refreshTokens)
    : IRequestHandler<DeleteAccountByEmailCommand, Result<Guid>>
{
    private readonly IUserRepository _users = users;
    private readonly IHealthReadingRepository _readings = readings;
    private readonly IRefreshTokenRepository _refreshTokens = refreshTokens;

    public async Task<Result<Guid>> Handle(
        DeleteAccountByEmailCommand request,
        CancellationToken cancellationToken)
    {
        var user = await _users.GetByEmailAsync(request.Email, cancellationToken);

        // Idempotente: se não existe, considera deletado.
        if (user is null)
        {
            return Result<Guid>.Success(Guid.Empty);
        }

        // Readings usam o email como UserId.
        await _readings.DeleteAllForUserAsync(request.Email, cancellationToken);

        // Refresh tokens por Guid.
        await _refreshTokens.DeleteAllForUserAsync(user.Id, cancellationToken);

        // User em si.
        await _users.DeleteAsync(user.Id, cancellationToken);

        return Result<Guid>.Success(user.Id);
    }
}
