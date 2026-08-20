using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.Net.Http.Headers;
using Microsoft.OpenApi;
using tobboAPI.Auth;
using tobboAPI.Data;
using tobboAPI.Helpers;
using tobboAPI.Services;

EnvFile.Load();

var builder = WebApplication.CreateBuilder(args);

builder.Services.Configure<TobboOptions>(options =>
{
    options.PublicBaseUrl = EnvFile.GetBaseUrl();
    options.TokenLifetimeDays = EnvFile.GetTokenLifetimeDays();
});

builder.Services.AddDbContext<TobboDbContext>(options =>
    options.UseNpgsql(EnvFile.GetDatabaseString()));

builder.Services.AddHttpContextAccessor();
builder.Services.AddSingleton<TokenHasher>();
builder.Services.AddScoped<CurrentUser>();
builder.Services.AddScoped<AnonymousService>();
builder.Services.AddScoped<PollService>();
builder.Services.AddScoped<VoteService>();
builder.Services.AddScoped<MeService>();

builder.Services
    .AddAuthentication(AnonymousTokenDefaults.Scheme)
    .AddScheme<AuthenticationSchemeOptions, AnonymousTokenHandler>(AnonymousTokenDefaults.Scheme, _ => { });
builder.Services.AddAuthorization();

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
        policy.AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod());
});

builder.Services.ConfigureHttpJsonOptions(options => ConfigureJson(options.SerializerOptions));
builder.Services.AddControllers()
    .AddJsonOptions(options => ConfigureJson(options.JsonSerializerOptions))
    .ConfigureApiBehaviorOptions(options =>
    {
        options.InvalidModelStateResponseFactory = context =>
        {
            var message = context.ModelState.Values
                .SelectMany(v => v.Errors)
                .Select(e => e.ErrorMessage)
                .FirstOrDefault(m => !string.IsNullOrWhiteSpace(m))
                ?? "Invalid request.";
            return new Microsoft.AspNetCore.Mvc.BadRequestObjectResult(
                new ErrorResponse("VALIDATION_ERROR", message));
        };
    });

builder.Services.AddExceptionHandler<ApiExceptionHandler>();
builder.Services.AddProblemDetails();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Tobbo API",
        Version = "v1",
        Description = "Anonymous polls API"
    });
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "Paste the accessToken from POST /api/v1/anonymous. Swagger adds the Bearer prefix.",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "Token"
    });
    options.AddSecurityRequirement(document => new OpenApiSecurityRequirement
    {
        [new OpenApiSecuritySchemeReference("Bearer", document)] = []
    });
});

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<TobboDbContext>();
    db.Database.Migrate();
}

app.UseSwagger();
app.UseSwaggerUI(options =>
{
    options.SwaggerEndpoint("/swagger/v1/swagger.json", "Tobbo API v1");
    options.RoutePrefix = "swagger";
});

app.UseExceptionHandler();

if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseCors();
app.UseAuthentication();
app.Use(async (context, next) =>
{
    if (!context.Request.Path.StartsWithSegments("/api/v1/anonymous")
        && context.Request.Headers.ContainsKey(HeaderNames.Authorization)
        && context.User.Identity?.IsAuthenticated != true)
    {
        context.Response.StatusCode = StatusCodes.Status401Unauthorized;
        await context.Response.WriteAsJsonAsync(
            new ErrorResponse("UNAUTHORIZED", "Invalid or expired token."));
        return;
    }

    await next();
});
app.UseAuthorization();
app.MapControllers();
app.Run();

static void ConfigureJson(JsonSerializerOptions options)
{
    options.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
    options.Converters.Add(new JsonStringEnumConverter(JsonNamingPolicy.CamelCase));
}
