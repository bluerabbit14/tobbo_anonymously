namespace tobboAPI.Models;

public enum PollStatus
{
    Active = 0,
    Closed = 1,
    Expired = 2
}

public class AnonymousUser
{
    public Guid Id { get; set; }
    public required string TokenHash { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime LastActiveAt { get; set; }

    public ICollection<Poll> CreatedPolls { get; set; } = new List<Poll>();
    public ICollection<PollVote> Votes { get; set; } = new List<PollVote>();
}

public class Poll
{
    public Guid Id { get; set; }
    public required string PublicCode { get; set; }
    public Guid CreatorUserId { get; set; }
    public required string Question { get; set; }
    public bool AllowNearby { get; set; }
    public decimal? Latitude { get; set; }
    public decimal? Longitude { get; set; }
    public PollStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public DateTime? ExpiresAt { get; set; }

    public AnonymousUser Creator { get; set; } = null!;
    public ICollection<PollOption> Options { get; set; } = new List<PollOption>();
    public ICollection<PollVote> Votes { get; set; } = new List<PollVote>();
}

public class PollOption
{
    public Guid Id { get; set; }
    public Guid PollId { get; set; }
    public required string Text { get; set; }
    public int DisplayOrder { get; set; }

    public Poll Poll { get; set; } = null!;
    public ICollection<PollVote> Votes { get; set; } = new List<PollVote>();
}

public class PollVote
{
    public Guid Id { get; set; }
    public Guid PollId { get; set; }
    public Guid PollOptionId { get; set; }
    public Guid UserId { get; set; }
    public DateTime CreatedAt { get; set; }

    public Poll Poll { get; set; } = null!;
    public PollOption Option { get; set; } = null!;
    public AnonymousUser User { get; set; } = null!;
}
