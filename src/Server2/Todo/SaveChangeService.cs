using Azure.Data.Tables;

namespace Server2.Todo
{
    public class SaveChangeService
    {
        private readonly TableClient _tableClient;

        public SaveChangeService(TableClient tableClient)
        {
            _tableClient = tableClient;
        }

        public async Task Create(TodoCreateDto item, CancellationToken cancellationToken)
        {
            var todo = new TodoEntity
            {
                PartitionKey = "todo",
                RowKey = Guid.NewGuid().ToString(),
                Name = item.Name,
                IsComplete = false
            };
            var addAction = new TableTransactionAction(TableTransactionActionType.Add, todo);

            var notify = new CreateNotifyEnitity
            {
                PartitionKey = "notify",
                RowKey = Guid.NewGuid().ToString(),
                TodoId = Guid.Parse(todo.RowKey),
                TodoName = todo.Name,
                TodoIsComplete = todo.IsComplete
            };
            var addNotifyCreatedAction = new TableTransactionAction(TableTransactionActionType.Add, notify);

            // odata.error":{"code":"CommandsInBatchActOnDifferentPartitions"
            // var actions = new [] { addAction, addNotifyCreatedAction };
            // await _tableClient.SubmitTransactionAsync(actions, cancellationToken);

            await _tableClient.AddEntityAsync(todo, cancellationToken);
            await _tableClient.AddEntityAsync(notify, cancellationToken);
        }
    }
}
