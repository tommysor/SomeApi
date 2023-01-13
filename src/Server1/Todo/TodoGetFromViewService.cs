namespace Server1.Todo;

//todo Implement class TodoGetFromViewService
public class TodoGetFromViewService
{
    public TodoGetFromViewService()
    {
        
    }

    public async Task<IList<TodoGetDto>> GetAll()
    {
        var dummy = new[]
        {
            new TodoGetDto
            {
                Id = 1,
                Name = "dummy all",
                IsComplete = false
            }
        };

        await Task.CompletedTask;
        return dummy;
    }

    public async Task<IList<TodoGetDto>> GetMy()
    {
        var dummy = new[]
        {
            new TodoGetDto
            {
                Id = 1,
                Name = "dummy my",
                IsComplete = false
            }
        };

        await Task.CompletedTask;
        return dummy;
    }

    public async Task<TodoGetDto> GetById(long id)
    {
        var todo = new TodoGetDto
        {
            Id = 1,
            Name = "dummy",
            IsComplete = false
        };

        await Task.CompletedTask;
        return todo;
    }
}
