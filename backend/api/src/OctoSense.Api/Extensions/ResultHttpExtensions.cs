using Microsoft.AspNetCore.Mvc;
using OctoSense.Domain.Results;

namespace OctoSense.Api.Extensions;

/// <summary>
/// Maps <see cref="Result{T}"/> to ASP.NET Core <see cref="IResult"/>.
/// </summary>
/// <remarks>
/// Expected failures stay in Result. Unexpected exceptions are not converted here.
/// </remarks>
public static class ResultHttpExtensions
{
    /// <summary>
    /// Converts a Result into an HTTP result using a success factory.
    /// </summary>
    /// <typeparam name="T">Success payload type.</typeparam>
    /// <param name="result">Handler Result.</param>
    /// <param name="onSuccess">Builds the 2xx result from the payload.</param>
    /// <returns>Success IResult or a 400 Problem Details response.</returns>
    /// <remarks>
    /// Validation errors use the RFC 7807 <c>errors</c> extension. Other failures use title/detail.
    /// </remarks>
    public static IResult ToHttpResult<T>(
        this Result<T> result,
        Func<T, IResult> onSuccess)
    {
        return result.Match(onSuccess, ToFailureResult);
    }

    /// <summary>
    /// Converts Result errors into HTTP 400 Problem Details.
    /// </summary>
    /// <param name="errors">Errors from a failed Result.</param>
    /// <returns>An HTTP 400 Problem Details result.</returns>
    /// <remarks>
    /// Groups messages by property name when the error is a validation failure.
    /// </remarks>
    private static IResult ToFailureResult(IReadOnlyList<Error> errors)
    {
        var validationErrors = errors
            .Where(error => error.Code == Error.ValidationCode)
            .ToList();

        if (validationErrors.Count > 0)
        {
            var grouped = validationErrors
                .GroupBy(error => string.IsNullOrWhiteSpace(error.PropertyName) ? "request" : error.PropertyName!)
                .ToDictionary(
                    group => group.Key,
                    group => group.Select(error => error.Message).ToArray());

            return Results.ValidationProblem(grouped);
        }

        var problem = new ProblemDetails
        {
            Status = StatusCodes.Status400BadRequest,
            Title = "The request could not be processed.",
            Detail = errors.Count == 0
                ? "Unknown failure."
                : string.Join(" ", errors.Select(error => error.Message))
        };

        return Results.Json(problem, statusCode: StatusCodes.Status400BadRequest);
    }
}
