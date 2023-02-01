using Azure.Data.Tables;
using Server2.Todo;

namespace Server2.Notifiers
{
    public class NotifyCreatedService : BackgroundService
    {
        private readonly TableClient _tableClient;
        private readonly ILogger<NotifyCreatedService> _logger;

        public NotifyCreatedService(TableClient tableClient, ILogger<NotifyCreatedService> logger)
        {
            _tableClient = tableClient;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            try
            {
                while (!stoppingToken.IsCancellationRequested)
                {
                    var query = _tableClient.QueryAsync<CreateNotifyEnitity>(x => x.PartitionKey == "notify", maxPerPage: 20, cancellationToken: stoppingToken);
                    var pages = query.AsPages();
                    
                    await foreach (var page in pages)
                    {
                        foreach (var item in page.Values)
                        {
                            var todo = new TodoView
                            {
                                Id = item.TodoId,
                                Name = item.TodoName,
                                IsComplete = item.TodoIsComplete
                            };

                            //todo publish to xxx
                            _logger.LogInformation("Publishing change: {Id}, {Name}, {IsCompleted}", todo.Id, todo.Name, todo.IsComplete);

                            var deleteAction = new TableTransactionAction(TableTransactionActionType.Delete, item);
                            await _tableClient.DeleteEntityAsync(item.PartitionKey, item.RowKey, item.ETag, stoppingToken);
                        }
                    }

                    await Task.Delay(1000, stoppingToken);
                }
            }
            catch (TaskCanceledException)
            {
                _logger.LogInformation("Stopping {Service}", nameof(NotifyCreatedService));
            }
            catch (Exception e)
            {
                _logger.LogError(e, "Error in {Service}", nameof(NotifyCreatedService));
                throw;
            }
        }
    }
}
