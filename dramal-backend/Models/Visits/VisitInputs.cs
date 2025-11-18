namespace Dramal.Models.Visits;

public class CreateVisitInput
{
    public string VisitReason { get; set; } = string.Empty;
    public DateTime VisitDate { get; set; }
    public string? DoctorName { get; set; }
    public string? Clinic { get; set; }
    public string? Diagnosis { get; set; }
    public string? Treatment { get; set; }
    public string? Medications { get; set; }
    public string? Notes { get; set; }
    public DateTime? FollowUpDate { get; set; }
    public Guid ChildId { get; set; }
}

public class UpdateVisitInput
{
    public Guid Id { get; set; }
    public string VisitReason { get; set; } = string.Empty;
    public DateTime VisitDate { get; set; }
    public string? DoctorName { get; set; }
    public string? Clinic { get; set; }
    public string? Diagnosis { get; set; }
    public string? Treatment { get; set; }
    public string? Medications { get; set; }
    public string? Notes { get; set; }
    public DateTime? FollowUpDate { get; set; }
}