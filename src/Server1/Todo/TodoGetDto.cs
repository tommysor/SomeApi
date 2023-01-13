namespace Server1.Todo;

public class TodoGetDto
{
    public int Id { get; set; }
    public string Name { get; set; } = default!;
    public bool IsComplete { get; set; }
}
