namespace Server1.Todo;

public class TodoAcceptForUpdateService
{
    private readonly HttpClient _httpClient;

    public TodoAcceptForUpdateService(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task Create(TodoCreateDto item)
    {
        var response = await _httpClient.PostAsJsonAsync("", item);
        response.EnsureSuccessStatusCode();
    }

    public async Task Update(Guid id, TodoUpdateDto item)
    {
        var message = new 
        {
            Operation = "Update",
            Id = id,
            Body = item
        };
        var response = await _httpClient.PostAsJsonAsync("", message);
        response.EnsureSuccessStatusCode();
    }

    public async Task Delete(Guid id)
    {
        var message = new 
        {
            Operation = "Delete",
            Id = id,
            Body = new{}
        };
        var response = await _httpClient.PostAsJsonAsync("", message);
        response.EnsureSuccessStatusCode();
    }
}
