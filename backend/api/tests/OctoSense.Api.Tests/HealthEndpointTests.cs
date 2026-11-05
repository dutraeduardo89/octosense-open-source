using System.Net;
using System.Net.Http.Json;
using OctoSense.Application.Features.Readings.Commands.CreateHealthReading;
using Xunit;

namespace OctoSense.Api.Tests;

[Collection("Mongo")]
public class HealthEndpointTests : IDisposable
{
    private readonly CustomWebApplicationFactory _factory;
    private readonly HttpClient _client;

    public HealthEndpointTests(MongoTestContainerFixture fixture)
    {
        _factory = new CustomWebApplicationFactory(fixture.ConnectionString);
        _client = _factory.CreateClient();
    }

    [Fact]
    public async Task GetHealth_ShouldReturnOk_WhenApiIsRunning()
    {
        var response = await _client.GetAsync("/health");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task CreateReading_ShouldReturnCreated_WhenDataIsValid()
    {
        var command = new CreateHealthReadingCommand(
            UserId: "usr_test_001",
            DeviceId: "dev_galaxy_watch_6",
            DeviceSource: "SamsungHealth",
            RecordedAt: DateTimeOffset.UtcNow,
            HeartRateBpm: 75,
            Steps: 500,
            SyncMode: null,
            BatteryLevel: null);

        var response = await _client.PostAsJsonAsync("/readings", command);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }

    public void Dispose()
    {
        _client.Dispose();
        _factory.Dispose();
    }
}
