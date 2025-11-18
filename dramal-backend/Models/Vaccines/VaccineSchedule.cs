using System.ComponentModel.DataAnnotations;

namespace Dramal.Models.Vaccines;

public class VaccineSchedule
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    [MaxLength(200)]
    public string VaccineName { get; set; } = string.Empty;

    [Required]
    public int DoseNumber { get; set; }

    [Required]
    [MaxLength(100)]
    public string RecommendedAge { get; set; } = string.Empty;

    [Required]
    public int AgeInDays { get; set; } // For calculation purposes

    [Required]
    public int ScheduleOrder { get; set; } // For ordering vaccines chronologically

    [Required]
    [MaxLength(5000)]
    public string VaccineInfo { get; set; } = string.Empty; // Detailed CDC information

    [MaxLength(200)]
    public string? AlternativeNames { get; set; } // Alternative vaccine names/brands

    public bool IsRequired { get; set; } = true;

    [MaxLength(500)]
    public string? SpecialNotes { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

public class VaccineRecommendation
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string VaccineName { get; set; } = string.Empty;
    public int DoseNumber { get; set; }
    public string RecommendedAge { get; set; } = string.Empty;
    public DateTime RecommendedDate { get; set; }
    public bool IsOverdue { get; set; }
    public bool IsCompleted { get; set; }
    public DateTime? CompletedDate { get; set; }
    public string VaccineInfo { get; set; } = string.Empty;
    public string? SpecialNotes { get; set; }
    public int DaysUntilDue { get; set; }
}