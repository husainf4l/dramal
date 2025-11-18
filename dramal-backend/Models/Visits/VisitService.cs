using Microsoft.EntityFrameworkCore;
using Models.Children;

namespace Dramal.Models.Visits;

public interface IVisitService
{
    Task<Visit> CreateVisitAsync(CreateVisitInput input, string userId);
    Task<Visit?> GetVisitByIdAsync(Guid id, string userId);
    Task<IEnumerable<Visit>> GetVisitsByChildIdAsync(Guid childId, string userId);
    Task<IEnumerable<Visit>> GetAllVisitsForUserAsync(string userId);
    Task<Visit> UpdateVisitAsync(UpdateVisitInput input, string userId);
    Task<bool> DeleteVisitAsync(Guid id, string userId);
}

public class VisitService : IVisitService
{
    private readonly ApplicationDbContext _context;

    public VisitService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<Visit> CreateVisitAsync(CreateVisitInput input, string userId)
    {
        // Verify the child belongs to the user
        var child = await _context.Children
            .FirstOrDefaultAsync(c => c.Id == input.ChildId && c.UserId == userId);

        if (child == null)
        {
            throw new UnauthorizedAccessException("Child not found or you don't have permission to access this child.");
        }

        var visit = new Visit
        {
            VisitReason = input.VisitReason.Trim(),
            VisitDate = input.VisitDate,
            DoctorName = string.IsNullOrWhiteSpace(input.DoctorName) ? null : input.DoctorName.Trim(),
            Clinic = string.IsNullOrWhiteSpace(input.Clinic) ? null : input.Clinic.Trim(),
            Diagnosis = string.IsNullOrWhiteSpace(input.Diagnosis) ? null : input.Diagnosis.Trim(),
            Treatment = string.IsNullOrWhiteSpace(input.Treatment) ? null : input.Treatment.Trim(),
            Medications = string.IsNullOrWhiteSpace(input.Medications) ? null : input.Medications.Trim(),
            Notes = string.IsNullOrWhiteSpace(input.Notes) ? null : input.Notes.Trim(),
            FollowUpDate = input.FollowUpDate,
            ChildId = input.ChildId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _context.Visits.Add(visit);
        await _context.SaveChangesAsync();

        // Load the child navigation property
        await _context.Entry(visit)
            .Reference(v => v.Child)
            .LoadAsync();

        return visit;
    }

    public async Task<Visit?> GetVisitByIdAsync(Guid id, string userId)
    {
        return await _context.Visits
            .Include(v => v.Child)
            .FirstOrDefaultAsync(v => v.Id == id && v.Child.UserId == userId);
    }

    public async Task<IEnumerable<Visit>> GetVisitsByChildIdAsync(Guid childId, string userId)
    {
        return await _context.Visits
            .Include(v => v.Child)
            .Where(v => v.ChildId == childId && v.Child.UserId == userId)
            .OrderByDescending(v => v.VisitDate)
            .ToListAsync();
    }

    public async Task<IEnumerable<Visit>> GetAllVisitsForUserAsync(string userId)
    {
        return await _context.Visits
            .Include(v => v.Child)
            .Where(v => v.Child.UserId == userId)
            .OrderByDescending(v => v.VisitDate)
            .ToListAsync();
    }

    public async Task<Visit> UpdateVisitAsync(UpdateVisitInput input, string userId)
    {
        var visit = await _context.Visits
            .Include(v => v.Child)
            .FirstOrDefaultAsync(v => v.Id == input.Id && v.Child.UserId == userId);

        if (visit == null)
        {
            throw new UnauthorizedAccessException("Visit not found or you don't have permission to access this visit.");
        }

        visit.VisitReason = input.VisitReason.Trim();
        visit.VisitDate = input.VisitDate;
        visit.DoctorName = string.IsNullOrWhiteSpace(input.DoctorName) ? null : input.DoctorName.Trim();
        visit.Clinic = string.IsNullOrWhiteSpace(input.Clinic) ? null : input.Clinic.Trim();
        visit.Diagnosis = string.IsNullOrWhiteSpace(input.Diagnosis) ? null : input.Diagnosis.Trim();
        visit.Treatment = string.IsNullOrWhiteSpace(input.Treatment) ? null : input.Treatment.Trim();
        visit.Medications = string.IsNullOrWhiteSpace(input.Medications) ? null : input.Medications.Trim();
        visit.Notes = string.IsNullOrWhiteSpace(input.Notes) ? null : input.Notes.Trim();
        visit.FollowUpDate = input.FollowUpDate;
        visit.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        return visit;
    }

    public async Task<bool> DeleteVisitAsync(Guid id, string userId)
    {
        var visit = await _context.Visits
            .Include(v => v.Child)
            .FirstOrDefaultAsync(v => v.Id == id && v.Child.UserId == userId);

        if (visit == null)
        {
            return false;
        }

        _context.Visits.Remove(visit);
        await _context.SaveChangesAsync();
        return true;
    }
}