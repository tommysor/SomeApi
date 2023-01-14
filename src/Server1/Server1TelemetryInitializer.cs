using Microsoft.ApplicationInsights.Channel;
using Microsoft.ApplicationInsights.Extensibility;

namespace Server1;

public class Server1TelemetryInitializer : ITelemetryInitializer
{
    private readonly string _cloudRoleName;

    public Server1TelemetryInitializer(string cloudRoleName)
    {
        _cloudRoleName = cloudRoleName;
    }

    public void Initialize(ITelemetry telemetry)
    {
        telemetry.Context.Cloud.RoleName = _cloudRoleName;
    }
}
