using FluentAssertions;
using OctoSense.Domain.Readings;
using Xunit;

namespace OctoSense.Api.Tests;

public sealed class HealthReadingMetricsTests
{
    [Fact]
    public void Create_ShouldReturnSuccess_WhenDataIsValid()
    {
        var result = HealthReadingMetrics.Create(heartRateBpm: 72, steps: 10);

        result.IsSuccess.Should().BeTrue();
        result.Value!.HeartRateBpm.Should().Be(72);
        result.Value.Steps.Should().Be(10);
    }

    [Fact]
    public void Create_ShouldReturnFailure_WhenHeartRateBpmIsNotGreaterThanZero()
    {
        var result = HealthReadingMetrics.Create(heartRateBpm: 0, steps: 10);

        result.IsFailure.Should().BeTrue();
    }

    [Fact]
    public void Create_ShouldReturnFailure_WhenStepsAreNegative()
    {
        var result = HealthReadingMetrics.Create(heartRateBpm: 72, steps: -1);

        result.IsFailure.Should().BeTrue();
    }

    [Fact]
    public void Create_ShouldReturnSuccess_WhenOnlyStepsProvided()
    {
        var result = HealthReadingMetrics.Create(steps: 1500);

        result.IsSuccess.Should().BeTrue();
        result.Value!.Steps.Should().Be(1500);
        result.Value.HeartRateBpm.Should().BeNull();
    }

    [Fact]
    public void Create_ShouldReturnFailure_WhenNoMetricProvided()
    {
        var result = HealthReadingMetrics.Create();

        result.IsFailure.Should().BeTrue();
    }

    [Fact]
    public void Create_ShouldReturnFailure_WhenOxygenSaturationOutOfRange()
    {
        var result = HealthReadingMetrics.Create(oxygenSaturationPercent: 120);

        result.IsFailure.Should().BeTrue();
        result.Errors.Should().Contain(error =>
            error.PropertyName == nameof(HealthReadingMetrics.OxygenSaturationPercent));
    }

    [Fact]
    public void Create_ShouldReturnSuccess_WhenOnlySleepProvided()
    {
        var result = HealthReadingMetrics.Create(sleepDuration: TimeSpan.FromHours(7));

        result.IsSuccess.Should().BeTrue();
        result.Value!.SleepDuration.Should().Be(TimeSpan.FromHours(7));
    }
}
