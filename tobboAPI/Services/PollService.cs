using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Npgsql;
using tobboAPI.Data;
using tobboAPI.Helpers;
using tobboAPI.Models;

namespace tobboAPI.Services;

public sealed class PollService
{
    private readonly TobboDbContext _db;
    private readonly IOptions<TobboOptions> _options;

    public PollService(TobboDbContext db, IOptions<TobboOptions> options)
    {
        _db = db;
        _options = options;
    }

    public async Task<CreatePollResponse> CreateAsync(
        Guid creatorUserId,
        CreatePollRequest request,
        CancellationToken cancellationToken)
    {
        var question = request.Question.Trim();
        if (string.IsNullOrWhiteSpace(question))
        {
            throw new ApiException(StatusCodes.Status400BadRequest, "VALIDATION_ERROR", "Add a question.");
        }

        var options = request.Options.Select(o => o.Trim()).ToList();
        if (options.Count is < AppLimits.MinOptions or > AppLimits.MaxOptions)
        {
            throw new ApiException(
                StatusCodes.Status400BadRequest,
                "VALIDATION_ERROR",
                $"A poll must have between {AppLimits.MinOptions} and {AppLimits.MaxOptions} options.");
        }

        if (options.Any(string.IsNullOrWhiteSpace))
        {
            throw new ApiException(StatusCodes.Status400BadRequest, "VALIDATION_ERROR", "Option can't be empty.");
        }

        if (options.Any(o => o.Length > AppLimits.MaxOptionLength))
        {
            throw new ApiException(
                StatusCodes.Status400BadRequest,
                "VALIDATION_ERROR",
                $"Option can't be longer than {AppLimits.MaxOptionLength} characters.");
        }

        if (request.AllowNearby && (request.Latitude is null || request.Longitude is null))
        {
            throw new ApiException(
                StatusCodes.Status400BadRequest,
                "ALLOW_NEARBY_REQUIRES_LOCATION",
                "Latitude and longitude are required when nearby sharing is enabled.");
        }

        var now = DateTime.UtcNow;
        var poll = new Poll
        {
            Id = Guid.NewGuid(),
            PublicCode = PollRules.NewPublicCode(),
            CreatorUserId = creatorUserId,
            Question = question,
            AllowNearby = request.AllowNearby,
            Latitude = request.AllowNearby ? request.Latitude : null,
            Longitude = request.AllowNearby ? request.Longitude : null,
            Status = PollStatus.Active,
            CreatedAt = now,
            UpdatedAt = now,
            Options = options
                .Select((text, index) => new PollOption
                {
                    Id = Guid.NewGuid(),
                    Text = text,
                    DisplayOrder = index + 1
                })
                .ToList()
        };

        for (var attempt = 0; attempt < 5; attempt++)
        {
            try
            {
                _db.Polls.Add(poll);
                await _db.SaveChangesAsync(cancellationToken);
                break;
            }
            catch (DbUpdateException ex) when (IsUniqueViolation(ex) && attempt < 4)
            {
                _db.Entry(poll).State = EntityState.Detached;
                foreach (var option in poll.Options)
                {
                    _db.Entry(option).State = EntityState.Detached;
                }

                poll.PublicCode = PollRules.NewPublicCode();
            }
        }

        var shareUrl = $"{_options.Value.PublicBaseUrl.TrimEnd('/')}/p/{poll.PublicCode}";
        return new CreatePollResponse(poll.Id, poll.PublicCode, shareUrl);
    }

    public async Task<PollDetailResponse> GetByPublicCodeAsync(
        string publicCode,
        Guid? currentUserId,
        double? latitude,
        double? longitude,
        CancellationToken cancellationToken)
    {
        var poll = await LoadPollAsync(publicCode, cancellationToken);
        var hasVoted = currentUserId is { } userId && poll.Votes.Any(v => v.UserId == userId);

        return new PollDetailResponse(
            poll.PublicCode,
            poll.Question,
            poll.Options.OrderBy(o => o.DisplayOrder).Select(o => new PollOptionResponse(o.Id, o.Text)).ToList(),
            poll.Votes.Count,
            DistanceFor(poll, latitude, longitude),
            hasVoted,
            PollRules.EffectiveStatus(poll, DateTime.UtcNow));
    }

    public async Task<PollResultsResponse> GetResultsAsync(
        string publicCode,
        Guid? currentUserId,
        CancellationToken cancellationToken)
    {
        var poll = await LoadPollAsync(publicCode, cancellationToken);
        var totalVotes = poll.Votes.Count;
        var counts = poll.Votes.GroupBy(v => v.PollOptionId).ToDictionary(g => g.Key, g => g.Count());
        Guid? myVoteOptionId = currentUserId is { } userId
            ? poll.Votes.FirstOrDefault(v => v.UserId == userId)?.PollOptionId
            : null;

        var options = poll.Options
            .OrderBy(o => o.DisplayOrder)
            .Select(o =>
            {
                var voteCount = counts.GetValueOrDefault(o.Id);
                var percentage = totalVotes == 0 ? 0 : Math.Round(voteCount * 100.0 / totalVotes, 1);
                return new PollResultOptionResponse(o.Id, o.Text, voteCount, percentage);
            })
            .ToList();

        return new PollResultsResponse(poll.Question, totalVotes, options, myVoteOptionId);
    }

    public async Task<NearbyPollsResponse> GetNearbyAsync(
        double latitude,
        double longitude,
        double radiusKm,
        CancellationToken cancellationToken)
    {
        if (latitude is < -90 or > 90 || longitude is < -180 or > 180)
        {
            throw new ApiException(StatusCodes.Status400BadRequest, "VALIDATION_ERROR", "Location is invalid.");
        }

        if (radiusKm <= 0)
        {
            throw new ApiException(StatusCodes.Status400BadRequest, "VALIDATION_ERROR", "radiusKm must be greater than 0.");
        }

        var now = DateTime.UtcNow;
        var box = GeoDistance.BoundingBox(latitude, longitude, radiusKm);

        var candidates = await _db.Polls
            .AsNoTracking()
            .Where(p =>
                p.AllowNearby
                && p.Status == PollStatus.Active
                && (p.ExpiresAt == null || p.ExpiresAt > now)
                && p.Latitude != null
                && p.Longitude != null
                && p.Latitude >= (decimal)box.MinLat
                && p.Latitude <= (decimal)box.MaxLat
                && p.Longitude >= (decimal)box.MinLon
                && p.Longitude <= (decimal)box.MaxLon)
            .Select(p => new
            {
                p.PublicCode,
                p.Question,
                p.Latitude,
                p.Longitude,
                VoteCount = p.Votes.Count
            })
            .ToListAsync(cancellationToken);

        var items = candidates
            .Select(p => new
            {
                p.PublicCode,
                p.Question,
                p.VoteCount,
                DistanceKm = GeoDistance.HaversineKm(
                    latitude,
                    longitude,
                    (double)p.Latitude!,
                    (double)p.Longitude!)
            })
            .Where(p => p.DistanceKm <= radiusKm)
            .OrderBy(p => p.DistanceKm)
            .Select(p => new NearbyPollItemResponse(
                p.PublicCode,
                p.Question,
                p.VoteCount,
                GeoDistance.RoundKm(p.DistanceKm)))
            .ToList();

        return new NearbyPollsResponse(items);
    }

    private async Task<Poll> LoadPollAsync(string publicCode, CancellationToken cancellationToken)
    {
        var poll = await _db.Polls
            .AsNoTracking()
            .Include(p => p.Options)
            .Include(p => p.Votes)
            .FirstOrDefaultAsync(p => p.PublicCode == publicCode.ToUpperInvariant(), cancellationToken);

        return poll ?? throw new ApiException(StatusCodes.Status404NotFound, "POLL_NOT_FOUND", "We couldn't load this question.");
    }

    private static double? DistanceFor(Poll poll, double? latitude, double? longitude)
    {
        if (latitude is null || longitude is null || poll.Latitude is null || poll.Longitude is null)
        {
            return null;
        }

        return GeoDistance.RoundKm(GeoDistance.HaversineKm(
            latitude.Value,
            longitude.Value,
            (double)poll.Latitude.Value,
            (double)poll.Longitude.Value));
    }

    private static bool IsUniqueViolation(DbUpdateException exception) =>
        exception.InnerException is PostgresException { SqlState: PostgresErrorCodes.UniqueViolation };
}
