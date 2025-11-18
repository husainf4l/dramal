using Microsoft.EntityFrameworkCore;
using HotChocolate;
using HotChocolate.Authorization;
using HotChocolate.Data;
using System.Security.Claims;

namespace Models.Children;

[QueryType]
public class ChildrenResolver
{
    /// <summary>
    /// Get all children for the current user
    /// </summary>
    [Authorize]
    [UseFiltering]
    [UseSorting]
    public async Task<IQueryable<Children>> GetMyChildren(
        [Service] IChildrenService childrenService,
        ClaimsPrincipal claimsPrincipal)
    {
        var userId = claimsPrincipal.FindFirst("userid")?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new GraphQLException("User not authenticated");

        return await childrenService.GetMyChildrenAsync(userId);
    }

    /// <summary>
    /// Get a specific child by ID (only if owned by current user)
    /// </summary>
    [Authorize]
    public async Task<Children?> GetChildById(
        Guid id,
        [Service] IChildrenService childrenService,
        ClaimsPrincipal claimsPrincipal,
        CancellationToken cancellationToken)
    {
        var userId = claimsPrincipal.FindFirst("userid")?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new GraphQLException("User not authenticated");

        return await childrenService.GetChildByIdAsync(id, userId, cancellationToken);
    }

    /// <summary>
    /// Get children count for current user
    /// </summary>
    [Authorize]
    public async Task<int> GetMyChildrenCount(
        [Service] IChildrenService childrenService,
        ClaimsPrincipal claimsPrincipal,
        CancellationToken cancellationToken)
    {
        var userId = claimsPrincipal.FindFirst("userid")?.Value;
        if (string.IsNullOrEmpty(userId))
            return 0;

        return await childrenService.GetMyChildrenCountAsync(userId, cancellationToken);
    }
}

[MutationType]
public class ChildrenMutations
{
    /// <summary>
    /// Create a new child for the current user
    /// </summary>
    [Authorize]
    public async Task<Children> CreateChild(
        CreateChildInput input,
        [Service] IChildrenService childrenService,
        ClaimsPrincipal claimsPrincipal,
        CancellationToken cancellationToken)
    {
        var userId = claimsPrincipal.FindFirst("userid")?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new GraphQLException("User not authenticated");

        return await childrenService.CreateChildAsync(input, userId, cancellationToken);
    }

    /// <summary>
    /// Update an existing child (only if owned by current user)
    /// </summary>
    [Authorize]
    public async Task<Children?> UpdateChild(
        UpdateChildInput input,
        [Service] IChildrenService childrenService,
        ClaimsPrincipal claimsPrincipal,
        CancellationToken cancellationToken)
    {
        var userId = claimsPrincipal.FindFirst("userid")?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new GraphQLException("User not authenticated");

        return await childrenService.UpdateChildAsync(input, userId, cancellationToken);
    }

    /// <summary>
    /// Delete a child (only if owned by current user)
    /// </summary>
    [Authorize]
    public async Task<bool> DeleteChild(
        Guid id,
        [Service] IChildrenService childrenService,
        ClaimsPrincipal claimsPrincipal,
        CancellationToken cancellationToken)
    {
        var userId = claimsPrincipal.FindFirst("userid")?.Value;
        if (string.IsNullOrEmpty(userId))
            throw new GraphQLException("User not authenticated");

        return await childrenService.DeleteChildAsync(id, userId, cancellationToken);
    }
}