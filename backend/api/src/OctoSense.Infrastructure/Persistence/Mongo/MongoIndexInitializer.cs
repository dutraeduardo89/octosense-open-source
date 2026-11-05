using MongoDB.Bson;
using MongoDB.Driver;

namespace OctoSense.Infrastructure.Persistence.Mongo;

/// <summary>
/// Initializes Mongo indexes required by the application.
/// </summary>
public static class MongoIndexInitializer
{
    public static async Task EnsureIndexesAsync(
        MongoDbContext dbContext,
        CancellationToken cancellationToken = default
    )
    {
        await dbContext.HealthReadings.Indexes.CreateOneAsync(
            new CreateIndexModel<HealthReadingDocument>(
                Builders<HealthReadingDocument>
                    .IndexKeys.Ascending(item => item.UserId)
                    .Ascending(item => item.RecordedAt),
                new CreateIndexOptions { Name = "user_recorded_at_idx" }
            ),
            cancellationToken: cancellationToken
        );

        // Índice único SÓ quando ExternalId é uma string real.
        //
        // IMPORTANTE: NÃO usar Sparse=true. Em índice composto, sparse só
        // pula documentos onde TODOS os campos estão ausentes. Como UserId
        // está sempre presente, documents com ExternalId=null ainda entrariam
        // no índice, gerando E11000 no segundo insert.
        //
        // PartialFilterExpression precisa de CreateIndexOptions<TDocument>
        // (genérico). O CreateIndexOptions padrão não tem essa propriedade.
        await dbContext.HealthReadings.Indexes.CreateOneAsync(
            new CreateIndexModel<HealthReadingDocument>(
                Builders<HealthReadingDocument>
                    .IndexKeys.Ascending(item => item.UserId)
                    .Ascending(item => item.ExternalId),
                new CreateIndexOptions<HealthReadingDocument>
                {
                    Name = "user_external_id_idx",
                    Unique = true,
                    PartialFilterExpression = Builders<HealthReadingDocument>.Filter
                        .Type(item => item.ExternalId, BsonType.String),
                }
            ),
            cancellationToken: cancellationToken
        );

        await dbContext.GoogleHealthLinks.Indexes.CreateOneAsync(
            new CreateIndexModel<GoogleHealthLinkDocument>(
                Builders<GoogleHealthLinkDocument>.IndexKeys.Ascending(item => item.UserId),
                new CreateIndexOptions { Name = "user_id_idx", Unique = true }
            ),
            cancellationToken: cancellationToken
        );

        await dbContext.GoogleHealthSyncCursors.Indexes.CreateOneAsync(
            new CreateIndexModel<GoogleHealthSyncCursorDocument>(
                Builders<GoogleHealthSyncCursorDocument>
                    .IndexKeys.Ascending(item => item.UserId)
                    .Ascending(item => item.DataType),
                new CreateIndexOptions { Name = "user_datatype_idx", Unique = true }
            ),
            cancellationToken: cancellationToken
        );

        await dbContext.RefreshTokens.Indexes.CreateOneAsync(
            new CreateIndexModel<RefreshTokenDocument>(
                Builders<RefreshTokenDocument>.IndexKeys
                    .Ascending(item => item.UserId)
                    .Ascending(item => item.ExpiresAt),
                new CreateIndexOptions { Name = "user_expires_idx" }
            ),
            cancellationToken: cancellationToken
        );
    }
}
