using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using tobboAPI.Helpers;

namespace tobboAPI.Data;

public sealed class TobboDbContextFactory : IDesignTimeDbContextFactory<TobboDbContext>
{
    public TobboDbContext CreateDbContext(string[] args)
    {
        EnvFile.Load();

        var options = new DbContextOptionsBuilder<TobboDbContext>()
            .UseNpgsql(EnvFile.GetDatabaseString())
            .Options;

        return new TobboDbContext(options);
    }
}
