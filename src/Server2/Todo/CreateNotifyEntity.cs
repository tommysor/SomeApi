using Azure;
using Azure.Data.Tables;

namespace Server2.Todo;

public class CreateNotifyEnitity : ITableEntity
{
    public string PartitionKey { get; set; } = default!;
    public string RowKey { get; set; } = default!;
    public DateTimeOffset? Timestamp { get; set; }
    public ETag ETag { get; set; }

    public Guid TodoId { get; set; } = default!;
    public string TodoName { get; set; } = default!;
    public bool TodoIsComplete { get; set; }
}
