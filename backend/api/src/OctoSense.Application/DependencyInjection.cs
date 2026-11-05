using DotRMediator.DependencyInjection;
using DotRValidator.DependencyInjection;
using Microsoft.Extensions.DependencyInjection;
using OctoSense.Application.Common.Behaviors;
using OctoSense.Application.Features.Readings.Commands.CreateHealthReading;

namespace OctoSense.Application;

/// <summary>
/// Registers application-layer CQRS services.
/// </summary>
/// <remarks>
/// Wires DotRMediator handlers, DotRValidator validators, and the validation pipeline behavior.
/// </remarks>
public static class DependencyInjection
{
    /// <summary>
    /// Adds mediator, validators, and pipeline behaviors from this assembly.
    /// </summary>
    /// <param name="services">DI collection of the composition root.</param>
    /// <returns>The same collection for chaining.</returns>
    /// <remarks>
    /// Call once from <c>Program.cs</c>. Handlers are discovered by assembly scan.
    /// </remarks>
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddValidatorsFromAssemblyContaining<CreateHealthReadingCommandValidator>();
        services.AddDotRMediator(configuration =>
        {
            configuration.RegisterServicesFromAssemblyContaining<CreateHealthReadingCommand>();
            configuration.AddOpenBehavior(typeof(ValidationBehavior<,>));
        });

        return services;
    }
}
