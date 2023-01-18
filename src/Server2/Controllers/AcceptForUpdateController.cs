using System.Buffers;
using System.Text;
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
    private readonly IHttpContextAccessor _httpContextAccessor;

    public AcceptForUpdateController(ILogger<AcceptForUpdateController> logger, IHttpContextAccessor httpContextAccessor)
    {
        _logger = logger;
        _httpContextAccessor = httpContextAccessor;
    }

    [HttpGet]
    public IActionResult Get()
    {
        return Ok();
    }

    [HttpPost("AcceptForUpdate")]
    [Topic("servicebus-pub-sub", "send-update-request")]
    public async Task<IActionResult> AcceptForUpdate([FromBody] dynamic item)
    {
        var context = _httpContextAccessor.HttpContext;
        var x = await context.Request.BodyReader.ReadAsync();
        var bytes = x.Buffer.ToArray();
        var x2 = Encoding.UTF8.GetString(bytes);
        _logger.LogInformation("AcceptForUpdate Body: {x2}", x2);

        // _logger.LogInformation("AcceptForUpdate: {item}", item);

        // var x1 = item.Body.ToArray();
        // var x2 = Encoding.UTF8.GetString(x1);
        // _logger.LogInformation("AcceptForUpdate Body: {x2}", x2);

        await Task.CompletedTask;
        return Accepted();
    }
}
