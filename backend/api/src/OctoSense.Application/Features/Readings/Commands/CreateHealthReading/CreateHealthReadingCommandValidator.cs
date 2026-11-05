using DotRValidator;
using OctoSense.Domain.Readings;

namespace OctoSense.Application.Features.Readings.Commands.CreateHealthReading;

/// <summary>
/// Validates input for <see cref="CreateHealthReadingCommand"/>.
/// </summary>
public sealed class CreateHealthReadingCommandValidator : IValidator<CreateHealthReadingCommand>
{
    public ValidationResult Validate(CreateHealthReadingCommand instance) => ValidateCore(instance);

    public ValidationResult Validate(ValidationContext<CreateHealthReadingCommand> context) =>
        ValidateCore(context.InstanceToValidate);

    public Task<ValidationResult> ValidateAsync(
        CreateHealthReadingCommand instance,
        CancellationToken cancellationToken = default
    ) => Task.FromResult(ValidateCore(instance));

    public Task<ValidationResult> ValidateAsync(
        ValidationContext<CreateHealthReadingCommand> context,
        CancellationToken cancellationToken = default
    ) => Task.FromResult(ValidateCore(context.InstanceToValidate));

    private static ValidationResult ValidateCore(CreateHealthReadingCommand instance)
    {
        var result = HealthReading.Create(
            instance.UserId,
            instance.DeviceId,
            instance.DeviceSource,
            instance.RecordedAt,
            instance.HeartRateBpm,
            instance.Steps,
            instance.SleepDuration,
            instance.OxygenSaturationPercent,
            instance.ActiveCaloriesKcal,
            instance.TotalCaloriesKcal,
            instance.SyncMode,
            instance.BatteryLevel,
            instance.ExternalId
        );

        if (result.IsSuccess)
        {
            return new ValidationResult();
        }

        var failures = result
            .Errors.Select(error => new ValidationFailure(
                error.PropertyName ?? string.Empty,
                error.Message
            ))
            .ToList();

        return new ValidationResult(failures);
    }
}
