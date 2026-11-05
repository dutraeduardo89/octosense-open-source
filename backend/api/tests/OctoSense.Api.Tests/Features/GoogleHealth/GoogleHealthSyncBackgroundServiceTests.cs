using DotRMediator;
using FluentAssertions;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using Moq;
using OctoSense.Api.Workers;
using OctoSense.Application.Features.GoogleHealth.Commands.SyncGoogleHealthReadings;
using OctoSense.Domain.GoogleHealth;
using OctoSense.Domain.Results;
using OctoSense.Infrastructure.GoogleHealth;

namespace OctoSense.Api.Tests.Features.GoogleHealth;

public sealed class GoogleHealthSyncBackgroundServiceTests
{
    [Fact]
    public async Task SyncLinkedUsersAsync_ShouldDispatchSyncCommand_WhenUserIsLinked()
    {
        var linkRepository = new Mock<IGoogleHealthLinkRepository>(MockBehavior.Strict);
        var sender = new Mock<ISender>(MockBehavior.Strict);
        var link = new GoogleHealthLink(
            "usr_local_demo",
            "refresh-token",
            "access-token",
            DateTimeOffset.UtcNow.AddHours(1),
            DateTimeOffset.UtcNow);

        linkRepository
            .Setup(item => item.ListAllAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync([link]);
        sender
            .Setup(item => item.Send(
                It.Is<SyncGoogleHealthReadingsCommand>(command => command.UserId == "usr_local_demo"),
                It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<SyncGoogleHealthReadingsResult>.Success(new SyncGoogleHealthReadingsResult(3, 1)));

        var worker = CreateWorker(enabled: true, linkRepository.Object, sender.Object);

        await worker.SyncLinkedUsersAsync(CancellationToken.None);

        sender.Verify(
            item => item.Send(
                It.Is<SyncGoogleHealthReadingsCommand>(command => command.UserId == "usr_local_demo"),
                It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task SyncLinkedUsersAsync_ShouldNotDispatch_WhenDisabled()
    {
        var linkRepository = new Mock<IGoogleHealthLinkRepository>(MockBehavior.Strict);
        var sender = new Mock<ISender>(MockBehavior.Strict);
        var worker = CreateWorker(enabled: false, linkRepository.Object, sender.Object);

        await worker.SyncLinkedUsersAsync(CancellationToken.None);

        sender.Verify(
            item => item.Send(It.IsAny<SyncGoogleHealthReadingsCommand>(), It.IsAny<CancellationToken>()),
            Times.Never);
        linkRepository.Verify(
            item => item.ListAllAsync(It.IsAny<CancellationToken>()),
            Times.Never);
    }

    [Fact]
    public async Task SyncLinkedUsersAsync_ShouldNotDispatch_WhenNoLinksExist()
    {
        var linkRepository = new Mock<IGoogleHealthLinkRepository>(MockBehavior.Strict);
        var sender = new Mock<ISender>(MockBehavior.Strict);
        linkRepository
            .Setup(item => item.ListAllAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync([]);

        var worker = CreateWorker(enabled: true, linkRepository.Object, sender.Object);

        await worker.SyncLinkedUsersAsync(CancellationToken.None);

        sender.Verify(
            item => item.Send(It.IsAny<SyncGoogleHealthReadingsCommand>(), It.IsAny<CancellationToken>()),
            Times.Never);
    }

    [Fact]
    public async Task SyncLinkedUsersAsync_ShouldContinue_WhenOneUserFails()
    {
        var linkRepository = new Mock<IGoogleHealthLinkRepository>(MockBehavior.Strict);
        var sender = new Mock<ISender>(MockBehavior.Strict);
        var first = new GoogleHealthLink(
            "usr_fail",
            "refresh-a",
            null,
            null,
            DateTimeOffset.UtcNow);
        var second = new GoogleHealthLink(
            "usr_ok",
            "refresh-b",
            null,
            null,
            DateTimeOffset.UtcNow);

        linkRepository
            .Setup(item => item.ListAllAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync([first, second]);
        sender
            .Setup(item => item.Send(
                It.Is<SyncGoogleHealthReadingsCommand>(command => command.UserId == "usr_fail"),
                It.IsAny<CancellationToken>()))
            .ThrowsAsync(new InvalidOperationException("Google unavailable."));
        sender
            .Setup(item => item.Send(
                It.Is<SyncGoogleHealthReadingsCommand>(command => command.UserId == "usr_ok"),
                It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<SyncGoogleHealthReadingsResult>.Success(new SyncGoogleHealthReadingsResult(1, 0)));

        var worker = CreateWorker(enabled: true, linkRepository.Object, sender.Object);

        var act = async () => await worker.SyncLinkedUsersAsync(CancellationToken.None);

        await act.Should().NotThrowAsync();
        sender.Verify(
            item => item.Send(
                It.Is<SyncGoogleHealthReadingsCommand>(command => command.UserId == "usr_ok"),
                It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task SyncLinkedUsersAsync_ShouldContinue_WhenCommandReturnsFailure()
    {
        var linkRepository = new Mock<IGoogleHealthLinkRepository>(MockBehavior.Strict);
        var sender = new Mock<ISender>(MockBehavior.Strict);
        var failing = new GoogleHealthLink(
            "usr_missing_link",
            "refresh",
            null,
            null,
            DateTimeOffset.UtcNow);
        var succeeding = new GoogleHealthLink(
            "usr_linked",
            "refresh",
            null,
            null,
            DateTimeOffset.UtcNow);

        linkRepository
            .Setup(item => item.ListAllAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync([failing, succeeding]);
        sender
            .Setup(item => item.Send(
                It.Is<SyncGoogleHealthReadingsCommand>(command => command.UserId == "usr_missing_link"),
                It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<SyncGoogleHealthReadingsResult>.Failure(
                Error.Validation("UserId", "Google Health link not found.")));
        sender
            .Setup(item => item.Send(
                It.Is<SyncGoogleHealthReadingsCommand>(command => command.UserId == "usr_linked"),
                It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<SyncGoogleHealthReadingsResult>.Success(new SyncGoogleHealthReadingsResult(2, 0)));

        var worker = CreateWorker(enabled: true, linkRepository.Object, sender.Object);

        await worker.SyncLinkedUsersAsync(CancellationToken.None);

        sender.Verify(
            item => item.Send(
                It.Is<SyncGoogleHealthReadingsCommand>(command => command.UserId == "usr_linked"),
                It.IsAny<CancellationToken>()),
            Times.Once);
    }

    private static GoogleHealthSyncBackgroundService CreateWorker(
        bool enabled,
        IGoogleHealthLinkRepository linkRepository,
        ISender sender)
    {
        var services = new ServiceCollection();
        services.AddSingleton(linkRepository);
        services.AddSingleton(sender);
        var provider = services.BuildServiceProvider();

        return new GoogleHealthSyncBackgroundService(
            provider.GetRequiredService<IServiceScopeFactory>(),
            Options.Create(new GoogleHealthOptions
            {
                Enabled = enabled,
                SyncInterval = TimeSpan.FromMinutes(15)
            }),
            NullLogger<GoogleHealthSyncBackgroundService>.Instance);
    }
}
