using System.ComponentModel.DataAnnotations;
using Models.Users;

namespace Models.Children;

public class Children
{
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [Required]
    [StringLength(100)]
    public string FirstName { get; set; } = string.Empty;
    
    [StringLength(100)]
    public string? LastName { get; set; }
    
    [Required]
    public DateTime DateOfBirth { get; set; }
    
    [StringLength(10)]
    public string? Gender { get; set; }
    
    [StringLength(500)]
    public string? Notes { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
    
    // Foreign key to User
    [Required]
    public string UserId { get; set; } = string.Empty;
    
    // Navigation property
    public User User { get; set; } = null!;
    
    // Navigation property for visits and vaccines
    public virtual ICollection<Dramal.Models.Visits.Visit> Visits { get; set; } = new List<Dramal.Models.Visits.Visit>();
    public virtual ICollection<Dramal.Models.Vaccines.Vaccine> Vaccines { get; set; } = new List<Dramal.Models.Vaccines.Vaccine>();
}