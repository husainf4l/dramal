using Microsoft.EntityFrameworkCore;
using Models.Children;

namespace Dramal.Models.Vaccines;

public interface IVaccineScheduleService
{
    Task<IEnumerable<VaccineRecommendation>> GetVaccineRecommendationsForChildAsync(Guid childId, string userId);
    Task<IEnumerable<VaccineRecommendation>> GetOverdueVaccinesForChildAsync(Guid childId, string userId);
    Task<IEnumerable<VaccineRecommendation>> GetUpcomingVaccinesForChildAsync(Guid childId, string userId, int daysAhead = 30);
    Task SeedVaccineScheduleAsync();
}

public class VaccineScheduleService : IVaccineScheduleService
{
    private readonly ApplicationDbContext _context;

    public VaccineScheduleService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<VaccineRecommendation>> GetVaccineRecommendationsForChildAsync(Guid childId, string userId)
    {
        // Verify child belongs to user
        var child = await _context.Children
            .FirstOrDefaultAsync(c => c.Id == childId && c.UserId == userId);

        if (child == null)
        {
            throw new UnauthorizedAccessException("Child not found or you don't have permission to access this child.");
        }

        // Get all vaccines administered to this child
        var administeredVaccines = await _context.Vaccines
            .Where(v => v.ChildId == childId)
            .ToListAsync();

        // Get vaccine schedule
        var schedules = await _context.VaccineSchedules
            .OrderBy(s => s.ScheduleOrder)
            .ToListAsync();

        var recommendations = new List<VaccineRecommendation>();
        var birthDate = child.DateOfBirth;
        var today = DateTime.UtcNow;

        foreach (var schedule in schedules)
        {
            var recommendedDate = birthDate.AddDays(schedule.AgeInDays);
            var daysUntilDue = (int)(recommendedDate - today).TotalDays;

            // Check if this vaccine dose has been administered
            var isCompleted = administeredVaccines.Any(v => 
                v.VaccineName.ToLower().Contains(schedule.VaccineName.ToLower()) && 
                v.DateAdministered <= recommendedDate.AddDays(30)); // Allow 30-day grace period

            var completedVaccine = administeredVaccines.FirstOrDefault(v => 
                v.VaccineName.ToLower().Contains(schedule.VaccineName.ToLower()) && 
                v.DateAdministered <= recommendedDate.AddDays(30));

            recommendations.Add(new VaccineRecommendation
            {
                Id = schedule.Id,
                VaccineName = schedule.VaccineName,
                DoseNumber = schedule.DoseNumber,
                RecommendedAge = schedule.RecommendedAge,
                RecommendedDate = recommendedDate,
                IsOverdue = today > recommendedDate && !isCompleted,
                IsCompleted = isCompleted,
                CompletedDate = completedVaccine?.DateAdministered,
                VaccineInfo = schedule.VaccineInfo,
                SpecialNotes = schedule.SpecialNotes,
                DaysUntilDue = daysUntilDue
            });
        }

        return recommendations;
    }

    public async Task<IEnumerable<VaccineRecommendation>> GetOverdueVaccinesForChildAsync(Guid childId, string userId)
    {
        var recommendations = await GetVaccineRecommendationsForChildAsync(childId, userId);
        return recommendations.Where(r => r.IsOverdue);
    }

    public async Task<IEnumerable<VaccineRecommendation>> GetUpcomingVaccinesForChildAsync(Guid childId, string userId, int daysAhead = 30)
    {
        var recommendations = await GetVaccineRecommendationsForChildAsync(childId, userId);
        var today = DateTime.UtcNow;
        var cutoffDate = today.AddDays(daysAhead);

        return recommendations.Where(r => 
            !r.IsCompleted && 
            r.RecommendedDate >= today && 
            r.RecommendedDate <= cutoffDate);
    }

    public async Task SeedVaccineScheduleAsync()
    {
        // Only seed if schedule is empty
        if (await _context.VaccineSchedules.AnyAsync())
            return;

        var schedules = new List<VaccineSchedule>
        {
            // Birth vaccines
            new() { VaccineName = "HepB", DoseNumber = 1, RecommendedAge = "Birth", AgeInDays = 0, ScheduleOrder = 0, VaccineInfo = "3-dose series at age 0, 1–2, 6–18 months. Birth weight ≥2,000 grams: 1 dose within 24 hours of birth if medically stable.", SpecialNotes = "First dose within 24 hours of birth" },

            // 2 months vaccines
            new() { VaccineName = "HepB", DoseNumber = 2, RecommendedAge = "1-2 Months", AgeInDays = 60, ScheduleOrder = 1, VaccineInfo = "Second dose of hepatitis B vaccine series" },
            new() { VaccineName = "Rotavirus (Rotarix)", DoseNumber = 1, RecommendedAge = "2 Months", AgeInDays = 60, ScheduleOrder = 2, VaccineInfo = "Rotarix®: 2-dose series at age 2 and 4 months. RotaTeq®: 3-dose series at age 2, 4, and 6 months" },
            new() { VaccineName = "Rotavirus (RotaTeq)", DoseNumber = 1, RecommendedAge = "2 Months", AgeInDays = 60, ScheduleOrder = 3, VaccineInfo = "RotaTeq®: 3-dose series at age 2, 4, and 6 months" },
            new() { VaccineName = "DTaP", DoseNumber = 1, RecommendedAge = "2 Months", AgeInDays = 60, ScheduleOrder = 4, VaccineInfo = "5-dose series at age 2, 4, 6, 15–18 months, 4–6 years" },
            new() { VaccineName = "Hib", DoseNumber = 1, RecommendedAge = "2 Months", AgeInDays = 60, ScheduleOrder = 5, VaccineInfo = "ActHIB®, Hiberix®, Pentacel®, or Vaxelis®: 4-dose series (3-dose primary series at age 2, 4, and 6 months, followed by a booster dose at age 12–15 months)" },
            new() { VaccineName = "PCV13/PCV15", DoseNumber = 1, RecommendedAge = "2 Months", AgeInDays = 60, ScheduleOrder = 7, VaccineInfo = "4-dose series at 2, 4, 6, 12–15 months" },
            new() { VaccineName = "IPV", DoseNumber = 1, RecommendedAge = "2 Months", AgeInDays = 60, ScheduleOrder = 8, VaccineInfo = "4-dose series at ages 2, 4, 6–18 months, 4–6 years" },

            // 4 months vaccines
            new() { VaccineName = "Rotavirus (Rotarix)", DoseNumber = 2, RecommendedAge = "4 Months", AgeInDays = 120, ScheduleOrder = 10, VaccineInfo = "Final dose for Rotarix series" },
            new() { VaccineName = "Rotavirus (RotaTeq)", DoseNumber = 2, RecommendedAge = "4 Months", AgeInDays = 120, ScheduleOrder = 11, VaccineInfo = "Second dose of RotaTeq series" },
            new() { VaccineName = "DTaP", DoseNumber = 2, RecommendedAge = "4 Months", AgeInDays = 120, ScheduleOrder = 12, VaccineInfo = "Second dose of DTaP series" },
            new() { VaccineName = "Hib", DoseNumber = 2, RecommendedAge = "4 Months", AgeInDays = 120, ScheduleOrder = 13, VaccineInfo = "Second dose of Hib series" },
            new() { VaccineName = "PCV13/PCV15", DoseNumber = 2, RecommendedAge = "4 Months", AgeInDays = 120, ScheduleOrder = 15, VaccineInfo = "Second dose of pneumococcal series" },
            new() { VaccineName = "IPV", DoseNumber = 2, RecommendedAge = "4 Months", AgeInDays = 120, ScheduleOrder = 16, VaccineInfo = "Second dose of polio vaccine series" },

            // 6 months vaccines
            new() { VaccineName = "Rotavirus (RotaTeq)", DoseNumber = 3, RecommendedAge = "6 Months", AgeInDays = 180, ScheduleOrder = 17, VaccineInfo = "Final dose for RotaTeq series" },
            new() { VaccineName = "DTaP", DoseNumber = 3, RecommendedAge = "6 Months", AgeInDays = 180, ScheduleOrder = 18, VaccineInfo = "Third dose of DTaP series" },
            new() { VaccineName = "Hib", DoseNumber = 3, RecommendedAge = "6 Months", AgeInDays = 180, ScheduleOrder = 19, VaccineInfo = "Third dose of Hib series (if using 4-dose schedule)" },
            new() { VaccineName = "PCV13/PCV15", DoseNumber = 3, RecommendedAge = "6 Months", AgeInDays = 180, ScheduleOrder = 20, VaccineInfo = "Third dose of pneumococcal series" },
            new() { VaccineName = "Influenza", DoseNumber = 1, RecommendedAge = "6 Months-8 Years", AgeInDays = 180, ScheduleOrder = 21, VaccineInfo = "Annual influenza vaccine. 2 doses separated by at least 4 weeks for first-time recipients under 9 years" },

            // 12-15 months vaccines
            new() { VaccineName = "Hib", DoseNumber = 4, RecommendedAge = "12-15 Months", AgeInDays = 365, ScheduleOrder = 31, VaccineInfo = "Booster dose for Hib series" },
            new() { VaccineName = "PCV13/PCV15", DoseNumber = 4, RecommendedAge = "12-15 Months", AgeInDays = 365, ScheduleOrder = 33, VaccineInfo = "Final dose of pneumococcal series" },
            new() { VaccineName = "MMR", DoseNumber = 1, RecommendedAge = "12-15 Months", AgeInDays = 365, ScheduleOrder = 34, VaccineInfo = "2-dose series at age 12–15 months, age 4–6 years" },
            new() { VaccineName = "Varicella", DoseNumber = 1, RecommendedAge = "12-15 Months", AgeInDays = 365, ScheduleOrder = 35, VaccineInfo = "2-dose series at age 12–15 months, 4–6 years" },
            new() { VaccineName = "HepA", DoseNumber = 1, RecommendedAge = "12-23 Months", AgeInDays = 365, ScheduleOrder = 36, VaccineInfo = "2-dose series (minimum interval: 6 months) at age 12–23 months" },

            // 15-18 months vaccines
            new() { VaccineName = "DTaP", DoseNumber = 4, RecommendedAge = "15-18 Months", AgeInDays = 480, ScheduleOrder = 38, VaccineInfo = "Fourth dose of DTaP series" },

            // 18-23 months vaccines
            new() { VaccineName = "HepA", DoseNumber = 2, RecommendedAge = "18-23 Months", AgeInDays = 550, ScheduleOrder = 37, VaccineInfo = "Second dose of hepatitis A series" },

            // 4-6 years vaccines
            new() { VaccineName = "DTaP", DoseNumber = 5, RecommendedAge = "4-6 Years", AgeInDays = 1460, ScheduleOrder = 40, VaccineInfo = "Final dose of DTaP series" },
            new() { VaccineName = "IPV", DoseNumber = 4, RecommendedAge = "4-6 Years", AgeInDays = 1460, ScheduleOrder = 41, VaccineInfo = "Final dose of polio vaccine series" },
            new() { VaccineName = "MMR", DoseNumber = 2, RecommendedAge = "4-6 Years", AgeInDays = 1460, ScheduleOrder = 42, VaccineInfo = "Second dose of MMR vaccine" },
            new() { VaccineName = "Varicella", DoseNumber = 2, RecommendedAge = "4-6 Years", AgeInDays = 1460, ScheduleOrder = 43, VaccineInfo = "Second dose of varicella vaccine" },

            // 11-12 years vaccines
            new() { VaccineName = "Tdap", DoseNumber = 1, RecommendedAge = "11-12 Years", AgeInDays = 4015, ScheduleOrder = 45, VaccineInfo = "Adolescents age 11–12 years: 1 dose Tdap" },
            new() { VaccineName = "Meningococcal", DoseNumber = 1, RecommendedAge = "11-12 Years", AgeInDays = 4015, ScheduleOrder = 46, VaccineInfo = "2-dose series at age 11–12 years; 16 years" },
            new() { VaccineName = "HPV", DoseNumber = 1, RecommendedAge = "11-12 Years", AgeInDays = 4015, ScheduleOrder = 48, VaccineInfo = "HPV vaccination routinely recommended at age 11–12 years (can start at age 9 years)" },

            // 16 years vaccines
            new() { VaccineName = "Meningococcal", DoseNumber = 2, RecommendedAge = "16 Years", AgeInDays = 5840, ScheduleOrder = 47, VaccineInfo = "Second dose of meningococcal vaccine" }
        };

        _context.VaccineSchedules.AddRange(schedules);
        await _context.SaveChangesAsync();
    }
}