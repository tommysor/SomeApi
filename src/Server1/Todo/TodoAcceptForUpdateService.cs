namespace Server1.Todo;

//todo Implement class TodoAcceptForUpdateService
public class TodoAcceptForUpdateService
{
    private readonly HttpClient _httpClient;

    public TodoAcceptForUpdateService(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task Create(TodoCreateDto item)
    {
        await _httpClient.PostAsJsonAsync("", item);
    }

    public async Task Update(long id, TodoUpdateDto item)
    {
        await Task.CompletedTask;
    }

    public async Task Delete(long id)
    {
        await Task.CompletedTask;
    }
}
