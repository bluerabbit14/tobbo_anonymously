using Microsoft.EntityFrameworkCore;
using tobboAPI.Models;

namespace tobboAPI.Data;

public class TobboDbContext : DbContext
{
    public TobboDbContext(DbContextOptions<TobboDbContext> options)
        : base(options)
    {
    }

    public DbSet<AnonymousUser> AnonymousUsers => Set<AnonymousUser>();
    public DbSet<Poll> Polls => Set<Poll>();
    public DbSet<PollOption> PollOptions => Set<PollOption>();
    public DbSet<PollVote> PollVotes => Set<PollVote>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        var users = modelBuilder.Entity<AnonymousUser>();
        users.ToTable("AnonymousUsers");
        users.HasKey(x => x.Id);
        users.Property(x => x.TokenHash).IsRequired().HasMaxLength(64);
        users.HasIndex(x => x.TokenHash).IsUnique();

        var polls = modelBuilder.Entity<Poll>();
        polls.ToTable("Polls");
        polls.HasKey(x => x.Id);
        polls.Property(x => x.PublicCode).IsRequired().HasMaxLength(6).IsFixedLength();
        polls.HasIndex(x => x.PublicCode).IsUnique();
        polls.Property(x => x.Question).IsRequired().HasMaxLength(120);
        polls.Property(x => x.Latitude).HasPrecision(9, 6);
        polls.Property(x => x.Longitude).HasPrecision(9, 6);
        polls.Property(x => x.Status).HasConversion<string>().HasMaxLength(16).IsRequired();
        polls.HasIndex(x => x.CreatorUserId);
        polls.HasIndex(x => new { x.AllowNearby, x.Status });
        polls.HasOne(x => x.Creator)
            .WithMany(x => x.CreatedPolls)
            .HasForeignKey(x => x.CreatorUserId)
            .OnDelete(DeleteBehavior.Restrict);
        polls.HasMany(x => x.Options)
            .WithOne(x => x.Poll)
            .HasForeignKey(x => x.PollId)
            .OnDelete(DeleteBehavior.Cascade);
        polls.HasMany(x => x.Votes)
            .WithOne(x => x.Poll)
            .HasForeignKey(x => x.PollId)
            .OnDelete(DeleteBehavior.Cascade);

        var options = modelBuilder.Entity<PollOption>();
        options.ToTable("PollOptions");
        options.HasKey(x => x.Id);
        options.Property(x => x.Text).IsRequired().HasMaxLength(60);
        options.HasIndex(x => new { x.PollId, x.DisplayOrder });

        var votes = modelBuilder.Entity<PollVote>();
        votes.ToTable("PollVotes");
        votes.HasKey(x => x.Id);
        votes.HasIndex(x => new { x.PollId, x.UserId }).IsUnique();
        votes.HasIndex(x => x.UserId);
        votes.HasOne(x => x.Option)
            .WithMany(x => x.Votes)
            .HasForeignKey(x => x.PollOptionId)
            .OnDelete(DeleteBehavior.Restrict);
        votes.HasOne(x => x.User)
            .WithMany(x => x.Votes)
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
