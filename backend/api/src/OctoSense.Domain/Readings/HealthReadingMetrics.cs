using OctoSense.Domain.Results;

namespace OctoSense.Domain.Readings;

/// <summary>
/// Physiological metrics captured in a health reading.
/// </summary>
/// <remarks>
/// Sparse value object. At least one metric must be present. Each supplied metric has its own invariant.
/// </remarks>
public sealed class HealthReadingMetrics
{
    /// <summary>
    /// Initializes metrics that already passed invariants.
    /// </summary>
    /// <param name="heartRateBpm">Optional heart rate in beats per minute.</param>
    /// <param name="steps">Optional step count.</param>
    /// <param name="sleepDuration">Optional sleep duration.</param>
    /// <param name="oxygenSaturationPercent">Optional blood oxygen percentage.</param>
    /// <param name="totalCaloriesKcal">Optional total calories in kilocalories.</param>
    /// <remarks>
    /// Callers must use <see cref="Create"/>. Direct construction is reserved for a valid state.
    /// </remarks>
    public HealthReadingMetrics()
    {
    }

    private HealthReadingMetrics(
        double? heartRateBpm,
        int? steps,
        TimeSpan? sleepDuration,
        double? oxygenSaturationPercent,
        double? activeCaloriesKcal,
        double? totalCaloriesKcal)
    {
        HeartRateBpm = heartRateBpm;
        Steps = steps;
        SleepDuration = sleepDuration;
        OxygenSaturationPercent = oxygenSaturationPercent;
        ActiveCaloriesKcal = activeCaloriesKcal;
        TotalCaloriesKcal = totalCaloriesKcal;
    }

    /// <summary>
    /// Heart rate in beats per minute when supplied.
    /// </summary>
    /// <remarks>
    /// Greater than zero when present.
    /// </remarks>
    public double? HeartRateBpm { get; set; }

    /// <summary>
    /// Step count when supplied.
    /// </summary>
    /// <remarks>
    /// Greater than or equal to zero when present.
    /// </remarks>
    public int? Steps { get; set; }

    /// <summary>
    /// Sleep duration when supplied.
    /// </summary>
    /// <remarks>
    /// Greater than zero when present.
    /// </remarks>
    public TimeSpan? SleepDuration { get; set; }

    /// <summary>
    /// Blood oxygen saturation percentage when supplied.
    /// </summary>
    /// <remarks>
    /// Inclusive range 0–100 when present.
    /// </remarks>
    public double? OxygenSaturationPercent { get; set; }

    /// <summary>
    /// Active calories in kilocalories when supplied (exercise only).
    /// </summary>
    /// <remarks>
    /// Greater than or equal to zero when present.
    /// </remarks>
    public double? ActiveCaloriesKcal { get; set; }

    /// <summary>
    /// Total calories in kilocalories when supplied (active + basal metabolism).
    /// </summary>
    /// <remarks>
    /// Greater than or equal to zero when present.
    /// </remarks>
    public double? TotalCaloriesKcal { get; set; }

    /// <summary>
    /// Creates sparse metrics when at least one value is present and each value satisfies invariants.
    /// </summary>
    /// <param name="heartRateBpm">Optional heart rate. When present, must be greater than zero.</param>
    /// <param name="steps">Optional steps. When present, must be greater than or equal to zero.</param>
    /// <param name="sleepDuration">Optional sleep duration. When present, must be greater than zero.</param>
    /// <param name="oxygenSaturationPercent">Optional SpO2. When present, must be 0–100.</param>
    /// <param name="totalCaloriesKcal">Optional calories. When present, must be greater than or equal to zero.</param>
    /// <returns>Success with metrics, or aggregated validation errors.</returns>
    /// <remarks>
    /// Application must not construct metrics by skipping this factory.
    /// </remarks>
    public static Result<HealthReadingMetrics> Create(
        double? heartRateBpm = null,
        int? steps = null,
        TimeSpan? sleepDuration = null,
        double? oxygenSaturationPercent = null,
        double? activeCaloriesKcal = null,
        double? totalCaloriesKcal = null)
    {
        var errors = new List<Error>();

        if (heartRateBpm is null
            && steps is null
            && sleepDuration is null
            && oxygenSaturationPercent is null
            && activeCaloriesKcal is null
            && totalCaloriesKcal is null)
        {
            errors.Add(Error.Validation(nameof(HealthReadingMetrics), "At least one metric is required."));
        }

        if (heartRateBpm is <= 0)
        {
            errors.Add(Error.Validation(nameof(HeartRateBpm), "HeartRateBpm must be greater than 0."));
        }

        if (steps is < 0)
        {
            errors.Add(Error.Validation(nameof(Steps), "Steps must be greater than or equal to 0."));
        }

        if (sleepDuration is { } sleep && sleep <= TimeSpan.Zero)
        {
            errors.Add(Error.Validation(nameof(SleepDuration), "SleepDuration must be greater than zero."));
        }

        if (oxygenSaturationPercent is { } spo2 && (spo2 < 0 || spo2 > 100))
        {
            errors.Add(Error.Validation(
                nameof(OxygenSaturationPercent),
                "OxygenSaturationPercent must be between 0 and 100."));
        }

        if (activeCaloriesKcal is < 0)
        {
            errors.Add(Error.Validation(
                nameof(ActiveCaloriesKcal),
                "ActiveCaloriesKcal must be greater than or equal to 0."));
        }

        if (totalCaloriesKcal is < 0)
        {
            errors.Add(Error.Validation(
                nameof(TotalCaloriesKcal),
                "TotalCaloriesKcal must be greater than or equal to 0."));
        }

        return errors.Count > 0
            ? Result<HealthReadingMetrics>.Failure(errors)
            : Result<HealthReadingMetrics>.Success(
                new HealthReadingMetrics(
                    heartRateBpm,
                    steps,
                    sleepDuration,
                    oxygenSaturationPercent,
                    activeCaloriesKcal,
                    totalCaloriesKcal));
    }
}
