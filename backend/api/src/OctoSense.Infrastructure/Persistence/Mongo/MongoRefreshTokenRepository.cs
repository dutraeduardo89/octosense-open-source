using MongoDB.Driver;
using OctoSense.Domain.Auth;

namespace OctoSense.Infrastructure.Persistence.Mongo;

/// <summary>
/// Mongo adapter for IRefreshTokenRepository.
/// </summary>
public sealed class MongoRefreshTokenRepository(MongoDbContext dbContext) : IRefreshTokenRepository
{
    private readonly MongoDbContext _dbContext = dbContext;

    public async Task SaveAsync(RefreshToken token, CancellationToken cancellationToken = default)
    {
        var document = new RefreshTokenDocument
        {
            Token = token.Token,
            UserId = token.UserId,
            CreatedAt = token.CreatedAt,
            ExpiresAt = token.ExpiresAt,
        };

        await _dbContext.RefreshTokens.InsertOneAsync(document, cancellationToken: cancellationToken);
    }

    public async Task<RefreshToken?> GetByTokenAsync(
        string token,
        CancellationToken cancellationToken = default)
    {
        var document = await _dbContext.RefreshTokens
            .Find(Builders<RefreshTokenDocument>.Filter.Eq(d => d.Token, token))
            .FirstOrDefaultAsync(cancellationToken);

        return document is null ? null : ToDomain(document);
    }

    public async Task<bool> DeleteAsync(string token, CancellationToken cancellationToken = default)
    {
        var result = await _dbContext.RefreshTokens.DeleteOneAsync(
            Builders<RefreshTokenDocument>.Filter.Eq(d => d.Token, token),
            cancellationToken);

        return result.DeletedCount > 0;
    }

    public async Task<int> DeleteAllForUserAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var result = await _dbContext.RefreshTokens.DeleteManyAsync(
            Builders<RefreshTokenDocument>.Filter.Eq(d => d.UserId, userId),
            cancellationToken);

        return (int)result.DeletedCount;
    }

    private static RefreshToken ToDomain(RefreshTokenDocument document) =>
        new(document.Token, document.UserId, document.CreatedAt, document.ExpiresAt);
}
