using Dapr;
using Microsoft.ApplicationInsights.DataContracts;
using Microsoft.AspNetCore.Mvc;
using Server2.Todo;

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
    public async Task<IActionResult> AcceptForUpdate([FromBody] AcceptForUpdateDto item)
    {
        var data = item.Data;
        _logger.LogInformation("AcceptForUpdate: {item}", data?.Name);

        var context = _httpContextAccessor.HttpContext;
        if (context is not null)
        {
            var requestTelemetry = context.Features.Get<RequestTelemetry>();
            requestTelemetry?.Properties.Add("BodyDataName", data?.Name);
        }

        await Task.CompletedTask;
        return Accepted();
    }
}
