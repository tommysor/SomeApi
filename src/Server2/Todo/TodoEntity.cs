using Azure;
using Azure.Data.Tables;

namespace Server2.Todo
{
    public class TodoEntity : ITableEntity
    {
        public string PartitionKey { get; set; } = default!;
        public string RowKey { get; set; } = default!;
        public DateTimeOffset? Timestamp { get; set; }
        public ETag ETag { get; set; }

        public string Name { get; set; } = default!;
        public bool IsComplete { get; set; }
    }
}
