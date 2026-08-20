using System.ComponentModel.DataAnnotations;
using tobboAPI.Helpers;

namespace tobboAPI.Models;

public sealed record AnonymousTokenResponse(string AccessToken, DateTime ExpiresAt, Guid UserId);

public sealed class CreatePollRequest
{
    [Required]
    [MaxLength(AppLimits.MaxQuestionLength)]
    public string Question { get; set; } = string.Empty;

    [Required]
    [MinLength(AppLimits.MinOptions)]
    [MaxLength(AppLimits.MaxOptions)]
    public List<string> Options { get; set; } = [];

    public bool AllowNearby { get; set; }

    [Range(-90, 90)]
    public decimal? Latitude { get; set; }

    [Range(-180, 180)]
    public decimal? Longitude { get; set; }
}

public sealed record CreatePollResponse(Guid Id, string PublicCode, string ShareUrl);

public sealed record PollOptionResponse(Guid Id, string Text);

public sealed record PollDetailResponse(
    string PublicCode,
    string Question,
    IReadOnlyList<PollOptionResponse> Options,
    int VoteCount,
    double? DistanceKm,
    bool HasVoted,
    PollStatus Status);

public sealed record NearbyPollItemResponse(
    string PublicCode,
    string Question,
    int VoteCount,
    double DistanceKm);

public sealed record NearbyPollsResponse(IReadOnlyList<NearbyPollItemResponse> Items);

public sealed record PollResultOptionResponse(
    Guid Id,
    string Text,
    int VoteCount,
    double Percentage);

public sealed record PollResultsResponse(
    string Question,
    int TotalVotes,
    IReadOnlyList<PollResultOptionResponse> Options,
    Guid? MyVoteOptionId);

public sealed class VoteRequest
{
    [Required]
    public Guid? OptionId { get; set; }
}

public sealed record MyPollItemResponse(
    string PublicCode,
    string Question,
    int VoteCount,
    DateTime CreatedAt);

public sealed record MyVoteItemResponse(
    string PublicCode,
    string Question,
    string SelectedOption,
    DateTime CreatedAt);

public sealed record MyPollsResponse(IReadOnlyList<MyPollItemResponse> Items);

public sealed record MyVotesResponse(IReadOnlyList<MyVoteItemResponse> Items);
