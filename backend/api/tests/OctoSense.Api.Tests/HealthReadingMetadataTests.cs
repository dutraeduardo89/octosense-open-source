using FluentAssertions;
using OctoSense.Domain.Readings;
using Xunit;

namespace OctoSense.Api.Tests;

public sealed class HealthReadingMetadataTests
{
    [Fact]
    public void CreateOptional_ShouldReturnNull_WhenBothValuesAreMissing()
    {
        var result = HealthReadingMetadata.CreateOptional(null, null);

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().BeNull();
    }

    [Fact]
    public void CreateOptional_ShouldReturnMetadata_WhenBatteryLevelIsValid()
    {
        var result = HealthReadingMetadata.CreateOptional("Background", 50);

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().NotBeNull();
        result.Value!.BatteryLevel.Should().Be(50);
    }

    [Theory]
    [InlineData(-1)]
    [InlineData(101)]
    public void CreateOptional_ShouldReturnFailure_WhenBatteryLevelIsOutOfRange(int batteryLevel)
    {
        var result = HealthReadingMetadata.CreateOptional("Background", batteryLevel);

        result.IsFailure.Should().BeTrue();
    }
}
