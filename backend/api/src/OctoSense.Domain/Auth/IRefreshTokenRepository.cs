namespace OctoSense.Domain.Auth;

/// <summary>
/// Repository port for refresh tokens.
/// </summary>
public interface IRefreshTokenRepository
{
    Task SaveAsync(RefreshToken token, CancellationToken cancellationToken = default);
    Task<RefreshToken?> GetByTokenAsync(string token, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(string token, CancellationToken cancellationToken = default);
    Task<int> DeleteAllForUserAsync(Guid userId, CancellationToken cancellationToken = default);
}
