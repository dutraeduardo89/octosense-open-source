namespace OctoSense.Domain.Auth;

/// <summary>
/// Repository port for user accounts.
/// </summary>
/// <remarks>
/// Infrastructure implements this. Domain does not know MongoDB.
/// </remarks>
public interface IUserRepository
{
    /// <summary>
    /// Gets a user by normalized email (lowercase, trimmed).
    /// </summary>
    Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken = default);

    /// <summary>
    /// Gets a user by internal id.
    /// </summary>
    Task<User?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);

    /// <summary>
    /// Inserts a new user. Caller must ensure email uniqueness beforehand.
    /// </summary>
    Task CreateAsync(User user, CancellationToken cancellationToken = default);

    /// <summary>
    /// Updates last login timestamp for an existing user.
    /// </summary>
    Task UpdateLastLoginAsync(
        Guid id,
        DateTimeOffset lastLoginAt,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Deletes the user by id. Returns true if a document was removed.
    /// </summary>
    Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken = default);
}
