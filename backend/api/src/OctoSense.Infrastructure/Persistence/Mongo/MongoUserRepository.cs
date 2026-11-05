using MongoDB.Driver;
using OctoSense.Domain.Auth;

namespace OctoSense.Infrastructure.Persistence.Mongo;

/// <summary>
/// Mongo adapter for IUserRepository.
/// </summary>
/// <param name="dbContext">Scoped Mongo context.</param>
public sealed class MongoUserRepository(MongoDbContext dbContext) : IUserRepository
{
    private readonly MongoDbContext _dbContext = dbContext;

    public async Task<User?> GetByEmailAsync(
        string email,
        CancellationToken cancellationToken = default)
    {
        var normalized = email.Trim().ToLowerInvariant();
        var document = await _dbContext.Users
            .Find(Builders<UserDocument>.Filter.Eq(item => item.Email, normalized))
            .FirstOrDefaultAsync(cancellationToken);

        return document is null ? null : ToDomain(document);
    }

    public async Task<User?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var document = await _dbContext.Users
            .Find(Builders<UserDocument>.Filter.Eq(item => item.Id, id))
            .FirstOrDefaultAsync(cancellationToken);

        return document is null ? null : ToDomain(document);
    }

    public async Task CreateAsync(User user, CancellationToken cancellationToken = default)
    {
        var document = new UserDocument
        {
            Id = user.Id,
            Email = user.Email.Trim().ToLowerInvariant(),
            DisplayName = user.DisplayName,
            CreatedAt = user.CreatedAt,
            LastLoginAt = user.LastLoginAt,
        };

        await _dbContext.Users.InsertOneAsync(document, cancellationToken: cancellationToken);
    }

    public async Task UpdateLastLoginAsync(
        Guid id,
        DateTimeOffset lastLoginAt,
        CancellationToken cancellationToken = default)
    {
        var update = Builders<UserDocument>.Update.Set(item => item.LastLoginAt, lastLoginAt);
        await _dbContext.Users.UpdateOneAsync(
            Builders<UserDocument>.Filter.Eq(item => item.Id, id),
            update,
            cancellationToken: cancellationToken);
    }

    public async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var result = await _dbContext.Users.DeleteOneAsync(
            Builders<UserDocument>.Filter.Eq(item => item.Id, id),
            cancellationToken);

        return result.DeletedCount > 0;
    }

    private static User ToDomain(UserDocument document) =>
        new(
            document.Id,
            document.Email,
            document.DisplayName,
            document.CreatedAt,
            document.LastLoginAt);
}
