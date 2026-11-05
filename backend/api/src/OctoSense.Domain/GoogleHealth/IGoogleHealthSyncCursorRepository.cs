namespace OctoSense.Domain.GoogleHealth;

/// <summary>
/// Repository port for Google Health sync cursors.
/// </summary>
public interface IGoogleHealthSyncCursorRepository
{
    Task<GoogleHealthSyncCursor?> GetAsync(
        string userId,
        string dataType,
        CancellationToken cancellationToken = default
    );
    Task UpsertAsync(GoogleHealthSyncCursor cursor, CancellationToken cancellationToken = default);
}
