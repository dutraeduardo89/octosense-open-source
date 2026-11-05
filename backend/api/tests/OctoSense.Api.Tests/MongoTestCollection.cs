using Xunit;

namespace OctoSense.Api.Tests;

// Define a collection "Mongo" no xUnit.
// Classes marcadas com [Collection("Mongo")] compartilham a mesma fixture
// (mesmo container) — evita subir N containers para N classes de teste.
[CollectionDefinition("Mongo")]
public sealed class MongoTestCollection : ICollectionFixture<MongoTestContainerFixture>
{
    // Classe vazia: só serve para registrar a fixture na collection.
}