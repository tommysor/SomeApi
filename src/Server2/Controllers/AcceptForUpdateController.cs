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
    private readonly SaveChangeService _saveChangeService;

    public AcceptForUpdateController(ILogger<AcceptForUpdateController> logger, IHttpContextAccessor httpContextAccessor, SaveChangeService saveChangeService)
    {
        _logger = logger;
        _httpContextAccessor = httpContextAccessor;
        _saveChangeService = saveChangeService;
    }

    [HttpGet]
    public IActionResult Get()
    {
        return Ok();
    }

    [HttpPost("AcceptForUpdate")]
    public async Task<IActionResult> AcceptForUpdate([FromBody] AcceptForUpdateDto item, CancellationToken cancellationToken)
    {
        var data = item.Data;
        if (data is null)
            return BadRequest(new { ErrorMessage = "Data is null"});
        _logger.LogInformation("AcceptForUpdate: {item}", data.Name);

        var context = _httpContextAccessor.HttpContext;
        if (context is not null)
        {
            var requestTelemetry = context.Features.Get<RequestTelemetry>();
            requestTelemetry?.Properties.Add("BodyDataName", data.Name);
        }

        await _saveChangeService.Create(data, cancellationToken);
        return Accepted();
    }
}
