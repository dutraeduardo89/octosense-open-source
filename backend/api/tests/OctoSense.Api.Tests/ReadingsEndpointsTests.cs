using System.Net;
using System.Net.Http.Json;
using OctoSense.Application.Features.Readings.Commands.CreateHealthReading;
using Xunit;

namespace OctoSense.Api.Tests;

[Collection("Mongo")]
public class ReadingsEndpointsTests : IDisposable
{
    private readonly CustomWebApplicationFactory _factory;
    private readonly HttpClient _client;

    public ReadingsEndpointsTests(MongoTestContainerFixture fixture)
    {
        _factory = new CustomWebApplicationFactory(fixture.ConnectionString);
        _client = _factory.CreateClient();
    }

    [Fact]
    public async Task PostReading_ShouldReturnCreated_WhenPayloadIsValid()
    {
        var command = CreateCommand(heartRateBpm: 80, steps: 1200, batteryLevel: 88);
        var response = await _client.PostAsJsonAsync("/readings", command);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }

    [Fact]
    public async Task PostReading_ShouldReturnBadRequest_WhenPayloadIsInvalid()
    {
        var command = CreateCommand(heartRateBpm: -5, steps: 1200, batteryLevel: null);
        var response = await _client.PostAsJsonAsync("/readings", command);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task PostReading_ShouldReturnCreated_WhenOptionalMetadataIsMissing()
    {
        var command = CreateCommand(heartRateBpm: 68, steps: 800, syncMode: null, batteryLevel: null);
        var response = await _client.PostAsJsonAsync("/readings", command);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }

    [Fact]
    public async Task GetReadings_ShouldReturnOk_WhenUserIdProvided()
    {
        var command = CreateCommand(heartRateBpm: 75, steps: 500);
        await _client.PostAsJsonAsync("/readings", command);

        var response = await _client.GetAsync("/readings?userId=usr_test_001");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var json = await response.Content.ReadAsStringAsync();
        Assert.Contains("usr_test_001", json);
        Assert.Contains("heartRateBpm", json, StringComparison.OrdinalIgnoreCase);
    }

    public void Dispose()
    {
        _client.Dispose();
        _factory.Dispose();
    }

    private static CreateHealthReadingCommand CreateCommand(
        double? heartRateBpm,
        int? steps,
        string? syncMode = "Background",
        int? batteryLevel = 88)
    {
        return new CreateHealthReadingCommand(
            UserId: "usr_test_001",
            DeviceId: "dev_galaxy_watch_6",
            DeviceSource: "SamsungHealth",
            RecordedAt: DateTimeOffset.UtcNow,
            HeartRateBpm: heartRateBpm,
            Steps: steps,
            SyncMode: syncMode,
            BatteryLevel: batteryLevel);
    }
}
