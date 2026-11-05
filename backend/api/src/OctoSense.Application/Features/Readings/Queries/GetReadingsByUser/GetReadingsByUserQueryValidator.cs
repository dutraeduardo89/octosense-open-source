using DotRValidator;

namespace OctoSense.Application.Features.Readings.Queries.GetReadingsByUser;

/// <summary>
/// Validates the user id for reading queries.
/// </summary>
public sealed class GetReadingsByUserQueryValidator : IValidator<GetReadingsByUserQuery>
{
    public ValidationResult Validate(GetReadingsByUserQuery instance) => ValidateCore(instance);

    public ValidationResult Validate(ValidationContext<GetReadingsByUserQuery> context) =>
        ValidateCore(context.InstanceToValidate);

    public Task<ValidationResult> ValidateAsync(
        GetReadingsByUserQuery instance,
        CancellationToken cancellationToken = default
    ) => Task.FromResult(ValidateCore(instance));

    public Task<ValidationResult> ValidateAsync(
        ValidationContext<GetReadingsByUserQuery> context,
        CancellationToken cancellationToken = default
    ) => Task.FromResult(ValidateCore(context.InstanceToValidate));

    private static ValidationResult ValidateCore(GetReadingsByUserQuery instance)
    {
        if (string.IsNullOrWhiteSpace(instance.UserId))
        {
            return new ValidationResult([
                new ValidationFailure(nameof(instance.UserId), "UserId is required."),
            ]);
        }

        return new ValidationResult();
    }
}
