using Azure.Data.Tables;
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

builder.Services.AddHttpClient<TodoAcceptForUpdateService>(client =>
{
    client.BaseAddress = new Uri("http://localhost:3500/v1.0/invoke/Server2/method/Todo");
});

builder.Services.AddTransient<TableClient>(services =>
{
    var configuration = services.GetRequiredService<IConfiguration>();
    var tableEndpoint = configuration["env1"];
    var logger = services.GetRequiredService<ILogger<TableClient>>();
    logger.LogInformation("Table endpoint: {tableEndpoint}", tableEndpoint);

    var connectionString = "DefaultEndpointsProtocol=https;AccountName=storage1qy2refqyi3cd4;AccountKey=T2GoXTm2Ah7DS8m0ISjBpqgwhKTCsH1fADetKDMhyQC8x0QufDnpJyutXsnmwoRp2PeOcR3IgdOF+AStMp1cqg==;EndpointSuffix=core.windows.net";
    var tableName = "TodoView";
    var tableClient = new TableClient(connectionString, tableName);
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

// Something to do with Dapr Actors?
app.MapGet("/dapr/config", () => new {});

app.Run();
