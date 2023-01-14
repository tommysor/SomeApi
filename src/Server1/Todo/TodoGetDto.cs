namespace Server1.Todo;

public class TodoGetDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = default!;
    public bool IsComplete { get; set; }
}
