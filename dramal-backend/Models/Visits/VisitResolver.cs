using HotChocolate.Authorization;
using System.Security.Claims;

namespace Dramal.Models.Visits;

public class VisitResolver
{
    [Authorize]
    public async Task<IEnumerable<Visit>> GetVisits(
        IVisitService visitService,
        ClaimsPrincipal claimsPrincipal)
    {
        var userId = claimsPrincipal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new UnauthorizedAccessException("User not authenticated");

        return await visitService.GetAllVisitsForUserAsync(userId);
    }

    [Authorize]
    public async Task<Visit?> GetVisit(
        Guid id,
        IVisitService visitService,
        ClaimsPrincipal claimsPrincipal)
    {
        var userId = claimsPrincipal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new UnauthorizedAccessException("User not authenticated");

        return await visitService.GetVisitByIdAsync(id, userId);
    }

    [Authorize]
    public async Task<IEnumerable<Visit>> GetVisitsByChild(
        Guid childId,
        IVisitService visitService,
        ClaimsPrincipal claimsPrincipal)
    {
        var userId = claimsPrincipal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new UnauthorizedAccessException("User not authenticated");

        return await visitService.GetVisitsByChildIdAsync(childId, userId);
    }

    [Authorize]
    public async Task<Visit> CreateVisit(
        CreateVisitInput input,
        IVisitService visitService,
        ClaimsPrincipal claimsPrincipal)
    {
        var userId = claimsPrincipal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new UnauthorizedAccessException("User not authenticated");

        return await visitService.CreateVisitAsync(input, userId);
    }

    [Authorize]
    public async Task<Visit> UpdateVisit(
        UpdateVisitInput input,
        IVisitService visitService,
        ClaimsPrincipal claimsPrincipal)
    {
        var userId = claimsPrincipal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new UnauthorizedAccessException("User not authenticated");

        return await visitService.UpdateVisitAsync(input, userId);
    }

    [Authorize]
    public async Task<bool> DeleteVisit(
        Guid id,
        IVisitService visitService,
        ClaimsPrincipal claimsPrincipal)
    {
        var userId = claimsPrincipal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new UnauthorizedAccessException("User not authenticated");

        return await visitService.DeleteVisitAsync(id, userId);
    }
}