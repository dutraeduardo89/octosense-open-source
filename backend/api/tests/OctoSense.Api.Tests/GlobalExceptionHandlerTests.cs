using DotRValidator;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging.Abstractions;
using Moq;
using OctoSense.Api.Exceptions;
using Xunit;

namespace OctoSense.Api.Tests;

public sealed class GlobalExceptionHandlerTests
{
    [Fact]
    public async Task TryHandleAsync_ShouldReturnFalse_WhenExceptionIsCancellation()
    {
        var handler = CreateHandler();
        var context = new DefaultHttpContext();

        var handled = await handler.TryHandleAsync(
            context,
            new OperationCanceledException(),
            CancellationToken.None);

        handled.Should().BeFalse();
    }

    [Fact]
    public async Task TryHandleAsync_ShouldReturnBadRequest_WhenExceptionIsValidationException()
    {
        var handler = CreateHandler();
        var context = new DefaultHttpContext();
        context.Response.Body = new MemoryStream();
        var exception = new ValidationException(
            new ValidationResult([new ValidationFailure("HeartRateBpm", "HeartRateBpm must be greater than 0.")]));

        var handled = await handler.TryHandleAsync(context, exception, CancellationToken.None);

        handled.Should().BeTrue();
        context.Response.StatusCode.Should().Be(StatusCodes.Status400BadRequest);
    }

    [Fact]
    public async Task TryHandleAsync_ShouldReturnInternalServerError_WhenExceptionIsUnexpected()
    {
        var handler = CreateHandler();
        var context = new DefaultHttpContext();
        context.Response.Body = new MemoryStream();

        var handled = await handler.TryHandleAsync(
            context,
            new InvalidOperationException("boom"),
            CancellationToken.None);

        handled.Should().BeTrue();
        context.Response.StatusCode.Should().Be(StatusCodes.Status500InternalServerError);
    }

    private static GlobalExceptionHandler CreateHandler()
    {
        var environment = new Mock<IHostEnvironment>();
        environment.SetupGet(item => item.EnvironmentName).Returns(Environments.Development);
        return new GlobalExceptionHandler(environment.Object, NullLogger<GlobalExceptionHandler>.Instance);
    }
}
