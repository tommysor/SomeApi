using Microsoft.AspNetCore.Mvc;

namespace Server1.Controllers;

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
