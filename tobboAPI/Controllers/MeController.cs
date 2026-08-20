using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using tobboAPI.Auth;
using tobboAPI.Models;
using tobboAPI.Services;

namespace tobboAPI.Controllers;

[ApiController]
[Authorize]
[Route("api/v1/me")]
public sealed class MeController : ControllerBase
{
    private readonly MeService _meService;
    private readonly CurrentUser _currentUser;

    public MeController(MeService meService, CurrentUser currentUser)
    {
        _meService = meService;
        _currentUser = currentUser;
    }

    [HttpGet("polls")]
    public async Task<ActionResult<MyPollsResponse>> Polls(CancellationToken cancellationToken)
    {
        return Ok(await _meService.GetMyPollsAsync(_currentUser.RequireUserId(), cancellationToken));
    }

    [HttpGet("votes")]
    public async Task<ActionResult<MyVotesResponse>> Votes(CancellationToken cancellationToken)
    {
        return Ok(await _meService.GetMyVotesAsync(_currentUser.RequireUserId(), cancellationToken));
    }
}
