using Microsoft.AspNetCore.Mvc;

namespace Server2.Controllers;

[ApiController]
[Route("/Readiness")]
[Produces("application/json")]
public class ReadinessController : Controller
{
    [HttpGet]
    public IActionResult Get()
    {
        return Ok();
    }
}
