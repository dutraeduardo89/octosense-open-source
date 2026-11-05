using System.Diagnostics;
using DotRValidator;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;

namespace OctoSense.Api.Exceptions;

/// <summary>
/// Maps unhandled exceptions to RFC 7807 Problem Details.
/// </summary>
/// <param name="environment">Used to include exception details only in Development.</param>
/// <param name="logger">Logger for unexpected failures.</param>
/// <remarks>
/// Complements the Result pattern: expected validation and domain failures return Result,
/// unexpected exceptions reach this handler. <see cref="ValidationException"/> is mapped to HTTP 400.
/// </remarks>
public sealed class GlobalExceptionHandler(
    IHostEnvironment environment,
    ILogger<GlobalExceptionHandler> logger) : IExceptionHandler
{
    /// <summary>
    /// Fallback message logged and returned for unexpected exceptions.
    /// </summary>
    /// <remarks>
    /// English log text required by project standards.
    /// </remarks>
    private const string UnhandledExceptionMessage =
        "An unhandled exception has occurred while executing the request.";

    /// <summary>
    /// Host environment used to decide whether to expose exception details.
    /// </summary>
    /// <remarks>
    /// Development includes stack traces; other environments keep Problem Details generic.
    /// </remarks>
    private readonly IHostEnvironment _environment = environment;

    /// <summary>
    /// Logger that records unexpected exceptions once.
    /// </summary>
    /// <remarks>
    /// Validation exceptions log the validation message; others log the fallback text.
    /// </remarks>
    private readonly ILogger<GlobalExceptionHandler> _logger = logger;

    /// <summary>
    /// Writes a Problem Details body and marks the exception as handled.
    /// </summary>
    /// <param name="httpContext">Current HTTP context.</param>
    /// <param name="exception">Unhandled exception.</param>
    /// <param name="cancellationToken">Token used to cancel the response write.</param>
    /// <returns><see langword="true"/> after the response is written; <see langword="false"/> for cancellation.</returns>
    /// <remarks>
    /// <see cref="OperationCanceledException"/> is not handled so Kestrel can complete cooperative cancellation.
    /// </remarks>
    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext,
        Exception exception,
        CancellationToken cancellationToken)
    {
        if (exception is OperationCanceledException)
        {
            return false;
        }

        var statusCode = exception is ValidationException
            ? StatusCodes.Status400BadRequest
            : StatusCodes.Status500InternalServerError;

        _logger.LogError(
            exception,
            exception is ValidationException ? exception.Message : UnhandledExceptionMessage);

        httpContext.Response.StatusCode = statusCode;
        httpContext.Response.ContentType = "application/problem+json";

        var problem = CreateProblemDetails(httpContext, exception, statusCode);
        await httpContext.Response.WriteAsJsonAsync(problem, cancellationToken);
        return true;
    }

    /// <summary>
    /// Builds Problem Details for the current exception.
    /// </summary>
    /// <param name="httpContext">Current HTTP context.</param>
    /// <param name="exception">Unhandled exception.</param>
    /// <param name="statusCode">HTTP status assigned to the failure.</param>
    /// <returns>Problem Details payload.</returns>
    /// <remarks>
    /// Validation exceptions include property errors in <c>errors</c>. Development adds trace and detail.
    /// </remarks>
    private ProblemDetails CreateProblemDetails(
        HttpContext httpContext,
        Exception exception,
        int statusCode)
    {
        var problem = new ProblemDetails
        {
            Status = statusCode,
            Title = exception is ValidationException
                ? "One or more validation errors occurred."
                : UnhandledExceptionMessage,
            Type = "https://tools.ietf.org/html/rfc9110#section-15"
        };

        if (exception is ValidationException validationException)
        {
            problem.Extensions["errors"] = validationException.Result.Errors
                .GroupBy(failure => string.IsNullOrWhiteSpace(failure.PropertyName) ? "request" : failure.PropertyName)
                .ToDictionary(
                    group => group.Key,
                    group => group.Select(failure => failure.ErrorMessage).ToArray());
        }

        if (_environment.IsDevelopment())
        {
            problem.Detail = exception.ToString();
            problem.Extensions["traceId"] = Activity.Current?.Id ?? httpContext.TraceIdentifier;
        }

        return problem;
    }
}
