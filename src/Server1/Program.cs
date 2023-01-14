using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Server1;
using Server1.Todo;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddHealthChecks()
    .AddCheck("Hello", () => HealthCheckResult.Healthy("World"));

builder.Services.AddSingleton<ITelemetryInitializer>(new Server1TelemetryInitializer("Server1"));
builder.Services.AddApplicationInsightsTelemetry(options => 
{
    // options.ConnectionString = "InstrumentationKey=e0366b75-cc68-4e00-b245-5a576f4bddf9;IngestionEndpoint=https://norwayeast-0.in.applicationinsights.azure.com/;LiveEndpoint=https://norwayeast.livediagnostics.monitor.azure.com/";
});

builder.Services.AddTransient<TodoAcceptForUpdateService>();
builder.Services.AddTransient<TodoGetFromViewService>();

builder.Services.AddHttpClient<TodoAcceptForUpdateService>(client =>
{
    client.BaseAddress = new Uri("http://localhost:3500/v1.0/invoke/Server2/method/Todo");
});

var app = builder.Build();

// Configure the HTTP request pipeline.
// if (app.Environment.IsDevelopment())
// {
    app.UseSwagger();
    app.UseSwaggerUI();
// }

app.UseHealthChecks("/health");

app.MapControllers();

// Something to do with Dapr Actors?
app.MapGet("/dapr/config", () => new {});

app.Run();
