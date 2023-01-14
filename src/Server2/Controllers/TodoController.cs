using Microsoft.AspNetCore.Mvc;
using Server2.Todo;

namespace Server2.Controllers;

[ApiController]
[Route("/Todo")]
[Produces("application/json")]
public class TodoController : Controller
{
    public TodoController()
    {
        
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

        // await _todoAcceptForUpdateService.Create(item);
        await Task.CompletedTask;
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

        // var existing = await _todoGetFromViewService.GetById(id);
        // if (existing == null)
        // {
        //     return NotFound();
        // }

        // await _todoAcceptForUpdateService.Update(id, item);
        await Task.CompletedTask;
        return Accepted();
    }

    [HttpDelete("{id}")]
    [ProducesResponseType(202)]
    [ProducesResponseType(typeof(string), 404)]
    public async Task<IActionResult> Delete([FromRoute]Guid id)
    {
        // var existing = await _todoGetFromViewService.GetById(id);
        // if (existing == null)
        // {
        //     return NotFound();
        // }

        // await _todoAcceptForUpdateService.Delete(id);
        await Task.CompletedTask;
        return Accepted();
    }
}
