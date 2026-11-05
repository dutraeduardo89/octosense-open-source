using System.Security.Claims;
using DotRMediator;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Moq;
using OctoSense.Api.Controllers;
using OctoSense.Application.Features.Readings.Commands.CreateHealthReading;
using OctoSense.Application.Features.Feedback;
using OctoSense.Domain.Readings;
using OctoSense.Domain.Results;
using Xunit;

namespace OctoSense.Api.Tests;

public sealed class ReadingsControllerTests
{
    // Email do usuário sintético. Precisa bater com o UserId do CreateCommand
    // porque o controller agora exige que userId da URL/JWT coincidam (BOLA fix).
    private const string TestEmail = "usr_test_001";

    [Fact]
    public async Task CreateAsync_ShouldReturnCreated_WhenCommandSucceeds()
    {
        var command = CreateCommand();
        var reading = HealthReading.Create(
            command.UserId,
            command.DeviceId,
            command.DeviceSource,
            command.RecordedAt,
            heartRateBpm: command.HeartRateBpm,
            steps: command.Steps,
            syncMode: command.SyncMode,
            batteryLevel: command.BatteryLevel).Value!;
        var sender = new Mock<ISender>(MockBehavior.Strict);
        sender
            .Setup(item => item.Send(
                It.Is<CreateHealthReadingCommand>(c => c.UserId == TestEmail),
                It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<HealthReading>.Success(reading));

        var controller = BuildController(sender.Object);

        var result = await controller.CreateAsync(command, CancellationToken.None);

        result.Should().BeAssignableTo<IStatusCodeHttpResult>()
            .Which.StatusCode.Should().Be(StatusCodes.Status201Created);
        sender.Verify(
            item => item.Send(
                It.Is<CreateHealthReadingCommand>(c => c.UserId == TestEmail),
                It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task CreateAsync_ShouldReturnBadRequest_WhenCommandFails()
    {
        var command = CreateCommand();
        var sender = new Mock<ISender>(MockBehavior.Strict);
        sender
            .Setup(item => item.Send(
                It.IsAny<CreateHealthReadingCommand>(),
                It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<HealthReading>.Failure(
                Error.Validation("HeartRateBpm", "HeartRateBpm must be greater than 0.")));

        var controller = BuildController(sender.Object);

        var result = await controller.CreateAsync(command, CancellationToken.None);

        result.Should().BeAssignableTo<IStatusCodeHttpResult>()
            .Which.StatusCode.Should().Be(StatusCodes.Status400BadRequest);
    }

    /// <summary>
    /// Cria um ReadingsController com ControllerContext + User autenticado,
    /// para que User.GetAuthenticatedEmail() retorne TestEmail.
    /// </summary>
    private static ReadingsController BuildController(ISender sender)
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, TestEmail),
            new Claim("email", TestEmail),
            new Claim(ClaimTypes.Email, TestEmail),
        };
        var identity = new ClaimsIdentity(claims, "Test");
        var principal = new ClaimsPrincipal(identity);

        return new ReadingsController(sender, new Mock<IFeedbackService>().Object)
        {
            ControllerContext = new ControllerContext
            {
                HttpContext = new DefaultHttpContext { User = principal },
            },
        };
    }

    private static CreateHealthReadingCommand CreateCommand()
    {
        return new CreateHealthReadingCommand(
            UserId: TestEmail,
            DeviceId: "dev_galaxy_watch_6",
            DeviceSource: "SamsungHealth",
            RecordedAt: DateTimeOffset.UtcNow,
            HeartRateBpm: 72,
            Steps: 100,
            SyncMode: null,
            BatteryLevel: null);
    }
}
