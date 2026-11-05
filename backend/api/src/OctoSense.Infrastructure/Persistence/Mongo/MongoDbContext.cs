using MongoDB.Driver;

namespace OctoSense.Infrastructure.Persistence.Mongo;

/// <summary>
/// Thin wrapper over <see cref="IMongoDatabase"/> for typed collections.
/// </summary>
/// <remarks>
/// Not a unit of work. Holds the database reference and collection names only.
/// </remarks>
public sealed class MongoDbContext
{
    /// <summary>
    /// Mongo database resolved from the singleton client.
    /// </summary>
    /// <remarks>
    /// Scoped per request so tests can isolate databases by name.
    /// </remarks>
    private readonly IMongoDatabase _database;

    /// <summary>
    /// Creates a context for a named database.
    /// </summary>
    /// <param name="client">Thread-safe Mongo client (singleton).</param>
    /// <param name="databaseName">Database name, typically <c>octosense</c> or a test Guid.</param>
    /// <remarks>
    /// Does not open extra connections beyond the client's pool.
    /// </remarks>
    public MongoDbContext(IMongoClient client, string databaseName)
    {
        _database = client.GetDatabase(databaseName);
    }

    /// <summary>
    /// Typed collection for health readings.
    /// </summary>
    /// <remarks>
    /// Collection name is <c>health_readings</c>.
    /// </remarks>
    public IMongoCollection<HealthReadingDocument> HealthReadings
        => _database.GetCollection<HealthReadingDocument>("health_readings");

    /// <summary>
    /// Typed collection for Google Health account links.
    /// </summary>
    /// <remarks>
    /// Collection name is <c>google_health_links</c>.
    /// </remarks>
    public IMongoCollection<GoogleHealthLinkDocument> GoogleHealthLinks
        => _database.GetCollection<GoogleHealthLinkDocument>("google_health_links");

    /// <summary>
    /// Typed collection for Google Health sync cursors.
    /// </summary>
    /// <remarks>
    /// Collection name is <c>google_health_sync_cursors</c>.
    /// </remarks>
    public IMongoCollection<GoogleHealthSyncCursorDocument> GoogleHealthSyncCursors
        => _database.GetCollection<GoogleHealthSyncCursorDocument>("google_health_sync_cursors");

    /// <summary>
    /// Typed collection for user accounts.
    /// </summary>
    /// <remarks>
    /// Collection name is <c>users</c>. Email has a unique index.
    /// </remarks>
    public IMongoCollection<UserDocument> Users
        => _database.GetCollection<UserDocument>("users");

    /// <summary>
    /// Typed collection for refresh tokens.
    /// </summary>
    /// <remarks>
    /// Collection name is <c>refresh_tokens</c>.
    /// </remarks>
    public IMongoCollection<RefreshTokenDocument> RefreshTokens
        => _database.GetCollection<RefreshTokenDocument>("refresh_tokens");
}
