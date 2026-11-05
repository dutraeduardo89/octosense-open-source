using MongoDB.Driver;
using OctoSense.Domain.GoogleHealth;

namespace OctoSense.Infrastructure.Persistence.Mongo;

/// <summary>
/// Mongo adapter for Google Health sync cursor storage.
/// </summary>
public sealed class MongoGoogleHealthSyncCursorRepository(MongoDbContext dbContext)
    : IGoogleHealthSyncCursorRepository
{
    private readonly MongoDbContext _dbContext = dbContext;

    public async Task<GoogleHealthSyncCursor?> GetAsync(
        string userId,
        string dataType,
        CancellationToken cancellationToken = default
    )
    {
        var document = await _dbContext
            .GoogleHealthSyncCursors.Find(
                Builders<GoogleHealthSyncCursorDocument>.Filter.And(
                    Builders<GoogleHealthSyncCursorDocument>.Filter.Eq(item => item.UserId, userId),
                    Builders<GoogleHealthSyncCursorDocument>.Filter.Eq(
                        item => item.DataType,
                        dataType
                    )
                )
            )
            .FirstOrDefaultAsync(cancellationToken);

        return document is null
            ? null
            : new GoogleHealthSyncCursor(document.UserId, document.DataType, document.LastSyncedAt);
    }

    public async Task UpsertAsync(
        GoogleHealthSyncCursor cursor,
        CancellationToken cancellationToken = default
    )
    {
        var filter = Builders<GoogleHealthSyncCursorDocument>.Filter.And(
            Builders<GoogleHealthSyncCursorDocument>.Filter.Eq(item => item.UserId, cursor.UserId),
            Builders<GoogleHealthSyncCursorDocument>.Filter.Eq(
                item => item.DataType,
                cursor.DataType
            )
        );

        var update = Builders<GoogleHealthSyncCursorDocument>
            .Update.Set(item => item.UserId, cursor.UserId)
            .Set(item => item.DataType, cursor.DataType)
            .Set(item => item.LastSyncedAt, cursor.LastSyncedAt);

        await _dbContext.GoogleHealthSyncCursors.UpdateOneAsync(
            filter,
            update,
            new UpdateOptions { IsUpsert = true },
            cancellationToken
        );
    }
}
