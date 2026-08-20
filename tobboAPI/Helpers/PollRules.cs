using tobboAPI.Models;

namespace tobboAPI.Helpers;

public static class PollRules
{
    public static PollStatus EffectiveStatus(Poll poll, DateTime utcNow)
    {
        if (poll.Status == PollStatus.Closed)
        {
            return PollStatus.Closed;
        }

        if (poll.ExpiresAt is { } expiresAt && expiresAt <= utcNow)
        {
            return PollStatus.Expired;
        }

        return poll.Status;
    }

    public static string NewPublicCode()
    {
        const string alphabet = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";
        Span<char> chars = stackalloc char[6];
        for (var i = 0; i < chars.Length; i++)
        {
            chars[i] = alphabet[Random.Shared.Next(alphabet.Length)];
        }

        return new string(chars);
    }
}

public static class GeoDistance
{
    private const double EarthRadiusKm = 6371.0;
    private const double KmPerDegreeLatitude = 111.0;

    public static double HaversineKm(double lat1, double lon1, double lat2, double lon2)
    {
        var dLat = ToRadians(lat2 - lat1);
        var dLon = ToRadians(lon2 - lon1);
        var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2)
                + Math.Cos(ToRadians(lat1)) * Math.Cos(ToRadians(lat2))
                * Math.Sin(dLon / 2) * Math.Sin(dLon / 2);
        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        return EarthRadiusKm * c;
    }

    public static (double MinLat, double MaxLat, double MinLon, double MaxLon) BoundingBox(
        double latitude,
        double longitude,
        double radiusKm)
    {
        var latDelta = radiusKm / KmPerDegreeLatitude;
        var lonDelta = radiusKm / (KmPerDegreeLatitude * Math.Max(Math.Cos(ToRadians(latitude)), 0.01));
        return (latitude - latDelta, latitude + latDelta, longitude - lonDelta, longitude + lonDelta);
    }

    public static double RoundKm(double distanceKm) => Math.Round(distanceKm, 1);

    private static double ToRadians(double degrees) => degrees * Math.PI / 180.0;
}
