using Microsoft.AspNetCore.Mvc;

namespace Server2.Controllers;

[ApiController]
[Route("[controller]")]
[Produces("application/json")]
public class DaprController : Controller
{
    private readonly IConfiguration _configuration;

    public DaprController(IConfiguration configuration)
    {
        _configuration = configuration;
    }

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
        
        var pubSubComponentName = _configuration["PubSubComponentName"];
        var topic = _configuration["PubSubCreateTodoTopic"];
        var subscriptions = new []
        {
            new 
            {
                topic = topic,
                route = "AcceptForUpdate/AcceptForUpdate",
                pubsubName = pubSubComponentName
            }
        };

        return Ok(subscriptions);
    }
}
