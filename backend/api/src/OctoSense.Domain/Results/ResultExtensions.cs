namespace OctoSense.Domain.Results;

/// <summary>
/// Functional helpers for <see cref="Result{T}"/>.
/// </summary>
/// <remarks>
/// Keep branching out of handlers and endpoints by matching success and failure explicitly.
/// </remarks>
public static class ResultExtensions
{
    /// <summary>
    /// Maps a result to another type.
    /// </summary>
    /// <typeparam name="TIn">Input payload type.</typeparam>
    /// <typeparam name="TOut">Mapped payload or return type.</typeparam>
    /// <param name="result">Source result.</param>
    /// <param name="onSuccess">Invoked when <paramref name="result"/> succeeded.</param>
    /// <param name="onFailure">Invoked when <paramref name="result"/> failed.</param>
    /// <returns>The value produced by the matching callback.</returns>
    /// <remarks>
    /// Used by HTTP adapters to convert Result into <c>IResult</c>.
    /// </remarks>
    public static TOut Match<TIn, TOut>(
        this Result<TIn> result,
        Func<TIn, TOut> onSuccess,
        Func<IReadOnlyList<Error>, TOut> onFailure)
    {
        return result.IsSuccess
            ? onSuccess(result.Value!)
            : onFailure(result.Errors);
    }
}
