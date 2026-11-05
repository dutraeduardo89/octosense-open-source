using DotRMediator;
using Microsoft.AspNetCore.Mvc;

namespace OctoSense.Api.Controllers;

/// <summary>
/// Base controller that exposes the DotRMediator sender.
/// </summary>
/// <param name="sender">Application sender used to dispatch commands and queries.</param>
/// <remarks>
/// Feature controllers inherit this type so HTTP stays thin and CQRS lives in Application.
/// </remarks>
[ApiController]
public abstract class BaseApiController(ISender sender) : ControllerBase
{
    /// <summary>
    /// Sender used to dispatch CQRS requests.
    /// </summary>
    /// <remarks>
    /// Resolved from DI. Do not send HTTP-specific types through this port.
    /// </remarks>
    protected ISender Sender { get; } = sender;
}
