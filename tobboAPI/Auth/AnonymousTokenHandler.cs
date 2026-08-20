using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text.Encodings.Web;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using tobboAPI.Data;
using tobboAPI.Helpers;

namespace tobboAPI.Auth;

public sealed class AnonymousTokenHandler : AuthenticationHandler<AuthenticationSchemeOptions>
{
    private readonly TobboDbContext _db;
    private readonly TokenHasher _tokenHasher;
    private readonly IOptions<TobboOptions> _options;

    public AnonymousTokenHandler(
        IOptionsMonitor<AuthenticationSchemeOptions> schemeOptions,
        ILoggerFactory logger,
        UrlEncoder encoder,
        TobboDbContext db,
        TokenHasher tokenHasher,
        IOptions<TobboOptions> options)
        : base(schemeOptions, logger, encoder)
    {
        _db = db;
        _tokenHasher = tokenHasher;
        _options = options;
    }

    protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        if (!Request.Headers.ContainsKey("Authorization"))
        {
            return AuthenticateResult.NoResult();
        }

        if (!AuthenticationHeaderValue.TryParse(Request.Headers.Authorization, out var header)
            || !string.Equals(header.Scheme, "Bearer", StringComparison.OrdinalIgnoreCase)
            || string.IsNullOrWhiteSpace(header.Parameter))
        {
            return AuthenticateResult.Fail("Invalid authorization header.");
        }

        var hash = _tokenHasher.Hash(header.Parameter);
        var user = await _db.AnonymousUsers.FirstOrDefaultAsync(u => u.TokenHash == hash);
        if (user is null)
        {
            return AuthenticateResult.Fail("Invalid token.");
        }

        var expiresAt = user.CreatedAt.AddDays(_options.Value.TokenLifetimeDays);
        if (expiresAt <= DateTime.UtcNow)
        {
            return AuthenticateResult.Fail("Token expired.");
        }

        user.LastActiveAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        var claims = new[] { new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()) };
        var identity = new ClaimsIdentity(claims, Scheme.Name);
        var principal = new ClaimsPrincipal(identity);
        return AuthenticateResult.Success(new AuthenticationTicket(principal, Scheme.Name));
    }

    protected override async Task HandleChallengeAsync(AuthenticationProperties properties)
    {
        Response.StatusCode = StatusCodes.Status401Unauthorized;
        await Response.WriteAsJsonAsync(new ErrorResponse("UNAUTHORIZED", "Authentication is required."));
    }
}
