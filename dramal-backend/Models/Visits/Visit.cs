using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Models.Children;

namespace Dramal.Models.Visits;

public class Visit
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    [MaxLength(200)]
    public string VisitReason { get; set; } = string.Empty;

    [Required]
    public DateTime VisitDate { get; set; }

    [MaxLength(100)]
    public string? DoctorName { get; set; }

    [MaxLength(200)]
    public string? Clinic { get; set; }

    [MaxLength(1000)]
    public string? Diagnosis { get; set; }

    [MaxLength(1000)]
    public string? Treatment { get; set; }

    [MaxLength(1000)]
    public string? Medications { get; set; }

    [MaxLength(1000)]
    public string? Notes { get; set; }

    public DateTime? FollowUpDate { get; set; }

    [Required]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [Required]
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Foreign key to Children
    [Required]
    public Guid ChildId { get; set; }

    // Navigation property
    [ForeignKey("ChildId")]
    public virtual Children Child { get; set; } = null!;
}
