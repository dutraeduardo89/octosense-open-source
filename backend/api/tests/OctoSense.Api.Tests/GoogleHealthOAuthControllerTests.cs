using System.Net;
using System.Net.Http;
using System.Net.Http.Json;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Moq;
using OctoSense.Domain.GoogleHealth;
using Xunit;

namespace OctoSense.Api.Tests;

[Collection("Mongo")]
public sealed class GoogleHealthOAuthControllerTests : IDisposable
{
    private readonly CustomWebApplicationFactory _factory;
    private readonly Mock<IGoogleHealthClient> _googleClient = new(MockBehavior.Strict);
    private readonly Mock<IGoogleHealthLinkRepository> _linkRepository = new(MockBehavior.Strict);
    private readonly HttpClient _client;

    public GoogleHealthOAuthControllerTests(MongoTestContainerFixture fixture)
    {
        _factory = new CustomWebApplicationFactory(fixture.ConnectionString);
        _client = _factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureTestServices(services =>
            {
                services.RemoveAll<IGoogleHealthClient>();
                services.RemoveAll<IGoogleHealthLinkRepository>();
                services.AddSingleton(_googleClient.Object);
                services.AddSingleton(_linkRepository.Object);
            });
        }).CreateClient(new WebApplicationFactoryClientOptions
        {
            AllowAutoRedirect = false
        });
    }

    [Fact]
    public async Task Start_ShouldReturnAuthorizationUrl_WhenClientIdIsConfigured()
    {
        _googleClient
            .Setup(item => item.BuildAuthorizationUrl())
            .Returns("https://accounts.google.com/o/oauth2/v2/auth?client_id=test");

        var response = await _client.GetAsync("/auth/google/health");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var payload = await response.Content.ReadFromJsonAsync<Dictionary<string, string>>();
        payload!["authorizationUrl"].Should().StartWith("https://accounts.google.com/");
    }

    [Fact]
    public async Task Callback_ShouldPersistLink_WhenCodeExchangeSucceeds()
    {
        _googleClient
            .Setup(item => item.ExchangeCodeAsync("auth-code", It.IsAny<CancellationToken>()))
            .ReturnsAsync(new GoogleOAuthTokens("access", "refresh", 3600));
        _googleClient
            .Setup(item => item.GetUserProfileAsync("access", It.IsAny<CancellationToken>()))
            .ReturnsAsync(new GoogleUserProfile("owner@gmail.com"));

        _linkRepository
            .Setup(item => item.UpsertAsync(It.IsAny<GoogleHealthLink>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        var response = await _client.GetAsync("/auth/google/health/callback?code=auth-code");
        var html = await response.Content.ReadAsStringAsync();

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        html.Should().Contain("octosense://oauth/linked");
        html.Should().Contain("Abrir OctoSense");
        _linkRepository.Verify(
            item => item.UpsertAsync(
                It.Is<GoogleHealthLink>(link =>
                    link.UserId == "owner@gmail.com" && link.RefreshToken == "refresh"),
                It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task Active_ShouldReturnLinkedEmail_WhenLinkExists()
    {
        _linkRepository
            .Setup(item => item.GetMostRecentlyLinkedAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(new GoogleHealthLink(
                "owner@gmail.com",
                "refresh",
                "access",
                DateTimeOffset.UtcNow.AddHours(1),
                DateTimeOffset.UtcNow));

        var response = await _client.GetAsync("/auth/google/health/active");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var body = await response.Content.ReadAsStringAsync();
        body.Should().Contain("owner@gmail.com");
    }

    [Fact]
    public async Task Unlink_ShouldRemoveLink_WhenUserIdExists()
    {
        _linkRepository
            .Setup(item => item.DeleteAsync("usr_oauth_001", It.IsAny<CancellationToken>()))
            .ReturnsAsync(true);

        var response = await _client.DeleteAsync("/auth/google/health/usr_oauth_001");

        response.StatusCode.Should().Be(HttpStatusCode.NoContent);
    }

    public void Dispose()
    {
        _client.Dispose();
        _factory.Dispose();
    }
}
