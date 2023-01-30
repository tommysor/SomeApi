namespace Server2.Todo;

public sealed class TodoView
{
    public Guid Id { get; set; } = default!;
    public string Name { get; set; } = default!;
    public bool IsComplete { get; set; }
}
