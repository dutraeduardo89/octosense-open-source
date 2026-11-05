namespace OctoSense.Domain.Readings;

/// <summary>
/// Persistence port for health readings.
/// </summary>
/// <remarks>
/// Infrastructure implements this. Domain does not know MongoDB.
/// </remarks>
public interface IHealthReadingRepository
{
    /// <summary>
    /// Persists a validated health reading.
    /// </summary>
    /// <param name="reading">Reading created by <see cref="HealthReading.Create"/>.</param>
    /// <param name="cancellationToken">Token used to cancel the write.</param>
    /// <returns>A task that completes when the insert finishes.</returns>
    /// <remarks>
    /// Implementations must not mutate domain invariants. Failures should throw and reach the global exception handler.
    /// </remarks>
    Task SaveAsync(HealthReading reading, CancellationToken cancellationToken = default);

    /// <summary>
    /// Persists a reading when its external identifier is new for the user.
    /// </summary>
    /// <param name="reading">Reading created by <see cref="HealthReading.Create"/>.</param>
    /// <param name="cancellationToken">Token used to cancel the write.</param>
    /// <returns><see langword="true"/> when inserted; <see langword="false"/> when the external id already exists.</returns>
    /// <remarks>
    /// Used by Google Health sync to skip duplicate DataPoints. Readings without <see cref="HealthReading.ExternalId"/> are always inserted.
    /// </remarks>
    Task<bool> SaveIfNewExternalIdAsync(HealthReading reading, CancellationToken cancellationToken = default);

    /// <summary>
    /// Lists readings for a user ordered by recorded time descending.
    /// </summary>
    /// <param name="userId">Owner of the readings.</param>
    /// <param name="cancellationToken">Token used to cancel the query.</param>
    /// <returns>Readings for the user; empty when none exist.</returns>
    /// <remarks>
    /// Used by <c>GET /readings</c> for the mobile dashboard.
    /// </remarks>
    Task<IReadOnlyList<HealthReading>> ListByUserIdAsync(
        string userId,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Lists readings for a user within a UTC date range, inclusive on the start, exclusive on the end.
    /// </summary>
    /// <param name="userId">Owner of the readings.</param>
    /// <param name="fromInclusive">Lower bound (UTC, inclusive) on RecordedAt.</param>
    /// <param name="toExclusive">Upper bound (UTC, exclusive) on RecordedAt.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Readings in range, or empty when none exist.</returns>
    /// <remarks>
    /// Used by daily summary aggregation. Bounds are half-open to keep day bucketing exact.
    /// </remarks>
    Task<IReadOnlyList<HealthReading>> ListByUserAndPeriodAsync(
        string userId,
        DateTimeOffset fromInclusive,
        DateTimeOffset toExclusive,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Deletes all readings owned by the user. Used when deleting the account.
    /// </summary>
    /// <returns>Number of documents removed.</returns>
    Task<long> DeleteAllForUserAsync(string userId, CancellationToken cancellationToken = default);
}