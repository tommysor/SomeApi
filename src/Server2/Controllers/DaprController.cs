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

    [HttpGet]
    [Route("subscribe")]
    public IActionResult Subscribe()
    {
        /*
         * https://docs.dapr.io/developing-applications/sdks/dotnet/dotnet-troubleshooting/dotnet-troubleshooting-pubsub/
        [
            {"topic":"deposit","route":"deposit","pubsubName":"pubsub"},
            {"topic":"withdraw","route":"withdraw","pubsubName":"pubsub"}
        ]
        */
        var subscriptions = new []
        {
            new 
            {
                topic = "send-update-request",
                route = "AcceptForUpdate/AcceptForUpdate",
                pubsubName = "servicebus-pub-sub"
            }
        };

        return Ok(subscriptions);
    }
}
