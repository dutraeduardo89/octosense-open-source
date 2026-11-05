using MongoDB.Driver;
using OctoSense.Domain.GoogleHealth;

namespace OctoSense.Infrastructure.Persistence.Mongo;

/// <summary>
/// Mongo adapter for <see cref="IGoogleHealthLinkRepository"/>.
/// </summary>
/// <param name="dbContext">Scoped Mongo context.</param>
/// <remarks>
/// Upserts by <c>userId</c>. Never logs refresh tokens.
/// </remarks>
public sealed class MongoGoogleHealthLinkRepository(MongoDbContext dbContext) : IGoogleHealthLinkRepository
{
    private readonly MongoDbContext _dbContext = dbContext;

    /// <inheritdoc />
    public async Task UpsertAsync(GoogleHealthLink link, CancellationToken cancellationToken = default)
    {
        var filter = Builders<GoogleHealthLinkDocument>.Filter.Eq(document => document.UserId, link.UserId);
        var update = Builders<GoogleHealthLinkDocument>.Update
            .Set(document => document.UserId, link.UserId)
            .Set(document => document.RefreshToken, link.RefreshToken)
            .Set(document => document.AccessToken, link.AccessToken)
            .Set(document => document.AccessTokenExpiresAt, link.AccessTokenExpiresAt)
            .Set(document => document.LinkedAt, link.LinkedAt);

        await _dbContext.GoogleHealthLinks.UpdateOneAsync(
            filter,
            update,
            new UpdateOptions { IsUpsert = true },
            cancellationToken);
    }

    /// <inheritdoc />
    public async Task<GoogleHealthLink?> GetByUserIdAsync(
        string userId,
        CancellationToken cancellationToken = default)
    {
        var document = await _dbContext.GoogleHealthLinks
            .Find(Builders<GoogleHealthLinkDocument>.Filter.Eq(item => item.UserId, userId))
            .FirstOrDefaultAsync(cancellationToken);

        return document is null ? null : ToDomain(document);
    }

    /// <inheritdoc />
    public async Task<IReadOnlyList<GoogleHealthLink>> ListAllAsync(
        CancellationToken cancellationToken = default)
    {
        var documents = await _dbContext.GoogleHealthLinks
            .Find(FilterDefinition<GoogleHealthLinkDocument>.Empty)
            .ToListAsync(cancellationToken);

        return documents.Select(ToDomain).ToList();
    }

    /// <inheritdoc />
    public async Task<GoogleHealthLink?> GetMostRecentlyLinkedAsync(
        CancellationToken cancellationToken = default)
    {
        var document = await _dbContext.GoogleHealthLinks
            .Find(FilterDefinition<GoogleHealthLinkDocument>.Empty)
            .SortByDescending(item => item.LinkedAt)
            .FirstOrDefaultAsync(cancellationToken);

        return document is null ? null : ToDomain(document);
    }

    /// <inheritdoc />
    public async Task<bool> DeleteAsync(string userId, CancellationToken cancellationToken = default)
    {
        var result = await _dbContext.GoogleHealthLinks.DeleteOneAsync(
            Builders<GoogleHealthLinkDocument>.Filter.Eq(document => document.UserId, userId),
            cancellationToken);

        return result.DeletedCount > 0;
    }

    private static GoogleHealthLink ToDomain(GoogleHealthLinkDocument document) =>
        new(
            document.UserId,
            document.RefreshToken,
            document.AccessToken,
            document.AccessTokenExpiresAt,
            document.LinkedAt);
}
