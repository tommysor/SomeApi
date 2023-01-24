using Microsoft.ApplicationInsights.DataContracts;
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
builder.Services.AddApplicationInsightsTelemetry();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHealthChecks("/health");

app.Use(async (context, next) =>
{
    var requestTelemetry = context.Features.Get<RequestTelemetry>();
    requestTelemetry?.Properties.Add("Path", context.Request.Path);
    Console.WriteLine($"Path: {context.Request.Path}");
    requestTelemetry?.Properties.Add("Method", context.Request.Method);
    Console.WriteLine($"Method: {context.Request.Method}");
    requestTelemetry?.Properties.Add("QueryString", context.Request.QueryString.ToString());
    Console.WriteLine($"QueryString: {context.Request.QueryString}");
    foreach (var header in context.Request.Headers)
    {
        requestTelemetry?.Properties.Add($"Header {header.Key}", header.Value);
        Console.WriteLine($"Header {header.Key}: {header.Value}");
    }

    if (context.Request.Method == "POST")
    {
        var memStream = new MemoryStream();
        await context.Request.Body.CopyToAsync(memStream, 81920, context.RequestAborted);
        memStream.Flush();
        memStream.Position = 0;
        var body = await new StreamReader(memStream).ReadToEndAsync();
        requestTelemetry?.Properties.Add("RequestBody", body);
        Console.WriteLine($"RequestBody: {body}");

        memStream.Position = 0;
        context.Request.Body = memStream;
    }
    await next();
});

app.MapControllers();

app.Run();
