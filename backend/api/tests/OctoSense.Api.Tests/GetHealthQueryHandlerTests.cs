using FluentAssertions;
using OctoSense.Application.Features.Health.Queries.GetHealth;
using Xunit;

namespace OctoSense.Api.Tests;

public sealed class GetHealthQueryHandlerTests
{
    [Fact]
    public async Task Handle_ShouldReturnHealthy_WhenQueryIsSent()
    {
        var handler = new GetHealthQueryHandler();

        var result = await handler.Handle(new GetHealthQuery(), CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().NotBeNull();
        result.Value!.Status.Should().Be("healthy");
    }
}
