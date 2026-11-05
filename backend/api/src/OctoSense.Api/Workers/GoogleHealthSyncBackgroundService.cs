using DotRMediator;
using Microsoft.Extensions.Options;
using OctoSense.Application.Features.GoogleHealth.Commands.SyncGoogleHealthReadings;
using OctoSense.Domain.GoogleHealth;
using OctoSense.Infrastructure.GoogleHealth;

namespace OctoSense.Api.Workers;

/// <summary>
/// Hosted worker that imports Google Health data points for every linked user.
/// </summary>
/// <param name="scopeFactory">Creates a DI scope per sync cycle.</param>
/// <param name="options">Google Health enablement and interval.</param>
/// <param name="logger">Structured logs without tokens.</param>
/// <remarks>
/// Satisfies ADR-0007: ingestion stays in-process. There is no HTTP sync endpoint.
/// The first cycle runs immediately after the host starts, then repeats on <see cref="GoogleHealthOptions.SyncInterval"/>.
/// </remarks>
public sealed class GoogleHealthSyncBackgroundService(
    IServiceScopeFactory scopeFactory,
    IOptions<GoogleHealthOptions> options,
    ILogger<GoogleHealthSyncBackgroundService> logger) : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory = scopeFactory;
    private readonly GoogleHealthOptions _options = options.Value;
    private readonly ILogger<GoogleHealthSyncBackgroundService> _logger = logger;

    /// <summary>
    /// Runs sync cycles until the host stops.
    /// </summary>
    /// <param name="stoppingToken">Host shutdown token.</param>
    /// <returns>A task that completes when the worker is cancelled.</returns>
    /// <remarks>
    /// A failed cycle is logged and does not stop later cycles. Cancellation ends the loop.
    /// </remarks>
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await SyncLinkedUsersAsync(stoppingToken);
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
            {
                break;
            }
            catch (Exception exception)
            {
                _logger.LogError(exception, "Google Health background sync cycle failed.");
            }

            try
            {
                await Task.Delay(ResolveInterval(), stoppingToken);
            }
            catch (OperationCanceledException)
            {
                break;
            }
        }
    }

    /// <summary>
    /// Lists linked accounts and dispatches <see cref="SyncGoogleHealthReadingsCommand"/> per user.
    /// </summary>
    /// <param name="cancellationToken">Cancellation token for the current cycle.</param>
    /// <returns>A task that completes when every linked user has been attempted.</returns>
    /// <remarks>
    /// Skips work when sync is disabled. One user's failure does not prevent the remaining users.
    /// Called by the hosted loop and by unit tests.
    /// </remarks>
    public async Task SyncLinkedUsersAsync(CancellationToken cancellationToken)
    {
        if (!_options.Enabled)
        {
            _logger.LogDebug("Google Health background sync is disabled.");
            return;
        }

        using var scope = _scopeFactory.CreateScope();
        var linkRepository = scope.ServiceProvider.GetRequiredService<IGoogleHealthLinkRepository>();
        var sender = scope.ServiceProvider.GetRequiredService<ISender>();

        IReadOnlyList<GoogleHealthLink> links;
        try
        {
            links = await linkRepository.ListAllAsync(cancellationToken);
        }
        catch (Exception exception)
        {
            _logger.LogError(exception, "Failed to list Google Health links.");
            return;
        }

        foreach (var link in links)
        {
            if (cancellationToken.IsCancellationRequested)
            {
                break;
            }

            try
            {
                var result = await sender.Send(
                    new SyncGoogleHealthReadingsCommand(link.UserId),
                    cancellationToken);

                if (result.IsFailure)
                {
                    var message = result.Errors.Count > 0
                        ? result.Errors[0].Message
                        : "Unknown error.";
                    _logger.LogWarning(
                        "Google Health sync did not complete for user {UserId}: {Error}",
                        link.UserId,
                        message);
                    continue;
                }

                _logger.LogInformation(
                    "Google Health sync imported {ImportedCount} and skipped {SkippedCount} readings for user {UserId}.",
                    result.Value!.ImportedCount,
                    result.Value.SkippedCount,
                    link.UserId);
            }
            catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested)
            {
                throw;
            }
            catch (Exception exception)
            {
                _logger.LogError(
                    exception,
                    "Google Health sync failed for user {UserId}.",
                    link.UserId);
            }
        }
    }

    /// <summary>
    /// Resolves the wait between sync cycles.
    /// </summary>
    /// <returns>Configured interval, or one second when the configured value is below one second.</returns>
    /// <remarks>
    /// Prevents a tight loop if configuration sets a zero interval.
    /// </remarks>
    private TimeSpan ResolveInterval()
    {
        return _options.SyncInterval < TimeSpan.FromSeconds(1)
            ? TimeSpan.FromSeconds(1)
            : _options.SyncInterval;
    }
}
