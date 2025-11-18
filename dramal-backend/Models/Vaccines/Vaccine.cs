using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Models.Children;

namespace Dramal.Models.Vaccines;

public class Vaccine
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    [MaxLength(200)]
    public string VaccineName { get; set; } = string.Empty;

    [Required]
    public DateTime DateAdministered { get; set; }

    [MaxLength(100)]
    public string? Manufacturer { get; set; }

    [MaxLength(50)]
    public string? BatchNumber { get; set; }

    [MaxLength(200)]
    public string? AdministeredBy { get; set; }

    [MaxLength(200)]
    public string? Location { get; set; }

    public DateTime? NextDueDate { get; set; }

    [MaxLength(1000)]
    public string? Notes { get; set; }

    [MaxLength(100)]
    public string? SideEffects { get; set; }

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