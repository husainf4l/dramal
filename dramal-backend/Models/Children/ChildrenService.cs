using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace Models.Children;

public interface IChildrenService
{
    Task<IQueryable<Children>> GetMyChildrenAsync(string userId);
    Task<Children?> GetChildByIdAsync(Guid id, string userId, CancellationToken cancellationToken = default);
    Task<Children> CreateChildAsync(CreateChildInput input, string userId, CancellationToken cancellationToken = default);
    Task<Children?> UpdateChildAsync(UpdateChildInput input, string userId, CancellationToken cancellationToken = default);
    Task<bool> DeleteChildAsync(Guid id, string userId, CancellationToken cancellationToken = default);
    Task<int> GetMyChildrenCountAsync(string userId, CancellationToken cancellationToken = default);
}

public class ChildrenService : IChildrenService
{
    private readonly ApplicationDbContext _context;

    public ChildrenService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<IQueryable<Children>> GetMyChildrenAsync(string userId)
    {
        if (string.IsNullOrEmpty(userId))
            throw new ArgumentException("User ID cannot be null or empty", nameof(userId));

        return _context.Children.Where(c => c.UserId == userId);
    }

    public async Task<Children?> GetChildByIdAsync(Guid id, string userId, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrEmpty(userId))
            throw new ArgumentException("User ID cannot be null or empty", nameof(userId));

        return await _context.Children
            .FirstOrDefaultAsync(c => c.Id == id && c.UserId == userId, cancellationToken);
    }

    public async Task<Children> CreateChildAsync(CreateChildInput input, string userId, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrEmpty(userId))
            throw new ArgumentException("User ID cannot be null or empty", nameof(userId));

        if (string.IsNullOrWhiteSpace(input.FirstName))
            throw new ArgumentException("First name is required", nameof(input.FirstName));

        var child = new Children
        {
            FirstName = input.FirstName.Trim(),
            LastName = string.IsNullOrWhiteSpace(input.LastName) ? null : input.LastName.Trim(),
            DateOfBirth = input.DateOfBirth,
            Gender = string.IsNullOrWhiteSpace(input.Gender) ? null : input.Gender.Trim(),
            Notes = string.IsNullOrWhiteSpace(input.Notes) ? null : input.Notes.Trim(),
            UserId = userId,
            CreatedAt = DateTime.UtcNow
        };

        _context.Children.Add(child);
        await _context.SaveChangesAsync(cancellationToken);

        return child;
    }

    public async Task<Children?> UpdateChildAsync(UpdateChildInput input, string userId, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrEmpty(userId))
            throw new ArgumentException("User ID cannot be null or empty", nameof(userId));

        if (string.IsNullOrWhiteSpace(input.FirstName))
            throw new ArgumentException("First name is required", nameof(input.FirstName));

        var child = await _context.Children
            .FirstOrDefaultAsync(c => c.Id == input.Id && c.UserId == userId, cancellationToken);

        if (child == null)
            return null;

        child.FirstName = input.FirstName.Trim();
        child.LastName = string.IsNullOrWhiteSpace(input.LastName) ? null : input.LastName.Trim();
        child.DateOfBirth = input.DateOfBirth;
        child.Gender = string.IsNullOrWhiteSpace(input.Gender) ? null : input.Gender.Trim();
        child.Notes = string.IsNullOrWhiteSpace(input.Notes) ? null : input.Notes.Trim();
        child.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);

        return child;
    }

    public async Task<bool> DeleteChildAsync(Guid id, string userId, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrEmpty(userId))
            throw new ArgumentException("User ID cannot be null or empty", nameof(userId));

        var child = await _context.Children
            .FirstOrDefaultAsync(c => c.Id == id && c.UserId == userId, cancellationToken);

        if (child == null)
            return false;

        _context.Children.Remove(child);
        await _context.SaveChangesAsync(cancellationToken);

        return true;
    }

    public async Task<int> GetMyChildrenCountAsync(string userId, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrEmpty(userId))
            return 0;

        return await _context.Children.CountAsync(c => c.UserId == userId, cancellationToken);
    }
}