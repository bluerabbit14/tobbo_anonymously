using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using tobboAPI.Models;
using tobboAPI.Services;

namespace tobboAPI.Controllers;

[ApiController]
[Route("api/v1/anonymous")]
public sealed class AnonymousController : ControllerBase
{
    private readonly AnonymousService _anonymousService;

    public AnonymousController(AnonymousService anonymousService)
    {
        _anonymousService = anonymousService;
    }

    [HttpPost]
    [AllowAnonymous]
    public async Task<ActionResult<AnonymousTokenResponse>> Create(CancellationToken cancellationToken)
    {
        return Ok(await _anonymousService.CreateAsync(cancellationToken));
    }
}
