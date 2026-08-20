using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using tobboAPI.Auth;
using tobboAPI.Helpers;
using tobboAPI.Models;
using tobboAPI.Services;

namespace tobboAPI.Controllers;

[ApiController]
[Route("api/v1/polls")]
public sealed class PollsController : ControllerBase
{
    private readonly PollService _pollService;
    private readonly VoteService _voteService;
    private readonly CurrentUser _currentUser;

    public PollsController(PollService pollService, VoteService voteService, CurrentUser currentUser)
    {
        _pollService = pollService;
        _voteService = voteService;
        _currentUser = currentUser;
    }

    [HttpPost]
    [Authorize]
    public async Task<ActionResult<CreatePollResponse>> Create(
        [FromBody] CreatePollRequest request,
        CancellationToken cancellationToken)
    {
        return Ok(await _pollService.CreateAsync(_currentUser.RequireUserId(), request, cancellationToken));
    }

    [HttpGet("nearby")]
    [AllowAnonymous]
    public async Task<ActionResult<NearbyPollsResponse>> Nearby(
        [FromQuery] double? latitude,
        [FromQuery] double? longitude,
        [FromQuery] double radiusKm = 5,
        CancellationToken cancellationToken = default)
    {
        if (latitude is null || longitude is null)
        {
            throw new ApiException(
                StatusCodes.Status400BadRequest,
                "LOCATION_REQUIRED",
                "latitude and longitude are required.");
        }

        return Ok(await _pollService.GetNearbyAsync(latitude.Value, longitude.Value, radiusKm, cancellationToken));
    }

    [HttpGet("{publicCode}")]
    [AllowAnonymous]
    public async Task<ActionResult<PollDetailResponse>> Get(
        string publicCode,
        [FromQuery] double? latitude,
        [FromQuery] double? longitude,
        CancellationToken cancellationToken)
    {
        return Ok(await _pollService.GetByPublicCodeAsync(
            publicCode,
            _currentUser.UserId,
            latitude,
            longitude,
            cancellationToken));
    }

    [HttpPost("{publicCode}/votes")]
    [Authorize]
    public async Task<IActionResult> Vote(
        string publicCode,
        [FromBody] VoteRequest request,
        CancellationToken cancellationToken)
    {
        if (request.OptionId is null || request.OptionId == Guid.Empty)
        {
            throw new ApiException(StatusCodes.Status400BadRequest, "VALIDATION_ERROR", "optionId is required.");
        }

        await _voteService.VoteAsync(
            _currentUser.RequireUserId(),
            publicCode,
            request.OptionId.Value,
            cancellationToken);
        return NoContent();
    }

    [HttpGet("{publicCode}/results")]
    [AllowAnonymous]
    public async Task<ActionResult<PollResultsResponse>> Results(
        string publicCode,
        CancellationToken cancellationToken)
    {
        return Ok(await _pollService.GetResultsAsync(publicCode, _currentUser.UserId, cancellationToken));
    }
}
