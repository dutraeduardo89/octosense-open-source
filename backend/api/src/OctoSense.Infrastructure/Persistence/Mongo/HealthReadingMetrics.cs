namespace OctoSense.Infrastructure.Persistence.Mongo;

/// <summary>
/// BSON subdocument for physiological metrics.
/// </summary>
/// <remarks>
/// Sparse: only populated fields are meaningful. Matches the rich-domain value object.
/// </remarks>
public sealed class HealthReadingMetrics
{
    /// <summary>
    /// Heart rate in beats per minute when present.
    /// </summary>
    public double? HeartRateBpm { get; set; }

    /// <summary>
    /// Step count when present.
    /// </summary>
    public int? Steps { get; set; }

    /// <summary>
    /// Sleep duration when present.
    /// </summary>
    public TimeSpan? SleepDuration { get; set; }

    /// <summary>
    /// Blood oxygen saturation percentage when present.
    /// </summary>
    public double? OxygenSaturationPercent { get; set; }

    /// <summary>
    /// Active calories in kilocalories when present (exercise only).
    /// </summary>
    public double? ActiveCaloriesKcal { get; set; }

    /// <summary>
    /// Total calories in kilocalories when present (active + basal).
    /// </summary>
    public double? TotalCaloriesKcal { get; set; }
}
