using Microsoft.EntityFrameworkCore;
using tobboAPI.Data;
using tobboAPI.Models;

namespace tobboAPI.Services;

public sealed class MeService
{
    private readonly TobboDbContext _db;

    public MeService(TobboDbContext db)
    {
        _db = db;
    }

    public async Task<MyPollsResponse> GetMyPollsAsync(Guid userId, CancellationToken cancellationToken)
    {
        var items = await _db.Polls
            .AsNoTracking()
            .Where(p => p.CreatorUserId == userId)
            .OrderByDescending(p => p.CreatedAt)
            .Select(p => new MyPollItemResponse(p.PublicCode, p.Question, p.Votes.Count, p.CreatedAt))
            .ToListAsync(cancellationToken);

        return new MyPollsResponse(items);
    }

    public async Task<MyVotesResponse> GetMyVotesAsync(Guid userId, CancellationToken cancellationToken)
    {
        var items = await _db.PollVotes
            .AsNoTracking()
            .Where(v => v.UserId == userId)
            .OrderByDescending(v => v.CreatedAt)
            .Select(v => new MyVoteItemResponse(v.Poll.PublicCode, v.Poll.Question, v.Option.Text, v.CreatedAt))
            .ToListAsync(cancellationToken);

        return new MyVotesResponse(items);
    }
}
