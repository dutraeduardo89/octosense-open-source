using DotRMediator;
using OctoSense.Domain.Results;

namespace OctoSense.Application.Features.Health.Queries.GetHealth;

/// <summary>
/// Query that reports API liveness.
/// </summary>
/// <remarks>
/// Dispatched by <c>GET /health</c>. Has no input and no validator.
/// </remarks>
public sealed record GetHealthQuery : IRequest<Result<HealthStatusResponse>>;
