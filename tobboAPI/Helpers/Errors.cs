namespace tobboAPI.Helpers;

public class TobboOptions
{
    public const string SectionName = "Tobbo";

    public string PublicBaseUrl { get; set; } = "https://tobbo.app";
    public int TokenLifetimeDays { get; set; } = 365;
}

public static class AppLimits
{
    public const int MaxQuestionLength = 120;
    public const int MinOptions = 2;
    public const int MaxOptions = 4;
    public const int MaxOptionLength = 60;
}

public sealed class ApiException : Exception
{
    public ApiException(int statusCode, string code, string message)
        : base(message)
    {
        StatusCode = statusCode;
        Code = code;
    }

    public int StatusCode { get; }
    public string Code { get; }
}

public sealed record ErrorResponse(string Code, string Message);
