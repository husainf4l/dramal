namespace Models.Children;

/// <summary>
/// DTO for creating a new child
/// </summary>
public record CreateChildInput(
    string FirstName,
    string? LastName,
    DateTime DateOfBirth,
    string? Gender,
    string? Notes
);

/// <summary>
/// DTO for updating an existing child
/// </summary>
public record UpdateChildInput(
    Guid Id,
    string FirstName,
    string? LastName,
    DateTime DateOfBirth,
    string? Gender,
    string? Notes
);

/// <summary>
/// DTO for child response (optional - HotChocolate can auto-generate from entity)
/// </summary>
public record ChildrenDto(
    Guid Id,
    string FirstName,
    string? LastName,
    DateTime DateOfBirth,
    string? Gender,
    string? Notes,
    DateTime CreatedAt,
    DateTime? UpdatedAt,
    string UserId
);