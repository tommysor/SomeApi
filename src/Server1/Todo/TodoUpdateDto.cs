namespace Server1.Todo;

public class TodoUpdateDto
{
    public string Name { get; set; } = default!;
    public bool IsComplete { get; set; }
}
