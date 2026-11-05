using DotRValidator;
using FluentAssertions;
using Moq;
using OctoSense.Application.Common.Behaviors;
using OctoSense.Application.Features.Readings.Commands.CreateHealthReading;
using OctoSense.Domain.Readings;
using OctoSense.Domain.Results;
using Xunit;

namespace OctoSense.Api.Tests;

public sealed class ValidationBehaviorTests
{
    [Fact]
    public async Task Handle_ShouldCallNext_WhenValidatorSucceeds()
    {
        var command = CreateCommand();
        var validator = new CreateHealthReadingCommandValidator();
        var behavior = new ValidationBehavior<CreateHealthReadingCommand, Result<HealthReading>>([validator]);
        var nextCalled = false;

        var response = await behavior.Handle(
            command,
            () =>
            {
                nextCalled = true;
                return Task.FromResult(Result<HealthReading>.Success(CreateValidReading()));
            },
            CancellationToken.None);

        nextCalled.Should().BeTrue();
        response.IsSuccess.Should().BeTrue();
    }

    [Fact]
    public async Task Handle_ShouldReturnFailure_WhenValidatorFails()
    {
        var command = CreateCommand(heartRateBpm: -1);
        var validator = new CreateHealthReadingCommandValidator();
        var behavior = new ValidationBehavior<CreateHealthReadingCommand, Result<HealthReading>>([validator]);

        var response = await behavior.Handle(
            command,
            () => Task.FromResult(Result<HealthReading>.Success(CreateValidReading())),
            CancellationToken.None);

        response.IsFailure.Should().BeTrue();
        response.Errors.Should().Contain(error => error.Code == Error.ValidationCode);
    }

    [Fact]
    public async Task Handle_ShouldThrowValidationException_WhenResponseIsNotResult()
    {
        var validator = new Mock<IValidator<string>>();
        validator
            .Setup(item => item.ValidateAsync("invalid", It.IsAny<CancellationToken>()))
            .ReturnsAsync(new ValidationResult([new ValidationFailure("Value", "Value is invalid.")]));

        var behavior = new ValidationBehavior<string, string>([validator.Object]);

        var act = async () => await behavior.Handle(
            "invalid",
            () => Task.FromResult("ok"),
            CancellationToken.None);

        await act.Should().ThrowAsync<ValidationException>();
    }

    private static CreateHealthReadingCommand CreateCommand(double heartRateBpm = 72)
    {
        return new CreateHealthReadingCommand(
            UserId: "usr_test_001",
            DeviceId: "dev_galaxy_watch_6",
            DeviceSource: "SamsungHealth",
            RecordedAt: DateTimeOffset.UtcNow,
            HeartRateBpm: heartRateBpm,
            Steps: 100,
            SyncMode: null,
            BatteryLevel: null);
    }

    private static HealthReading CreateValidReading()
    {
        return HealthReading.Create(
            "usr_test_001",
            "dev_galaxy_watch_6",
            "SamsungHealth",
            DateTimeOffset.UtcNow,
            heartRateBpm: 72,
            steps: 100).Value!;
    }
}
