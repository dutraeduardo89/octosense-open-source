using DotRMediator;
using OctoSense.Domain.Results;

namespace OctoSense.Application.Features.Auth.Commands.DeleteAccount;

/// <summary>
/// Deletes the authenticated user account and all associated data.
/// </summary>
/// <param name="Email">Email do usuário (claim do JWT).</param>
public sealed record DeleteAccountByEmailCommand(string Email) : IRequest<Result<Guid>>;
