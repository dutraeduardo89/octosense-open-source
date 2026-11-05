namespace OctoSense.Domain.GoogleHealth;

/// <summary>
/// Sync cursor for one user and Google data type.
/// </summary>
/// <param name="UserId">OctoSense user id.</param>
/// <param name="DataType">Google data type id.</param>
/// <param name="LastSyncedAt">Upper bound already imported.</param>
/// <remarks>
/// Advanced after a successful sync window.
/// </remarks>
public sealed record GoogleHealthSyncCursor(
    string UserId,
    string DataType,
    DateTimeOffset LastSyncedAt);
