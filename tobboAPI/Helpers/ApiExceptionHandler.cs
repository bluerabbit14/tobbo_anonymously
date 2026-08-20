using Microsoft.AspNetCore.Diagnostics;

namespace tobboAPI.Helpers;

public sealed class ApiExceptionHandler : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext,
        Exception exception,
        CancellationToken cancellationToken)
    {
        var (statusCode, code, message) = exception switch
        {
            ApiException api => (api.StatusCode, api.Code, api.Message),
            _ => (StatusCodes.Status500InternalServerError, "INTERNAL_ERROR", "Something went wrong.")
        };

        httpContext.Response.StatusCode = statusCode;
        await httpContext.Response.WriteAsJsonAsync(new ErrorResponse(code, message), cancellationToken);
        return true;
    }
}
