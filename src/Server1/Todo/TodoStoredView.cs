using Azure;
using Azure.Data.Tables;

namespace Server1.Todo;

public class TodoStoredView : ITableEntity
{
    public Guid Id { get; set; }
    public string Name { get; set; } = default!;
    public bool IsComplete { get; set; }
    public string PartitionKey { get; set; } = default!;

    public string RowKey 
    { 
         get => Id.ToString();
         set => Id = Guid.Parse(value);
    }
    public DateTimeOffset? Timestamp { get; set; }
    public ETag ETag { get; set; }
}
