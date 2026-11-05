using DotRMediator;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OctoSense.Api.Extensions;
using OctoSense.Application.Features.Readings.Commands.CreateHealthReading;
using OctoSense.Application.Features.Readings.Queries.GetDailySummary;
using OctoSense.Application.Features.Readings.Queries.GetReadingsByUser;
using OctoSense.Application.Features.Feedback;
using OctoSense.Domain.Readings;

namespace OctoSense.Api.Controllers;

/// <summary>
/// HTTP adapter for health reading ingestion, listing and aggregated summaries.
/// </summary>
/// <param name="sender">Application sender used to dispatch reading commands and queries.</param>
/// <remarks>
/// Todas as rotas exigem JWT (ver <see cref="AuthorizeAttribute"/>).
/// O UserId usado nas operações é SEMPRE o email do JWT, nunca o informado
/// pelo cliente. Tentativas de acessar dados de outro usuário retornam 403.
/// </remarks>
[Authorize]
[Route("readings")]
public sealed class ReadingsController(ISender sender, IFeedbackService feedbackService) : BaseApiController(sender)
{
    /// <summary>
    /// Cria uma leitura para o usuário autenticado.
    /// </summary>
    /// <remarks>
    /// O campo UserId do body é IGNORADO e sobrescrito pelo email do JWT.
    /// Isso impede que um cliente autenticado grave dados em nome de outro.
    /// </remarks>
    [HttpPost]
    [ProducesResponseType(typeof(HealthReading), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IResult> CreateAsync(
        [FromBody] CreateHealthReadingCommand command,
        CancellationToken cancellationToken)
    {
        var authEmail = User.GetAuthenticatedEmail();
        if (string.IsNullOrWhiteSpace(authEmail))
        {
            return Results.Unauthorized();
        }

        var safeCommand = command with { UserId = authEmail };

        var result = await Sender.Send(safeCommand, cancellationToken);
        return result.ToHttpResult(reading =>
            TypedResults.Created($"/readings/{reading.RecordedAt}", reading));
    }

    /// <summary>
    /// Lista leituras do PRÓPRIO usuário autenticado.
    /// </summary>
    /// <remarks>
    /// 403 se o userId da URL divergir do email do JWT.
    /// </remarks>
    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<HealthReading>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IResult> ListByUserAsync(
        [FromQuery] string userId,
        CancellationToken cancellationToken)
    {
        var authEmail = User.GetAuthenticatedEmail();
        if (string.IsNullOrWhiteSpace(authEmail))
        {
            return Results.Unauthorized();
        }

        if (!string.Equals(userId, authEmail, StringComparison.OrdinalIgnoreCase))
        {
            return Results.Forbid();
        }

        var result = await Sender.Send(new GetReadingsByUserQuery(userId), cancellationToken);
        return result.ToHttpResult(readings => TypedResults.Ok(readings));
    }

    [HttpGet("feedback")]
    [ProducesResponseType(typeof(FeedbackResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IResult> GetFeedbackAsync(
        [FromQuery] string period = "7d",
        CancellationToken cancellationToken = default)
    {
        var authEmail = User.GetAuthenticatedEmail();
        if (string.IsNullOrWhiteSpace(authEmail))
        {
            return Results.Unauthorized();
        }

        var result = await feedbackService.GenerateAsync(authEmail, period, cancellationToken);
        return result.ToHttpResult(feedback => TypedResults.Ok(feedback));
    }

    /// <summary>
    /// Retorna sumário diário do PRÓPRIO usuário autenticado.
    /// </summary>
    /// <remarks>
    /// 403 se o userId da URL divergir do email do JWT.
    /// </remarks>
    [HttpGet("summary")]
    [ProducesResponseType(typeof(PeriodSummaryResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IResult> GetDailySummaryAsync(
        [FromQuery] string userId,
        [FromQuery] DateOnly from,
        [FromQuery] DateOnly to,
        CancellationToken cancellationToken)
    {
        var authEmail = User.GetAuthenticatedEmail();
        if (string.IsNullOrWhiteSpace(authEmail))
        {
            return Results.Unauthorized();
        }

        if (!string.Equals(userId, authEmail, StringComparison.OrdinalIgnoreCase))
        {
            return Results.Forbid();
        }

        var result = await Sender.Send(
            new GetDailySummaryQuery(userId, from, to),
            cancellationToken);

        return result.ToHttpResult(summary => TypedResults.Ok(summary));
    }
}
