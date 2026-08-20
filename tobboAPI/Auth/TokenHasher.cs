using System.Security.Cryptography;
using System.Text;

namespace tobboAPI.Auth;

public static class AnonymousTokenDefaults
{
    public const string Scheme = "AnonymousToken";
}

public sealed class TokenHasher
{
    public string CreateToken()
    {
        var bytes = RandomNumberGenerator.GetBytes(32);
        return Convert.ToBase64String(bytes)
            .TrimEnd('=')
            .Replace('+', '-')
            .Replace('/', '_');
    }

    public string Hash(string token)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(token));
        return Convert.ToHexString(bytes).ToLowerInvariant();
    }
}
