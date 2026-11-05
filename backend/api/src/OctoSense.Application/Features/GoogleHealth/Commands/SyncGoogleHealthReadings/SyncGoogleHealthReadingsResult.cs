namespace OctoSense.Application.Features.GoogleHealth.Commands.SyncGoogleHealthReadings;

/// <summary>
/// Outcome of a Google Health sync for one user.
/// </summary>
/// <param name="ImportedCount">Number of newly persisted readings.</param>
/// <param name="SkippedCount">Number of data points skipped as duplicates.</param>
/// <remarks>
/// Used for logging and tests; not returned to end users.
/// </remarks>
public sealed record SyncGoogleHealthReadingsResult(int ImportedCount, int SkippedCount);
