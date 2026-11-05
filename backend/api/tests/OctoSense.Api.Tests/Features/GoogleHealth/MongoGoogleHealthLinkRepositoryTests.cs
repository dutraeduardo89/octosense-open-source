using FluentAssertions;
using MongoDB.Driver;
using OctoSense.Domain.GoogleHealth;
using OctoSense.Infrastructure.Persistence.Mongo;

namespace OctoSense.Api.Tests.Features.GoogleHealth;

[Collection("Mongo")]
public sealed class MongoGoogleHealthLinkRepositoryTests
{
    private readonly MongoTestContainerFixture _fixture;

    public MongoGoogleHealthLinkRepositoryTests(MongoTestContainerFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task ListAllAsync_ShouldReturnPersistedLink_WhenUpserted()
    {
        var context = new MongoDbContext(
            new MongoClient(_fixture.ConnectionString),
            $"octosense_test_{Guid.NewGuid():N}");
        var repository = new MongoGoogleHealthLinkRepository(context);
        var linkedAt = DateTimeOffset.Parse("2026-09-20T12:00:00Z");
        var link = new GoogleHealthLink(
            "usr_local_demo",
            "refresh-token",
            "access-token",
            linkedAt.AddHours(1),
            linkedAt);

        await repository.UpsertAsync(link, CancellationToken.None);

        var listed = await repository.ListAllAsync(CancellationToken.None);

        listed.Should().ContainSingle()
            .Which.UserId.Should().Be("usr_local_demo");
        listed[0].RefreshToken.Should().Be("refresh-token");
    }
}
