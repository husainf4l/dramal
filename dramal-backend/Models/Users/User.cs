using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;

namespace Models.Users;

public class User : IdentityUser
{
    [Required]
    [MaxLength(100)]
    public string FirstName { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(100)]
    public string LastName { get; set; } = string.Empty;
    
    // Navigation property - one user can have many children
    public ICollection<Models.Children.Children> Children { get; set; } = new List<Models.Children.Children>();
}