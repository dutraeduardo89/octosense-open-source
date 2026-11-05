using Testcontainers.MongoDb;
using Xunit;

namespace OctoSense.Api.Tests;

// Fixture compartilhada: sobe UM container Mongo por execução de teste
// e reusa entre todas as classes que declaram [Collection("Mongo")].
public sealed class MongoTestContainerFixture : IAsyncLifetime
{
    private readonly MongoDbContainer _container = new MongoDbBuilder("mongo:7")
        .WithCleanUp(true)
        .Build();

    public string ConnectionString => _container.GetConnectionString();

    public Task InitializeAsync() => _container.StartAsync();

    public Task DisposeAsync() => _container.DisposeAsync().AsTask();
}