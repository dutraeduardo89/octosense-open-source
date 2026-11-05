namespace OctoSense.Domain.Results;

/// <summary>
/// Represents success or expected failure of an operation.
/// </summary>
/// <typeparam name="T">Payload type returned on success.</typeparam>
/// <remarks>
/// Handlers and endpoints return this type instead of throwing for validation and domain failures.
/// Unexpected exceptions remain the responsibility of the global exception handler.
/// </remarks>
public sealed class Result<T>
{
    /// <summary>
    /// Initializes a result instance.
    /// </summary>
    /// <param name="isSuccess">Whether the operation succeeded.</param>
    /// <param name="value">Payload when successful; otherwise default.</param>
    /// <param name="errors">Errors when failed; empty on success.</param>
    /// <remarks>
    /// Use <see cref="Success"/> and <see cref="Failure(Error)"/> factories. Do not mix success with errors.
    /// </remarks>
    private Result(bool isSuccess, T? value, IReadOnlyList<Error> errors)
    {
        IsSuccess = isSuccess;
        Value = value;
        Errors = errors;
    }

    /// <summary>
    /// Indicates that the operation completed successfully.
    /// </summary>
    public bool IsSuccess { get; }

    /// <summary>
    /// Indicates that the operation failed with expected errors.
    /// </summary>
    public bool IsFailure => !IsSuccess;

    /// <summary>
    /// Payload produced on success.
    /// </summary>
    /// <remarks>
    /// Null when <see cref="IsFailure"/> is true.
    /// </remarks>
    public T? Value { get; }

    /// <summary>
    /// Errors describing an expected failure.
    /// </summary>
    /// <remarks>
    /// Empty when <see cref="IsSuccess"/> is true.
    /// </remarks>
    public IReadOnlyList<Error> Errors { get; }

    /// <summary>
    /// Creates a successful result.
    /// </summary>
    /// <param name="value">Payload to return.</param>
    /// <returns>A successful <see cref="Result{T}"/>.</returns>
    /// <remarks>
    /// Endpoints map this to 2xx responses.
    /// </remarks>
    public static Result<T> Success(T value) => new(true, value, []);

    /// <summary>
    /// Creates a failed result from a single error.
    /// </summary>
    /// <param name="error">Failure description.</param>
    /// <returns>A failed <see cref="Result{T}"/>.</returns>
    /// <remarks>
    /// Convenience overload around <see cref="Failure(IReadOnlyList{Error})"/>.
    /// </remarks>
    public static Result<T> Failure(Error error) => new(false, default, [error]);

    /// <summary>
    /// Creates a failed result from one or more errors.
    /// </summary>
    /// <param name="errors">Failure descriptions.</param>
    /// <returns>A failed <see cref="Result{T}"/>.</returns>
    /// <remarks>
    /// Used by the validation pipeline when DotRValidator reports multiple failures.
    /// </remarks>
    public static Result<T> Failure(IReadOnlyList<Error> errors) => new(false, default, errors);
}
