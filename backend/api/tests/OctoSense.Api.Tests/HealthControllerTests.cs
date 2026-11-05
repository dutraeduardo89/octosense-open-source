using DotRMediator;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Moq;
using OctoSense.Api.Controllers;
using OctoSense.Application.Features.Health.Queries.GetHealth;
using OctoSense.Domain.Results;
using Xunit;

namespace OctoSense.Api.Tests;

public sealed class HealthControllerTests
{
    [Fact]
    public async Task GetAsync_ShouldReturnOk_WhenQuerySucceeds()
    {
        var sender = new Mock<ISender>(MockBehavior.Strict);
        sender
            .Setup(item => item.Send(It.IsAny<GetHealthQuery>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<HealthStatusResponse>.Success(new HealthStatusResponse("healthy")));

        var controller = new HealthController(sender.Object);

        var result = await controller.GetAsync(CancellationToken.None);

        result.Should().BeAssignableTo<IStatusCodeHttpResult>()
            .Which.StatusCode.Should().Be(StatusCodes.Status200OK);
        sender.Verify(
            item => item.Send(It.IsAny<GetHealthQuery>(), It.IsAny<CancellationToken>()),
            Times.Once);
    }
}
