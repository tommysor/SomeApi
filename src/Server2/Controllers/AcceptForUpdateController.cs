using Azure.Messaging.ServiceBus;
using Dapr;
using Microsoft.AspNetCore.Mvc;

namespace Server2.Controllers;

[ApiController]
[Route("/AcceptForUpdate")]
[Produces("application/json")]
public class AcceptForUpdateController : Controller
{
    private readonly ILogger<AcceptForUpdateController> _logger;

    public AcceptForUpdateController(ILogger<AcceptForUpdateController> logger)
    {
        _logger = logger;
    }

    [HttpGet]
    public IActionResult Get()
    {
        return Ok();
    }

    [HttpPost("AcceptForUpdate")]
    [Topic("servicebus-pub-sub", "send-update-request")]
    public async Task<IActionResult> AcceptForUpdate([FromBody] ProcessMessageEventArgs item)
    {
        _logger.LogInformation("AcceptForUpdate: {item}", item);
        await Task.CompletedTask;
        return Accepted();
    }
}
