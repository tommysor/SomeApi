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

var appName = builder.Configuration["appName"] ?? nameof(Server1);
builder.Services.AddSingleton<ITelemetryInitializer>(new Server1TelemetryInitializer(appName));
builder.Services.AddApplicationInsightsTelemetry();

builder.Services.AddTransient<TodoAcceptForUpdateService>();
builder.Services.AddTransient<TodoGetFromViewService>();

builder.Services.AddHttpClient<TodoAcceptForUpdateService>((services, client) =>
{
    var logger = services.GetRequiredService<ILogger<TodoAcceptForUpdateService>>();
    var configuration = services.GetRequiredService<IConfiguration>();
    var endpoint = configuration["createTodoPublishUrl"]!;
    logger.LogInformation("Publish endpoint: {endpoint}", endpoint);
    client.BaseAddress = new Uri(endpoint);
});

builder.Services.AddTransient<TableClient>(services =>
{
    var configuration = services.GetRequiredService<IConfiguration>();
    var tableEndpoint = configuration["tableEndpoint"]!;
    var tableName = configuration["tableName"]!;
    var logger = services.GetRequiredService<ILogger<TableClient>>();
    logger.LogInformation("Table endpoint: {tableEndpoint} name: {tableName}", tableEndpoint, tableName);

    var tableClient = new TableClient(new Uri(tableEndpoint), tableName, new DefaultAzureCredential());
    return tableClient;
});

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.UseHealthChecks("/health");

app.MapControllers();

app.Run();
