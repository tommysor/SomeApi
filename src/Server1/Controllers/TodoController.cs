using Microsoft.AspNetCore.Mvc;
using Server1.Todo;

namespace Server1.Controllers;

[ApiController]
[Route("")]
[Produces("application/json")]
public class TodoController : Controller
{
    private readonly TodoAcceptForUpdateService _todoAcceptForUpdateService;
    private readonly TodoGetFromViewService _todoGetFromViewService;

    public TodoController(TodoAcceptForUpdateService todoAcceptForUpdateService, TodoGetFromViewService todoGetFromViewService)
    {
        _todoAcceptForUpdateService = todoAcceptForUpdateService;
        _todoGetFromViewService = todoGetFromViewService;
    }

    [HttpGet]
    [Route("all")]
    public async Task<IList<TodoGetDto>> GetAll()
    {
        var result = await _todoGetFromViewService.GetAll();
        return result;
    }

    [HttpGet]
    public async Task<IList<TodoGetDto>> GetMy()
    {
        var result = await _todoGetFromViewService.GetMy();
        return result;
    }

    [HttpGet("{id}", Name = "GetTodo")]
    [ProducesResponseType(200)]
    [ProducesResponseType(typeof(string), 404)]
    public async Task<ActionResult<TodoGetDto>> GetById([FromRoute]Guid id)
    {
        var result = await _todoGetFromViewService.GetById(id);
        if (result == null)
        {
            return NotFound();
        }
        return result;
    }

    [HttpPost]
    [ProducesResponseType(202)]
    [ProducesResponseType(typeof(string), 400)]
    public async Task<IActionResult> Create([FromBody] TodoCreateDto item)
    {
        if (item == null)
        {
            return BadRequest();
        }

        await _todoAcceptForUpdateService.Create(item);
        return Accepted();
    }

    [HttpPut("{id}")]
    [ProducesResponseType(202)]
    [ProducesResponseType(typeof(string), 400)]
    [ProducesResponseType(typeof(string), 404)]
    public async Task<IActionResult> Update([FromRoute]Guid id, [FromBody] TodoUpdateDto item)
    {
        if (item == null)
        {
            return BadRequest();
        }

        var existing = await _todoGetFromViewService.GetById(id);
        if (existing == null)
        {
            return NotFound();
        }

        await _todoAcceptForUpdateService.Update(id, item);
        return Accepted();
    }

    [HttpDelete("{id}")]
    [ProducesResponseType(202)]
    [ProducesResponseType(typeof(string), 404)]
    public async Task<IActionResult> Delete([FromRoute]Guid id)
    {
        var existing = await _todoGetFromViewService.GetById(id);
        if (existing == null)
        {
            return NotFound();
        }

        await _todoAcceptForUpdateService.Delete(id);
        return Accepted();
    }
}
