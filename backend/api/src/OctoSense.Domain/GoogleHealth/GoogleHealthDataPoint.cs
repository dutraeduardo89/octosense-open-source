namespace OctoSense.Domain.GoogleHealth;

/// <summary>
/// A health data point imported from Google Health API.
/// </summary>
/// <param name="Name">Google resource name used as ExternalId.</param>
/// <param name="DataType">Google data type id (e.g. steps, heart-rate).</param>
/// <param name="RecordedAt">Capture instant.</param>
/// <param name="DeviceId">Device or data-source identifier.</param>
/// <param name="DeviceSource">Vendor/platform label for OctoSense.</param>
/// <param name="HeartRateBpm">Optional heart rate.</param>
/// <param name="Steps">Optional steps.</param>
/// <param name="SleepDuration">Optional sleep duration.</param>
/// <param name="OxygenSaturationPercent">Optional SpO2.</param>
/// <param name="TotalCaloriesKcal">Optional calories.</param>
/// <remarks>
/// Mapped by Application into <c>HealthReading.Create</c>. Not a domain entity.
/// </remarks>
public sealed record GoogleHealthDataPoint(
    string Name,
    string DataType,
    DateTimeOffset RecordedAt,
    string DeviceId,
    string DeviceSource,
    double? HeartRateBpm = null,
    int? Steps = null,
    TimeSpan? SleepDuration = null,
    double? OxygenSaturationPercent = null,
    double? TotalCaloriesKcal = null);
