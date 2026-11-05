namespace OctoSense.Domain.Results;

/// <summary>
/// Describes a failed operation without throwing.
/// </summary>
/// <remarks>
/// Used by <see cref="Result{T}"/> for expected failures such as validation.
/// Unexpected failures still travel through the global exception handler.
/// </remarks>
public sealed record Error
{
    /// <summary>
    /// Code assigned to validation failures.
    /// </summary>
    public const string ValidationCode = "Validation";

    /// <summary>
    /// Code assigned to generic domain or application failures.
    /// </summary>
    public const string FailureCode = "Failure";

    /// <summary>
    /// Initializes a structured error.
    /// </summary>
    /// <param name="code">Stable machine-readable code.</param>
    /// <param name="message">Human-readable description in English.</param>
    /// <param name="propertyName">Optional property that caused the failure.</param>
    /// <remarks>
    /// Prefer factory methods <see cref="Validation"/> and <see cref="Failure(string)"/> over calling this constructor directly.
    /// </remarks>
    private Error(string code, string message, string? propertyName)
    {
        Code = code;
        Message = message;
        PropertyName = propertyName;
    }

    /// <summary>
    /// Machine-readable error category.
    /// </summary>
    public string Code { get; }

    /// <summary>
    /// Human-readable description in English.
    /// </summary>
    public string Message { get; }

    /// <summary>
    /// Property associated with a validation failure, when applicable.
    /// </summary>
    public string? PropertyName { get; }

    /// <summary>
    /// Creates a validation error bound to a property.
    /// </summary>
    /// <param name="propertyName">Name of the invalid property.</param>
    /// <param name="message">Validation message in English.</param>
    /// <returns>A validation <see cref="Error"/>.</returns>
    /// <remarks>
    /// Mapped to HTTP 400 by API Result adapters.
    /// </remarks>
    public static Error Validation(string propertyName, string message) =>
        new(ValidationCode, message, propertyName);

    /// <summary>
    /// Creates a generic failure without a property.
    /// </summary>
    /// <param name="message">Failure message in English.</param>
    /// <returns>A failure <see cref="Error"/>.</returns>
    /// <remarks>
    /// Use for domain guards that are not field-specific.
    /// </remarks>
    public static Error Failure(string message) =>
        new(FailureCode, message, null);
}
