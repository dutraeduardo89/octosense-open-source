using FluentAssertions;
using OctoSense.Domain.Readings;
using OctoSense.Domain.Results;
using Xunit;

namespace OctoSense.Api.Tests;

public sealed class HealthReadingTests
{
    [Fact]
    public void Create_ShouldReturnSuccess_WhenDataIsValid()
    {
        var result = HealthReading.Create(
            "usr_test_001",
            "dev_galaxy_watch_6",
            "SamsungHealth",
            DateTimeOffset.UtcNow,
            heartRateBpm: 72.5,
            steps: 100,
            syncMode: "Background",
            batteryLevel: 80);

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().NotBeNull();
        result.Value!.Metrics.HeartRateBpm.Should().Be(72.5);
        result.Value.Metadata.Should().NotBeNull();
    }

    [Theory]
    [InlineData(-10, 100)]
    [InlineData(80, -1)]
    public void Create_ShouldReturnFailure_WhenMetricsAreInvalid(double heartRateBpm, int steps)
    {
        var result = CreateReading(heartRateBpm: heartRateBpm, steps: steps);

        result.IsFailure.Should().BeTrue();
    }

    [Fact]
    public void Create_ShouldReturnFailure_WhenHeartRateBpmIsZero()
    {
        var result = CreateReading(heartRateBpm: 0, steps: 100);

        result.IsFailure.Should().BeTrue();
        result.Errors.Should().Contain(error => error.PropertyName == nameof(HealthReadingMetrics.HeartRateBpm));
    }

    [Fact]
    public void Create_ShouldReturnSuccess_WhenStepsAreZero()
    {
        var result = CreateReading(heartRateBpm: 72.5, steps: 0);

        result.IsSuccess.Should().BeTrue();
    }

    [Fact]
    public void Create_ShouldReturnFailure_WhenUserIdIsEmpty()
    {
        var result = CreateReading(userId: " ");

        result.IsFailure.Should().BeTrue();
        result.Errors.Should().Contain(error => error.PropertyName == nameof(HealthReading.UserId));
    }

    [Fact]
    public void Create_ShouldReturnFailure_WhenBatteryLevelIsOutOfRange()
    {
        var result = CreateReading(batteryLevel: 101);

        result.IsFailure.Should().BeTrue();
        result.Errors.Should().Contain(error => error.PropertyName == nameof(HealthReadingMetadata.BatteryLevel));
    }

    [Fact]
    public void Create_ShouldOmitMetadata_WhenSyncModeAndBatteryAreNull()
    {
        var result = CreateReading(syncMode: null, batteryLevel: null);

        result.IsSuccess.Should().BeTrue();
        result.Value!.Metadata.Should().BeNull();
    }

    [Fact]
    public void Create_ShouldReturnSuccess_WhenExternalIdAndSparseMetrics()
    {
        var result = HealthReading.Create(
            "usr_test_001",
            "google-health",
            "google-health",
            DateTimeOffset.UtcNow,
            steps: 4200,
            externalId: "users/me/dataTypes/steps/dataPoints/abc");

        result.IsSuccess.Should().BeTrue();
        result.Value!.ExternalId.Should().Be("users/me/dataTypes/steps/dataPoints/abc");
        result.Value.Metrics.Steps.Should().Be(4200);
        result.Value.Metrics.HeartRateBpm.Should().BeNull();
    }

    private static Result<HealthReading> CreateReading(
        string userId = "usr_test_001",
        double? heartRateBpm = 72.5,
        int? steps = 100,
        string? syncMode = "Background",
        int? batteryLevel = null)
    {
        return HealthReading.Create(
            userId,
            "dev_galaxy_watch_6",
            "SamsungHealth",
            DateTimeOffset.UtcNow,
            heartRateBpm,
            steps,
            syncMode: syncMode,
            batteryLevel: batteryLevel);
    }
}
