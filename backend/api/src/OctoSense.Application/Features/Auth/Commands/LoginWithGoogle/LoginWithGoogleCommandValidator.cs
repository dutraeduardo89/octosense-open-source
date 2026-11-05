using DotRValidator;

namespace OctoSense.Application.Features.Auth.Commands.LoginWithGoogle;

/// <summary>
/// Validates input for <see cref="LoginWithGoogleCommand"/>.
/// </summary>
public sealed class LoginWithGoogleCommandValidator : IValidator<LoginWithGoogleCommand>
{
    public ValidationResult Validate(LoginWithGoogleCommand instance) => ValidateCore(instance);

    public ValidationResult Validate(ValidationContext<LoginWithGoogleCommand> context) =>
        ValidateCore(context.InstanceToValidate);

    public Task<ValidationResult> ValidateAsync(
        LoginWithGoogleCommand instance,
        CancellationToken cancellationToken = default
    ) => Task.FromResult(ValidateCore(instance));

    public Task<ValidationResult> ValidateAsync(
        ValidationContext<LoginWithGoogleCommand> context,
        CancellationToken cancellationToken = default
    ) => Task.FromResult(ValidateCore(context.InstanceToValidate));

    private static ValidationResult ValidateCore(LoginWithGoogleCommand instance)
    {
        var failures = new List<ValidationFailure>();

        if (string.IsNullOrWhiteSpace(instance.IdToken))
        {
            failures.Add(new ValidationFailure(nameof(instance.IdToken), "IdToken is required."));
        }

        return new ValidationResult(failures);
    }
}
