namespace tobboAPI.Helpers;

public static class EnvFile
{
    public static void Load()
    {
        var path = FindEnvPath();
        if (path is null)
        {
            return;
        }

        foreach (var raw in File.ReadAllLines(path))
        {
            var line = raw.Trim();
            if (line.Length == 0 || line.StartsWith('#'))
            {
                continue;
            }

            var separator = line.IndexOf('=');
            if (separator <= 0)
            {
                continue;
            }

            var key = line[..separator].Trim();
            var value = line[(separator + 1)..].Trim().Trim('"').Trim('\'');
            Environment.SetEnvironmentVariable(key, value);
        }
    }

    public static string GetDatabaseString()
    {
        var value = Environment.GetEnvironmentVariable("Database_string");
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new InvalidOperationException("Set Database_string in the .env file.");
        }

        return value;
    }

    public static string GetBaseUrl()
    {
        var value = Environment.GetEnvironmentVariable("Base_url");
        return string.IsNullOrWhiteSpace(value) ? "https://tobbo.app" : value.Trim().TrimEnd('/');
    }

    public static int GetTokenLifetimeDays()
    {
        var value = Environment.GetEnvironmentVariable("TokenLifetimeDays");
        return int.TryParse(value, out var days) && days > 0 ? days : 365;
    }

    private static string? FindEnvPath()
    {
        var dir = new DirectoryInfo(Directory.GetCurrentDirectory());
        while (dir is not null)
        {
            var candidate = Path.Combine(dir.FullName, ".env");
            if (File.Exists(candidate))
            {
                return candidate;
            }

            dir = dir.Parent;
        }

        return null;
    }
}
