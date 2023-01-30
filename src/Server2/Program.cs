using Azure.Data.Tables;
using Azure.Identity;
using Microsoft.ApplicationInsights.Extensibility;
using Server2;
using Server2.Notifiers;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddHealthChecks();

var appName = builder.Configuration["appName"] ?? nameof(Server2);
builder.Services.AddSingleton<ITelemetryInitializer>(new Server2TelemetryInitializer(appName));
builder.Services.AddApplicationInsightsTelemetry();

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

builder.Services.AddHostedService<NotifyCreatedService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    app.Map("/", (context) => 
    {
        context.Response.Redirect("/swagger");
        return Task.CompletedTask;
    });
}

app.UseHealthChecks("/health");

app.MapControllers();

app.Run();
