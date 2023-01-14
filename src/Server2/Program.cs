using Microsoft.ApplicationInsights.Extensibility;
using Server2;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddHealthChecks();

builder.Services.AddSingleton<ITelemetryInitializer>(new Server2TelemetryInitializer("Server2"));
builder.Services.AddApplicationInsightsTelemetry(options => 
{
    options.ConnectionString = "InstrumentationKey=e0366b75-cc68-4e00-b245-5a576f4bddf9;IngestionEndpoint=https://norwayeast-0.in.applicationinsights.azure.com/;LiveEndpoint=https://norwayeast.livediagnostics.monitor.azure.com/";
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHealthChecks("/health");

app.MapControllers();

app.Run();
