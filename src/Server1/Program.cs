using Azure.Data.Tables;
using Azure.Identity;
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
builder.Services.AddApplicationInsightsTelemetry();

builder.Services.AddTransient<TodoAcceptForUpdateService>();
builder.Services.AddTransient<TodoGetFromViewService>();

builder.Services.AddHttpClient<TodoAcceptForUpdateService>((services, client) =>
{
    var configuration = services.GetRequiredService<IConfiguration>();
    var endpoint = configuration["SaveChangeEndpoint"]!;
    client.BaseAddress = new Uri(endpoint);
});

builder.Services.AddTransient<TableClient>(services =>
{
    var configuration = services.GetRequiredService<IConfiguration>();
    var tableEndpoint = configuration["tableEndpoint"]!;
    var logger = services.GetRequiredService<ILogger<TableClient>>();
    logger.LogInformation("Table endpoint: {tableEndpoint}", tableEndpoint);

    var tableName = "TodoView";
    var tableClient = new TableClient(new Uri(tableEndpoint), tableName, new DefaultAzureCredential());
    tableClient.CreateIfNotExists();
    return tableClient;
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

app.Run();
