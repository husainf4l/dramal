namespace Dramal.Models.Vaccines;

public class CreateVaccineInput
{
    public string VaccineName { get; set; } = string.Empty;
    public DateTime DateAdministered { get; set; }
    public string? Manufacturer { get; set; }
    public string? BatchNumber { get; set; }
    public string? AdministeredBy { get; set; }
    public string? Location { get; set; }
    public DateTime? NextDueDate { get; set; }
    public string? Notes { get; set; }
    public string? SideEffects { get; set; }
    public Guid ChildId { get; set; }
}

public class UpdateVaccineInput
{
    public Guid Id { get; set; }
    public string VaccineName { get; set; } = string.Empty;
    public DateTime DateAdministered { get; set; }
    public string? Manufacturer { get; set; }
    public string? BatchNumber { get; set; }
    public string? AdministeredBy { get; set; }
    public string? Location { get; set; }
    public DateTime? NextDueDate { get; set; }
    public string? Notes { get; set; }
    public string? SideEffects { get; set; }
}