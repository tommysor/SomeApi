using Server2;
using Microsoft.AspNetCore.Mvc.Testing;

namespace Server2.Tests.Systems;

public class BasicTests
{
    private void OverrideConfig(IWebHostBuilder builder)
    {
        builder.ConfigureAppConfiguration((context, config) =>
        {
            IEnumerable<KeyValuePair<string, string?>>? configValues = new []
            {
                new KeyValuePair<string, string?>("tableEndpoint", "https://localhost/TableEndpoint"),
                new KeyValuePair<string, string?>("tableName", "SomeTableName"),
            };
            config.AddInMemoryCollection(configValues);
        });
    }

    [Fact]
    public async Task Test1()
    {
        var host = new WebApplicationFactory<Server2.IServer2Marker>()
            .WithWebHostBuilder(builder =>
            {
                OverrideConfig(builder);
                builder.ConfigureServices(services =>
                {
                    services.AddTransient<Azure.Data.Tables.TableClient>(services =>
                    {
                        var tableClient = new Azure.Data.Tables.TableClient(new Uri("https://localhost/TableEndpoint"));
                        return tableClient;
                    });
                });
            });
        var client = host.CreateClient();

        var x = await client.GetAsync("/health");
        Assert.Equal(System.Net.HttpStatusCode.OK, x.StatusCode);

    }
}