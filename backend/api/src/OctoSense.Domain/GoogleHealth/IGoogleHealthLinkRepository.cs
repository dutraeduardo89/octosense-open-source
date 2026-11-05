namespace OctoSense.Domain.GoogleHealth;

/// <summary>
/// Repository port for Google Health account links.
/// </summary>
public interface IGoogleHealthLinkRepository
{
    Task UpsertAsync(GoogleHealthLink link, CancellationToken cancellationToken = default);
    Task<GoogleHealthLink?> GetByUserIdAsync(
        string userId,
        CancellationToken cancellationToken = default
    );
    Task<IReadOnlyList<GoogleHealthLink>> ListAllAsync(
        CancellationToken cancellationToken = default
    );
    Task<GoogleHealthLink?> GetMostRecentlyLinkedAsync(
        CancellationToken cancellationToken = default
    );
    Task<bool> DeleteAsync(string userId, CancellationToken cancellationToken = default);
}
