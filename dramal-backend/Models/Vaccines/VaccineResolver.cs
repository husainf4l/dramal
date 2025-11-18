using HotChocolate;
using HotChocolate.Authorization;
using System.Security.Claims;

namespace Dramal.Models.Vaccines;

public class VaccineResolver
{
    [Authorize]
    public async Task<IEnumerable<Vaccine>> GetVaccines(
        [Service] IVaccineService vaccineService,
        ClaimsPrincipal claimsPrincipal)
    {
        var userId = claimsPrincipal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new UnauthorizedAccessException("User not authenticated");

        return await vaccineService.GetAllVaccinesForUserAsync(userId);
    }

    [Authorize]
    public async Task<Vaccine?> GetVaccine(
        Guid id,
        [Service] IVaccineService vaccineService,
        ClaimsPrincipal claimsPrincipal)
    {
        var userId = claimsPrincipal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new UnauthorizedAccessException("User not authenticated");

        return await vaccineService.GetVaccineByIdAsync(id, userId);
    }

    [Authorize]
    public async Task<IEnumerable<Vaccine>> GetVaccinesByChild(
        Guid childId,
        [Service] IVaccineService vaccineService,
        ClaimsPrincipal claimsPrincipal)
    {
        var userId = claimsPrincipal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new UnauthorizedAccessException("User not authenticated");

        return await vaccineService.GetVaccinesByChildIdAsync(childId, userId);
    }

    [Authorize]
    public async Task<IEnumerable<Vaccine>> GetUpcomingVaccines(
        int daysAhead,
        [Service] IVaccineService vaccineService,
        ClaimsPrincipal claimsPrincipal)
    {
        var userId = claimsPrincipal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new UnauthorizedAccessException("User not authenticated");

        return await vaccineService.GetUpcomingVaccinesAsync(userId, daysAhead);
    }

    [Authorize]
    public async Task<Vaccine> CreateVaccine(
        CreateVaccineInput input,
        [Service] IVaccineService vaccineService,
        ClaimsPrincipal claimsPrincipal)
    {
        var userId = claimsPrincipal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new UnauthorizedAccessException("User not authenticated");

        return await vaccineService.CreateVaccineAsync(input, userId);
    }

    [Authorize]
    public async Task<Vaccine> UpdateVaccine(
        UpdateVaccineInput input,
        [Service] IVaccineService vaccineService,
        ClaimsPrincipal claimsPrincipal)
    {
        var userId = claimsPrincipal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new UnauthorizedAccessException("User not authenticated");

        return await vaccineService.UpdateVaccineAsync(input, userId);
    }

    [Authorize]
    public async Task<bool> DeleteVaccine(
        Guid id,
        [Service] IVaccineService vaccineService,
        ClaimsPrincipal claimsPrincipal)
    {
        var userId = claimsPrincipal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new UnauthorizedAccessException("User not authenticated");

        return await vaccineService.DeleteVaccineAsync(id, userId);
    }

    [Authorize]
    public async Task<IEnumerable<VaccineRecommendation>> GetVaccineRecommendations(
        Guid childId,
        [Service] IVaccineScheduleService scheduleService,
        ClaimsPrincipal claimsPrincipal)
    {
        var userId = claimsPrincipal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new UnauthorizedAccessException("User not authenticated");

        return await scheduleService.GetVaccineRecommendationsForChildAsync(childId, userId);
    }

    [Authorize]
    public async Task<IEnumerable<VaccineRecommendation>> GetOverdueVaccines(
        Guid childId,
        [Service] IVaccineScheduleService scheduleService,
        ClaimsPrincipal claimsPrincipal)
    {
        var userId = claimsPrincipal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new UnauthorizedAccessException("User not authenticated");

        return await scheduleService.GetOverdueVaccinesForChildAsync(childId, userId);
    }

    [Authorize]
    public async Task<IEnumerable<VaccineRecommendation>> GetUpcomingVaccinesForChild(
        Guid childId,
        int daysAhead,
        [Service] IVaccineScheduleService scheduleService,
        ClaimsPrincipal claimsPrincipal)
    {
        var userId = claimsPrincipal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new UnauthorizedAccessException("User not authenticated");

        return await scheduleService.GetUpcomingVaccinesForChildAsync(childId, userId, daysAhead);
    }
}