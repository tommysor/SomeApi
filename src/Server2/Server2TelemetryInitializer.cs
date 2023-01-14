using Microsoft.ApplicationInsights.Channel;
using Microsoft.ApplicationInsights.Extensibility;

namespace Server2;

public class Server2TelemetryInitializer : ITelemetryInitializer
{
    private readonly string _cloudRoleName;

    public Server2TelemetryInitializer(string cloudRoleName)
    {
        _cloudRoleName = cloudRoleName;
    }

    public void Initialize(ITelemetry telemetry)
    {
        telemetry.Context.Cloud.RoleName = _cloudRoleName;
    }
}
