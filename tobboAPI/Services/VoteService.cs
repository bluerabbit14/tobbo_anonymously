using Microsoft.EntityFrameworkCore;
using Npgsql;
using tobboAPI.Data;
using tobboAPI.Helpers;
using tobboAPI.Models;

namespace tobboAPI.Services;

public sealed class VoteService
{
    private readonly TobboDbContext _db;

    public VoteService(TobboDbContext db)
    {
        _db = db;
    }

    public async Task VoteAsync(Guid userId, string publicCode, Guid optionId, CancellationToken cancellationToken)
    {
        var poll = await _db.Polls
            .Include(p => p.Options)
            .FirstOrDefaultAsync(p => p.PublicCode == publicCode.ToUpperInvariant(), cancellationToken);

        if (poll is null)
        {
            throw new ApiException(StatusCodes.Status404NotFound, "POLL_NOT_FOUND", "We couldn't load this question.");
        }

        var status = PollRules.EffectiveStatus(poll, DateTime.UtcNow);
        if (status is PollStatus.Closed or PollStatus.Expired)
        {
            throw new ApiException(StatusCodes.Status409Conflict, "POLL_CLOSED", "This question has closed.");
        }

        if (poll.Options.All(o => o.Id != optionId))
        {
            throw new ApiException(StatusCodes.Status404NotFound, "OPTION_NOT_FOUND", "That option isn't available.");
        }

        if (await _db.PollVotes.AnyAsync(v => v.PollId == poll.Id && v.UserId == userId, cancellationToken))
        {
            throw new ApiException(StatusCodes.Status409Conflict, "ALREADY_VOTED", "You have already voted on this poll.");
        }

        _db.PollVotes.Add(new PollVote
        {
            Id = Guid.NewGuid(),
            PollId = poll.Id,
            PollOptionId = optionId,
            UserId = userId,
            CreatedAt = DateTime.UtcNow
        });

        try
        {
            await _db.SaveChangesAsync(cancellationToken);
        }
        catch (DbUpdateException ex) when (ex.InnerException is PostgresException { SqlState: PostgresErrorCodes.UniqueViolation })
        {
            throw new ApiException(StatusCodes.Status409Conflict, "ALREADY_VOTED", "You have already voted on this poll.");
        }
    }
}
