using MongoDB.Bson;
using MongoDB.Driver;
using OctoSense.Domain.Readings;
using DomainHealthReading = OctoSense.Domain.Readings.HealthReading;

namespace OctoSense.Infrastructure.Persistence.Mongo;

/// <summary>
/// MongoDB adapter for <see cref="IHealthReadingRepository"/>.
/// </summary>
/// <param name="dbContext">Scoped Mongo context exposing the readings collection.</param>
/// <remarks>
/// Mapeia a leitura rica do domínio 1:1 para <see cref="HealthReadingDocument"/>.
/// Leituras com ExternalId sao upsert (idempotente). Sem ExternalId, insert normal.
/// </remarks>
public sealed class MongoHealthReadingRepository(MongoDbContext dbContext) : IHealthReadingRepository
{
    private readonly MongoDbContext _dbContext = dbContext;

    /// <inheritdoc />
    public async Task SaveAsync(
        DomainHealthReading reading,
        CancellationToken cancellationToken = default)
    {
        var document = ToDocument(reading);

        // Upsert idempotente quando ha ExternalId (ex: sync do HC).
        // Syncs subsequentes do mesmo periodo atualizam o doc em vez de
        // inserir copias — resolve o bug do Trends inflando.
        //
        // IMPORTANTE: usamos UpdateOne com $set em vez de ReplaceOne.
        // ReplaceOne gera erro 66 ("immutable field '_id' was altered")
        // quando 2 requests concorrentes tentam upsert do mesmo doc:
        // o Find nao acha, ambos mandam ReplaceOne, o segundo ve _id
        // diferente do primeiro e o Mongo rejeita. UpdateOne com $set
        // preserva o _id automaticamente e e idempotente sob concorrencia.
        if (!string.IsNullOrWhiteSpace(reading.ExternalId))
        {
            var filter = Builders<HealthReadingDocument>.Filter.And(
                Builders<HealthReadingDocument>.Filter.Eq(x => x.UserId, reading.UserId),
                Builders<HealthReadingDocument>.Filter.Eq(x => x.ExternalId, reading.ExternalId)
            );

            var update = Builders<HealthReadingDocument>.Update
                .SetOnInsert(x => x.Id, ObjectId.GenerateNewId().ToString())
                .Set(x => x.UserId, document.UserId)
                .Set(x => x.DeviceId, document.DeviceId)
                .Set(x => x.DeviceSource, document.DeviceSource)
                .Set(x => x.RecordedAt, document.RecordedAt)
                .Set(x => x.ExternalId, document.ExternalId)
                .Set(x => x.Metrics, document.Metrics)
                .Set(x => x.Metadata, document.Metadata);

            await _dbContext.HealthReadings.UpdateOneAsync(
                filter,
                update,
                new UpdateOptions { IsUpsert = true },
                cancellationToken);
            return;
        }

        await _dbContext.HealthReadings.InsertOneAsync(
            document,
            cancellationToken: cancellationToken);
    }

    /// <inheritdoc />
    public async Task<bool> SaveIfNewExternalIdAsync(
        DomainHealthReading reading,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(reading.ExternalId))
        {
            await SaveAsync(reading, cancellationToken);
            return true;
        }

        var filter = Builders<HealthReadingDocument>.Filter.And(
            Builders<HealthReadingDocument>.Filter.Eq(x => x.UserId, reading.UserId),
            Builders<HealthReadingDocument>.Filter.Eq(x => x.ExternalId, reading.ExternalId)
        );

        var existing = await _dbContext.HealthReadings
            .Find(filter)
            .Limit(1)
            .AnyAsync(cancellationToken);

        await SaveAsync(reading, cancellationToken);
        return !existing;
    }

    /// <inheritdoc />
    public async Task<IReadOnlyList<DomainHealthReading>> ListByUserIdAsync(
        string userId,
        CancellationToken cancellationToken = default)
    {
        var filter = Builders<HealthReadingDocument>.Filter.Eq(x => x.UserId, userId);
        var sort = Builders<HealthReadingDocument>.Sort.Descending(x => x.RecordedAt);

        var documents = await _dbContext.HealthReadings
            .Find(filter)
            .Sort(sort)
            .ToListAsync(cancellationToken);

        return documents.Select(ToDomain).ToList();
    }

    /// <inheritdoc />
    public async Task<IReadOnlyList<DomainHealthReading>> ListByUserAndPeriodAsync(
        string userId,
        DateTimeOffset fromInclusive,
        DateTimeOffset toExclusive,
        CancellationToken cancellationToken = default)
    {
        var filter = Builders<HealthReadingDocument>.Filter.And(
            Builders<HealthReadingDocument>.Filter.Eq(x => x.UserId, userId),
            Builders<HealthReadingDocument>.Filter.Gte(x => x.RecordedAt, fromInclusive),
            Builders<HealthReadingDocument>.Filter.Lt(x => x.RecordedAt, toExclusive)
        );

        var sort = Builders<HealthReadingDocument>.Sort.Descending(x => x.RecordedAt);

        var documents = await _dbContext.HealthReadings
            .Find(filter)
            .Sort(sort)
            .ToListAsync(cancellationToken);

        return documents.Select(ToDomain).ToList();
    }

    /// <inheritdoc />
    public async Task<long> DeleteAllForUserAsync(
        string userId,
        CancellationToken cancellationToken = default)
    {
        var result = await _dbContext.HealthReadings.DeleteManyAsync(
            Builders<HealthReadingDocument>.Filter.Eq(x => x.UserId, userId),
            cancellationToken);

        return result.DeletedCount;
    }

    /// <summary>
    /// Mapeia entidade de dominio -> documento BSON.
    /// </summary>
    private static HealthReadingDocument ToDocument(DomainHealthReading reading) =>
        new()
        {
            Id = ObjectId.GenerateNewId().ToString(),
            UserId = reading.UserId,
            DeviceId = reading.DeviceId,
            DeviceSource = reading.DeviceSource,
            RecordedAt = reading.RecordedAt,
            ExternalId = reading.ExternalId,
            Metrics = new HealthReadingMetrics
            {
                HeartRateBpm = reading.Metrics.HeartRateBpm,
                Steps = reading.Metrics.Steps,
                SleepDuration = reading.Metrics.SleepDuration,
                OxygenSaturationPercent = reading.Metrics.OxygenSaturationPercent,
                ActiveCaloriesKcal = reading.Metrics.ActiveCaloriesKcal,
                TotalCaloriesKcal = reading.Metrics.TotalCaloriesKcal
            },
            Metadata = reading.Metadata is null
                ? null
                : new HealthReadingMetadata
                {
                    SyncMode = reading.Metadata.SyncMode,
                    BatteryLevel = reading.Metadata.BatteryLevel
                }
        };

    /// <summary>
    /// Mapeia documento BSON -> entidade de dominio.
    /// </summary>
    /// <remarks>
    /// HealthReading nao tem construtor publico. Criamos via factory e
    /// assumimos sucesso porque os dados vem do nosso proprio banco.
    /// </remarks>
    private static DomainHealthReading ToDomain(HealthReadingDocument doc)
    {
        var result = DomainHealthReading.Create(
            userId: doc.UserId,
            deviceId: doc.DeviceId,
            deviceSource: doc.DeviceSource,
            recordedAt: doc.RecordedAt,
            heartRateBpm: doc.Metrics?.HeartRateBpm,
            steps: doc.Metrics?.Steps,
            sleepDuration: doc.Metrics?.SleepDuration,
            oxygenSaturationPercent: doc.Metrics?.OxygenSaturationPercent,
            activeCaloriesKcal: doc.Metrics?.ActiveCaloriesKcal,
            totalCaloriesKcal: doc.Metrics?.TotalCaloriesKcal,
            syncMode: doc.Metadata?.SyncMode,
            batteryLevel: doc.Metadata?.BatteryLevel,
            externalId: doc.ExternalId);

        // Dados vem do Mongo controlado por nos; se invalido, e bug de escrita.
        return result.Value!;
    }
}
