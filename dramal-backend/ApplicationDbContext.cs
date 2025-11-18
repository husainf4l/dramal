using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Models.Auth;
using Models.Users;
using Models.Children;
using Dramal.Models.Visits;
using Dramal.Models.Vaccines;

public class ApplicationDbContext : IdentityDbContext<User>
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

    public DbSet<RefreshToken> RefreshTokens { get; set; } = null!;
    public DbSet<Children> Children { get; set; } = null!;
    public DbSet<Visit> Visits { get; set; } = null!;
    public DbSet<Vaccine> Vaccines { get; set; } = null!;
    public DbSet<VaccineSchedule> VaccineSchedules { get; set; } = null!;
}