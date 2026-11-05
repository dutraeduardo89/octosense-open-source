using DotRMediator;
using OctoSense.Domain.Results;

namespace OctoSense.Application.Features.GoogleHealth.Commands.SyncGoogleHealthReadings;

/// <summary>
/// Imports Google Health readings for a single user.
/// </summary>
/// <param name="UserId">Owner user id.</param>
public sealed record SyncGoogleHealthReadingsCommand(string UserId)
    : IRequest<Result<SyncGoogleHealthReadingsResult>>;
