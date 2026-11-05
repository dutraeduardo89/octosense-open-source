using OctoSense.Domain.Results;

namespace OctoSense.Application.Features.Feedback;

public interface IFeedbackService
{
    Task<Result<FeedbackResponse>> GenerateAsync(
        string userId,
        string period,
        CancellationToken cancellationToken = default);
}

public sealed record FeedbackResponse(
    string Insight,
    string Period,
    DateTimeOffset GeneratedAt);
