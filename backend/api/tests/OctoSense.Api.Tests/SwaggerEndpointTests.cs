using System.Net;
using Xunit;

namespace OctoSense.Api.Tests;

[Collection("Mongo")]
public sealed class SwaggerEndpointTests : IDisposable
{
    private readonly CustomWebApplicationFactory _factory;
    private readonly HttpClient _client;

    public SwaggerEndpointTests(MongoTestContainerFixture fixture)
    {
        _factory = new CustomWebApplicationFactory(fixture.ConnectionString);
        _client = _factory.CreateClient();
    }

    [Fact]
    public async Task GetSwaggerUi_ShouldReturnOk_WhenApiIsRunning()
    {
        var response = await _client.GetAsync("/swagger/index.html");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task GetSwaggerJson_ShouldReturnOk_WhenApiIsRunning()
    {
        var response = await _client.GetAsync("/swagger/octosense/swagger.json");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    public void Dispose()
    {
        _client.Dispose();
        _factory.Dispose();
    }
}
