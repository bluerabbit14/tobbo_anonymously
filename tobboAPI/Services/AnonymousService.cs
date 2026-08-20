using Microsoft.Extensions.Options;
using tobboAPI.Auth;
using tobboAPI.Data;
using tobboAPI.Helpers;
using tobboAPI.Models;

namespace tobboAPI.Services;

public sealed class AnonymousService
{
    private readonly TobboDbContext _db;
    private readonly TokenHasher _tokenHasher;
    private readonly IOptions<TobboOptions> _options;

    public AnonymousService(TobboDbContext db, TokenHasher tokenHasher, IOptions<TobboOptions> options)
    {
        _db = db;
        _tokenHasher = tokenHasher;
        _options = options;
    }

    public async Task<AnonymousTokenResponse> CreateAsync(CancellationToken cancellationToken)
    {
        var now = DateTime.UtcNow;
        var token = _tokenHasher.CreateToken();
        var user = new AnonymousUser
        {
            Id = Guid.NewGuid(),
            TokenHash = _tokenHasher.Hash(token),
            CreatedAt = now,
            LastActiveAt = now
        };

        _db.AnonymousUsers.Add(user);
        await _db.SaveChangesAsync(cancellationToken);

        return new AnonymousTokenResponse(token, now.AddDays(_options.Value.TokenLifetimeDays), user.Id);
    }
}
