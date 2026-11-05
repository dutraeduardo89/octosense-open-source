using DotRMediator;
using DotRValidator;
using OctoSense.Domain.Results;

namespace OctoSense.Application.Common.Behaviors;

/// <summary>
/// Runs DotRValidator rules before a handler and returns <see cref="Result{T}"/> failures without throwing.
/// </summary>
/// <typeparam name="TRequest">Request flowing through the pipeline.</typeparam>
/// <typeparam name="TResponse">Handler response type, typically <see cref="Result{T}"/>.</typeparam>
/// <remarks>
/// Expected validation failures become Result errors. If the response is not a Result, a <see cref="ValidationException"/> is thrown for the global exception handler.
/// </remarks>
/// <param name="validators">Validators registered for <typeparamref name="TRequest"/>.</param>
public sealed class ValidationBehavior<TRequest, TResponse>(
    IEnumerable<IValidator<TRequest>> validators)
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : notnull
{
    /// <summary>
    /// Validators that apply to the current request type.
    /// </summary>
    /// <remarks>
    /// Empty sequence skips validation and invokes the next pipeline step.
    /// </remarks>
    private readonly IEnumerable<IValidator<TRequest>> _validators = validators;

    /// <summary>
    /// Validates the request, then continues the pipeline.
    /// </summary>
    /// <param name="request">Incoming command or query.</param>
    /// <param name="next">Next pipeline delegate, ending at the handler.</param>
    /// <param name="cancellationToken">Token used to cancel async validation.</param>
    /// <returns>A Result failure, a thrown <see cref="ValidationException"/>, or the handler response.</returns>
    /// <remarks>
    /// Multiple validators run sequentially. Failures are flattened into a single Result or exception.
    /// </remarks>
    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken)
    {
        var validatorList = _validators.ToList();
        if (validatorList.Count == 0)
        {
            return await next();
        }

        var failures = new List<ValidationFailure>();
        foreach (var validator in validatorList)
        {
            var result = await validator.ValidateAsync(request, cancellationToken);
            failures.AddRange(result.Errors);
        }

        if (failures.Count == 0)
        {
            return await next();
        }

        var errors = failures
            .Select(failure => Error.Validation(failure.PropertyName, failure.ErrorMessage))
            .ToList();

        if (typeof(TResponse).IsGenericType
            && typeof(TResponse).GetGenericTypeDefinition() == typeof(Result<>))
        {
            var valueType = typeof(TResponse).GetGenericArguments()[0];
            var failureMethod = typeof(Result<>)
                .MakeGenericType(valueType)
                .GetMethod(nameof(Result<object>.Failure), [typeof(IReadOnlyList<Error>)])
                ?? throw new InvalidOperationException("Result.Failure(IReadOnlyList<Error>) was not found.");

            return (TResponse)failureMethod.Invoke(null, [errors])!;
        }

        throw new ValidationException(new ValidationResult(failures));
    }
}
