using DotRMediator;
using OctoSense.Domain.Results;

namespace OctoSense.Application.Features.Health.Queries.GetHealth;

/// <summary>
/// Handles <see cref="GetHealthQuery"/>.
/// </summary>
/// <remarks>
/// Returns a successful Result when the host process is running. Persistence is not consulted.
/// </remarks>
public sealed class GetHealthQueryHandler
    : IRequestHandler<GetHealthQuery, Result<HealthStatusResponse>>
{
    /// <summary>
    /// Builds the liveness response.
    /// </summary>
    /// <param name="request">Empty health query.</param>
    /// <param name="cancellationToken">Unused cancellation token reserved for the handler contract.</param>
    /// <returns>A successful Result with <c>status: healthy</c>.</returns>
    /// <remarks>
    /// Failures for this query are unexpected and surface through the global exception handler.
    /// </remarks>
    public Task<Result<HealthStatusResponse>> Handle(
        GetHealthQuery request,
        CancellationToken cancellationToken)
    {
        var response = Result<HealthStatusResponse>.Success(new HealthStatusResponse("healthy"));
        return Task.FromResult(response);
    }
}
