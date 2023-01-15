using Microsoft.AspNetCore.Mvc;

namespace Server2.Controllers;

[ApiController]
[Route("[controller]")]
[Produces("application/json")]
public class DaprController : Controller
{
    [HttpGet]
    [Route("config")]
    public IActionResult Get()
    {
        // Something to do with Dapr Actors?
        return Ok();
    }
}
