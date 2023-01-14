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
        await _httpClient.PostAsJsonAsync("", item);
    }

    public async Task Update(Guid id, TodoUpdateDto item)
    {
        await _httpClient.PutAsJsonAsync($"{id}", item);
    }

    public async Task Delete(Guid id)
    {
        await _httpClient.DeleteAsync($"{id}");
    }
}
