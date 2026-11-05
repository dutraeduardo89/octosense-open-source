using FluentAssertions;
using Microsoft.Extensions.Logging.Abstractions;
using Moq;
using OctoSense.Application.Features.GoogleHealth.Commands.SyncGoogleHealthReadings;
using OctoSense.Domain.GoogleHealth;
using OctoSense.Domain.Readings;

namespace OctoSense.Api.Tests.Features.GoogleHealth;

public sealed class SyncGoogleHealthReadingsCommandHandlerTests
{
    [Fact]
    public async Task Handle_ShouldFail_WhenGoogleHealthLinkIsMissing()
    {
        var googleClient = new Mock<IGoogleHealthClient>(MockBehavior.Strict);
        var linkRepository = new Mock<IGoogleHealthLinkRepository>(MockBehavior.Strict);
        var cursorRepository = new Mock<IGoogleHealthSyncCursorRepository>(MockBehavior.Strict);
        var readingRepository = new Mock<IHealthReadingRepository>(MockBehavior.Strict);

        linkRepository
            .Setup(item => item.GetByUserIdAsync("usr_missing", It.IsAny<CancellationToken>()))
            .ReturnsAsync((GoogleHealthLink?)null);

        var handler = new SyncGoogleHealthReadingsCommandHandler(
            googleClient.Object,
            linkRepository.Object,
            cursorRepository.Object,
            readingRepository.Object,
            NullLogger<SyncGoogleHealthReadingsCommandHandler>.Instance);

        var result = await handler.Handle(
            new SyncGoogleHealthReadingsCommand("usr_missing"),
            CancellationToken.None);

        result.IsFailure.Should().BeTrue();
        result.Errors[0].Message.Should().Be("Google Health link not found.");
    }

    [Fact]
    public async Task Handle_ShouldContinue_WhenOneDataTypeFails()
    {
        var googleClient = new Mock<IGoogleHealthClient>(MockBehavior.Strict);
        var linkRepository = new Mock<IGoogleHealthLinkRepository>(MockBehavior.Strict);
        var cursorRepository = new Mock<IGoogleHealthSyncCursorRepository>(MockBehavior.Strict);
        var readingRepository = new Mock<IHealthReadingRepository>(MockBehavior.Strict);
        var link = new GoogleHealthLink(
            "owner@gmail.com",
            "refresh-token",
            "access-token",
            DateTimeOffset.UtcNow.AddHours(1),
            DateTimeOffset.UtcNow);

        linkRepository
            .Setup(item => item.GetByUserIdAsync("owner@gmail.com", It.IsAny<CancellationToken>()))
            .ReturnsAsync(link);
        cursorRepository
            .Setup(item => item.GetAsync("owner@gmail.com", It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((GoogleHealthSyncCursor?)null);
        cursorRepository
            .Setup(item => item.UpsertAsync(It.IsAny<GoogleHealthSyncCursor>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);
        googleClient
            .Setup(item => item.ListDataPointsAsync(
                "access-token",
                "heart-rate",
                It.IsAny<DateTimeOffset>(),
                It.IsAny<CancellationToken>()))
            .ThrowsAsync(new HttpRequestException("Response status code does not indicate success: 403 (Forbidden)."));
        googleClient
            .Setup(item => item.ListDataPointsAsync(
                "access-token",
                It.Is<string>(dataType => dataType != "heart-rate"),
                It.IsAny<DateTimeOffset>(),
                It.IsAny<CancellationToken>()))
            .ReturnsAsync([]);

        var handler = new SyncGoogleHealthReadingsCommandHandler(
            googleClient.Object,
            linkRepository.Object,
            cursorRepository.Object,
            readingRepository.Object,
            NullLogger<SyncGoogleHealthReadingsCommandHandler>.Instance);

        var result = await handler.Handle(
            new SyncGoogleHealthReadingsCommand("owner@gmail.com"),
            CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        googleClient.Verify(
            item => item.ListDataPointsAsync(
                "access-token",
                "active-energy-burned",
                It.IsAny<DateTimeOffset>(),
                It.IsAny<CancellationToken>()),
            Times.Once);
    }
}