using Azure.Data.Tables;

namespace Server1.Todo;

//todo Implement class TodoGetFromViewService
public class TodoGetFromViewService
{
    private readonly TableClient _tableClient;

    public TodoGetFromViewService(TableClient tableClient)
    {
        _tableClient = tableClient;
    }

    public async Task<IList<TodoGetDto>> GetAll(CancellationToken cancellationToken)
    {
        var query = _tableClient.QueryAsync<TodoStoredView>(x => true, maxPerPage: 20, cancellationToken: cancellationToken);
        var pages = query.AsPages();
        var result = new List<TodoGetDto>();
        await foreach (var page in pages)
        {
            foreach (var item in page.Values)
            {
                result.Add(new TodoGetDto
                {
                    Id = item.Id,
                    Name = item.Name,
                    IsComplete = item.IsComplete
                });
            }
        }

        return result;
    }

    public async Task<IList<TodoGetDto>> GetMy()
    {
        var dummy = new[]
        {
            new TodoGetDto
            {
                Id = Guid.Empty,
                Name = "dummy my",
                IsComplete = false
            }
        };

        await Task.CompletedTask;
        return dummy;
    }

    public async Task<TodoGetDto> GetById(Guid id)
    {
        var todo = new TodoGetDto
        {
            Id = Guid.Empty,
            Name = "dummy",
            IsComplete = false
        };

        await Task.CompletedTask;
        return todo;
    }
}
