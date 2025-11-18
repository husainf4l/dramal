using Microsoft.EntityFrameworkCore;
using Models.Children;

namespace Dramal.Models.Vaccines;

public interface IVaccineService
{
    Task<Vaccine> CreateVaccineAsync(CreateVaccineInput input, string userId);
    Task<Vaccine?> GetVaccineByIdAsync(Guid id, string userId);
    Task<IEnumerable<Vaccine>> GetVaccinesByChildIdAsync(Guid childId, string userId);
    Task<IEnumerable<Vaccine>> GetAllVaccinesForUserAsync(string userId);
    Task<IEnumerable<Vaccine>> GetUpcomingVaccinesAsync(string userId, int daysAhead = 30);
    Task<Vaccine> UpdateVaccineAsync(UpdateVaccineInput input, string userId);
    Task<bool> DeleteVaccineAsync(Guid id, string userId);
}

public class VaccineService : IVaccineService
{
    private readonly ApplicationDbContext _context;

    public VaccineService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<Vaccine> CreateVaccineAsync(CreateVaccineInput input, string userId)
    {
        // Verify the child belongs to the user
        var child = await _context.Children
            .FirstOrDefaultAsync(c => c.Id == input.ChildId && c.UserId == userId);

        if (child == null)
        {
            throw new UnauthorizedAccessException("Child not found or you don't have permission to access this child.");
        }

        var vaccine = new Vaccine
        {
            VaccineName = input.VaccineName.Trim(),
            DateAdministered = input.DateAdministered,
            Manufacturer = string.IsNullOrWhiteSpace(input.Manufacturer) ? null : input.Manufacturer.Trim(),
            BatchNumber = string.IsNullOrWhiteSpace(input.BatchNumber) ? null : input.BatchNumber.Trim(),
            AdministeredBy = string.IsNullOrWhiteSpace(input.AdministeredBy) ? null : input.AdministeredBy.Trim(),
            Location = string.IsNullOrWhiteSpace(input.Location) ? null : input.Location.Trim(),
            NextDueDate = input.NextDueDate,
            Notes = string.IsNullOrWhiteSpace(input.Notes) ? null : input.Notes.Trim(),
            SideEffects = string.IsNullOrWhiteSpace(input.SideEffects) ? null : input.SideEffects.Trim(),
            ChildId = input.ChildId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _context.Vaccines.Add(vaccine);
        await _context.SaveChangesAsync();

        // Load the child navigation property
        await _context.Entry(vaccine)
            .Reference(v => v.Child)
            .LoadAsync();

        return vaccine;
    }

    public async Task<Vaccine?> GetVaccineByIdAsync(Guid id, string userId)
    {
        return await _context.Vaccines
            .Include(v => v.Child)
            .FirstOrDefaultAsync(v => v.Id == id && v.Child.UserId == userId);
    }

    public async Task<IEnumerable<Vaccine>> GetVaccinesByChildIdAsync(Guid childId, string userId)
    {
        return await _context.Vaccines
            .Include(v => v.Child)
            .Where(v => v.ChildId == childId && v.Child.UserId == userId)
            .OrderByDescending(v => v.DateAdministered)
            .ToListAsync();
    }

    public async Task<IEnumerable<Vaccine>> GetAllVaccinesForUserAsync(string userId)
    {
        return await _context.Vaccines
            .Include(v => v.Child)
            .Where(v => v.Child.UserId == userId)
            .OrderByDescending(v => v.DateAdministered)
            .ToListAsync();
    }

    public async Task<IEnumerable<Vaccine>> GetUpcomingVaccinesAsync(string userId, int daysAhead = 30)
    {
        var cutoffDate = DateTime.UtcNow.AddDays(daysAhead);
        
        return await _context.Vaccines
            .Include(v => v.Child)
            .Where(v => v.Child.UserId == userId && 
                       v.NextDueDate.HasValue && 
                       v.NextDueDate.Value <= cutoffDate && 
                       v.NextDueDate.Value >= DateTime.UtcNow)
            .OrderBy(v => v.NextDueDate)
            .ToListAsync();
    }

    public async Task<Vaccine> UpdateVaccineAsync(UpdateVaccineInput input, string userId)
    {
        var vaccine = await _context.Vaccines
            .Include(v => v.Child)
            .FirstOrDefaultAsync(v => v.Id == input.Id && v.Child.UserId == userId);

        if (vaccine == null)
        {
            throw new UnauthorizedAccessException("Vaccine not found or you don't have permission to access this vaccine.");
        }

        vaccine.VaccineName = input.VaccineName.Trim();
        vaccine.DateAdministered = input.DateAdministered;
        vaccine.Manufacturer = string.IsNullOrWhiteSpace(input.Manufacturer) ? null : input.Manufacturer.Trim();
        vaccine.BatchNumber = string.IsNullOrWhiteSpace(input.BatchNumber) ? null : input.BatchNumber.Trim();
        vaccine.AdministeredBy = string.IsNullOrWhiteSpace(input.AdministeredBy) ? null : input.AdministeredBy.Trim();
        vaccine.Location = string.IsNullOrWhiteSpace(input.Location) ? null : input.Location.Trim();
        vaccine.NextDueDate = input.NextDueDate;
        vaccine.Notes = string.IsNullOrWhiteSpace(input.Notes) ? null : input.Notes.Trim();
        vaccine.SideEffects = string.IsNullOrWhiteSpace(input.SideEffects) ? null : input.SideEffects.Trim();
        vaccine.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        return vaccine;
    }

    public async Task<bool> DeleteVaccineAsync(Guid id, string userId)
    {
        var vaccine = await _context.Vaccines
            .Include(v => v.Child)
            .FirstOrDefaultAsync(v => v.Id == id && v.Child.UserId == userId);

        if (vaccine == null)
        {
            return false;
        }

        _context.Vaccines.Remove(vaccine);
        await _context.SaveChangesAsync();
        return true;
    }
}