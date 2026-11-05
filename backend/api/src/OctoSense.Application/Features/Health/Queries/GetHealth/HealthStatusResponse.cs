namespace OctoSense.Application.Features.Health.Queries.GetHealth;

/// <summary>
/// Liveness payload returned by <see cref="GetHealthQuery"/>.
/// </summary>
/// <param name="Status">Status token. Always <c>healthy</c> when the process can answer.</param>
/// <remarks>
/// Does not probe MongoDB. Readiness is out of scope.
/// </remarks>
public sealed record HealthStatusResponse(string Status);
