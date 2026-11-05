using System.Text.Json;
using FluentAssertions;
using OctoSense.Infrastructure.GoogleHealth;

namespace OctoSense.Api.Tests.Features.GoogleHealth;

public sealed class GoogleHealthDataPointMapperTests
{
    [Fact]
    public void TryMapListItem_ShouldMapHeartRate_WhenBeatsPerMinuteIsString()
    {
        using var document = JsonDocument.Parse(
            """
            {
              "name": "users/me/dataTypes/heart-rate/dataPoints/hr-1",
              "dataSource": { "recordingMethod": "ACTIVELY_MEASURED" },
              "heartRate": {
                "sampleTime": { "physicalTime": "2026-09-20T08:00:00Z" },
                "beatsPerMinute": "72"
              }
            }
            """);

        var mapped = GoogleHealthDataPointMapper.TryMapListItem(document.RootElement, "heart-rate");

        mapped.Should().NotBeNull();
        mapped!.HeartRateBpm.Should().Be(72);
        mapped.RecordedAt.UtcDateTime.Should().Be(new DateTime(2026, 9, 20, 8, 0, 0, DateTimeKind.Utc));
    }

    [Fact]
    public void TryMapListItem_ShouldMapSteps_WhenCountIsString()
    {
        using var document = JsonDocument.Parse(
            """
            {
              "name": "users/me/dataTypes/steps/dataPoints/s-1",
              "steps": {
                "interval": { "startTime": "2026-09-20T10:00:00Z", "endTime": "2026-09-20T11:00:00Z" },
                "count": "1364"
              }
            }
            """);

        var mapped = GoogleHealthDataPointMapper.TryMapListItem(document.RootElement, "steps");

        mapped.Should().NotBeNull();
        mapped!.Steps.Should().Be(1364);
    }

    [Fact]
    public void TryMapListItem_ShouldMapSleep_WhenIntervalIsNested()
    {
        using var document = JsonDocument.Parse(
            """
            {
              "name": "users/me/dataTypes/sleep/dataPoints/sl-1",
              "sleep": {
                "interval": {
                  "startTime": "2026-09-19T23:00:00Z",
                  "endTime": "2026-09-20T06:24:00Z"
                }
              }
            }
            """);

        var mapped = GoogleHealthDataPointMapper.TryMapListItem(document.RootElement, "sleep");

        mapped.Should().NotBeNull();
        mapped!.SleepDuration.Should().Be(TimeSpan.FromHours(7) + TimeSpan.FromMinutes(24));
    }

    [Fact]
    public void TryMapListItem_ShouldMapActiveEnergy_WhenKcalIsNested()
    {
        using var document = JsonDocument.Parse(
            """
            {
              "name": "users/me/dataTypes/active-energy-burned/dataPoints/c-1",
              "activeEnergyBurned": {
                "interval": { "startTime": "2026-09-20T12:00:00Z", "endTime": "2026-09-20T13:00:00Z" },
                "kcal": 120.5
              }
            }
            """);

        var mapped = GoogleHealthDataPointMapper.TryMapListItem(document.RootElement, "active-energy-burned");

        mapped.Should().NotBeNull();
        mapped!.TotalCaloriesKcal.Should().Be(120.5);
    }

    [Fact]
    public void TryMapTotalCaloriesRollup_ShouldMapDailyKcalSum()
    {
        using var document = JsonDocument.Parse(
            """
            {
              "civilStartTime": { "year": 2026, "month": 9, "day": 20 },
              "totalCalories": { "kcalSum": 1364 }
            }
            """);

        var mapped = GoogleHealthDataPointMapper.TryMapTotalCaloriesRollup(document.RootElement);

        mapped.Should().NotBeNull();
        mapped!.TotalCaloriesKcal.Should().Be(1364);
        mapped.Name.Should().Be("users/me/dataTypes/total-calories/daily/2026-09-20");
        mapped.DataType.Should().Be("total-calories");
    }

    [Fact]
    public void TryMapTotalCaloriesRollup_ShouldMapDailyKcalSum_WhenCivilStartUsesNestedDate()
    {
        using var document = JsonDocument.Parse(
            """
            {
              "civilStartTime": { "date": { "year": 2026, "month": 9, "day": 20 }, "time": {} },
              "totalCalories": { "kcalSum": 1364 }
            }
            """);

        var mapped = GoogleHealthDataPointMapper.TryMapTotalCaloriesRollup(document.RootElement);

        mapped.Should().NotBeNull();
        mapped!.TotalCaloriesKcal.Should().Be(1364);
        mapped.Name.Should().Be("users/me/dataTypes/total-calories/daily/2026-09-20");
    }
}
