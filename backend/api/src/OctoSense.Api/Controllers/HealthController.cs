using DotRMediator;
using Microsoft.AspNetCore.Mvc;
using OctoSense.Api.Extensions;
using OctoSense.Application.Features.Health.Queries.GetHealth;

namespace OctoSense.Api.Controllers;

/// <summary>
/// HTTP adapter for API liveness.
/// </summary>
/// <param name="sender">Application sender used to dispatch <see cref="GetHealthQuery"/>.</param>
/// <remarks>
/// Maps <c>GET /health</c> to the health query. Does not probe MongoDB.
/// </remarks>
[Route("health")]
public sealed class HealthController(ISender sender) : BaseApiController(sender)
{
    /// <summary>
    /// Returns the process liveness payload.
    /// </summary>
    /// <param name="cancellationToken">Token used to cancel the query.</param>
    /// <returns>HTTP 200 with <see cref="HealthStatusResponse"/> on success.</returns>
    /// <remarks>
    /// Failures travel through <c>Result</c> or the global exception handler.
    /// </remarks>
    [HttpGet]
    [ProducesResponseType(typeof(HealthStatusResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IResult> GetAsync(CancellationToken cancellationToken)
    {
        var result = await Sender.Send(new GetHealthQuery(), cancellationToken);
        return result.ToHttpResult(status => TypedResults.Ok(status));
    }
}
