namespace Server2;

public sealed class AcceptForUpdateDto
{
    public string Operation { get; set; } = default!;
    public Guid Id { get; set; }
    public string Body { get; set; } = default!;
}

