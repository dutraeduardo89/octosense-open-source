using FluentAssertions;
using MongoDB.Driver;
using OctoSense.Domain.Readings;
using OctoSense.Infrastructure.Persistence.Mongo;

namespace OctoSense.Api.Tests.Features.Readings;

[Collection("Mongo")]
public sealed class MongoHealthReadingRepositoryTests
{
    private readonly MongoTestContainerFixture _fixture;

    public MongoHealthReadingRepositoryTests(MongoTestContainerFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task SaveAsync_ShouldInsertTwoReadings_WhenIdsAreGenerated()
    {
        var context = new MongoDbContext(
            new MongoClient(_fixture.ConnectionString),
            $"octosense_test_{Guid.NewGuid():N}");
        await MongoIndexInitializer.EnsureIndexesAsync(context);
        var repository = new MongoHealthReadingRepository(context);
        var first = HealthReading.Create(
            "owner@gmail.com",
            "google-health",
            "google-health",
            DateTimeOffset.Parse("2026-09-20T12:00:00Z"),
            totalCaloriesKcal: 1364,
            syncMode: "GoogleHealthSync",
            externalId: "users/me/dataTypes/total-calories/daily/2026-09-20").Value!;
        var second = HealthReading.Create(
            "owner@gmail.com",
            "google-health",
            "google-health",
            DateTimeOffset.Parse("2026-09-19T12:00:00Z"),
            totalCaloriesKcal: 1200,
            syncMode: "GoogleHealthSync",
            externalId: "users/me/dataTypes/total-calories/daily/2026-09-19").Value!;

        await repository.SaveAsync(first, CancellationToken.None);
        await repository.SaveAsync(second, CancellationToken.None);

        var listed = await repository.ListByUserIdAsync("owner@gmail.com", CancellationToken.None);

        listed.Should().HaveCount(2);
    }
}
