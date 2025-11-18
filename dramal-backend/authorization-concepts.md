# Authorization Concepts for Dramal

This document outlines comprehensive authorization concepts you can implement in your application.

## Current Implementation

### 1. Role-Based Access Control (RBAC)

**Roles Available:**
- `SuperAdmin` - Full system access
- `Admin` - Administrative access
- `User` - Basic user access

### 2. Claims-Based Authorization

**Current Claims:**
- `users:create` - Can create new users
- `users:read` - Can read user information
- `users:update` - Can update user information
- `users:delete` - Can delete users

### 3. Policy-Based Authorization

**Current Policies:**
```csharp
// Individual permissions
options.AddPolicy("users:create", policy => policy.RequireClaim("users:create", "true"));
options.AddPolicy("users:update", policy => policy.RequireClaim("users:update", "true"));
options.AddPolicy("users:delete", policy => policy.RequireClaim("users:delete", "true"));
options.AddPolicy("users:read", policy => policy.RequireClaim("users:read", "true"));

// Role-based policies
options.AddPolicy("admin", policy => policy.RequireRole("Admin", "SuperAdmin"));
options.AddPolicy("superadmin", policy => policy.RequireRole("SuperAdmin"));
```

## Extended Authorization Concepts

### 1. Resource-Based Authorization

For scenarios where authorization depends on the specific resource being accessed:

```csharp
// Custom requirement
public class OwnershipRequirement : IAuthorizationRequirement
{
    public string UserIdClaim { get; set; } = "userid";
}

// Custom handler
public class OwnershipHandler : AuthorizationHandler<OwnershipRequirement, IOwnedResource>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        OwnershipRequirement requirement,
        IOwnedResource resource)
    {
        var userId = context.User.FindFirst(requirement.UserIdClaim)?.Value;
        if (userId != null && userId == resource.OwnerId)
        {
            context.Succeed(requirement);
        }
        return Task.CompletedTask;
    }
}

// Interface for owned resources
public interface IOwnedResource
{
    string OwnerId { get; }
}
```

### 2. Permission-Based System

Create a more granular permission system:

```csharp
public static class Permissions
{
    // User management
    public const string Users_Create = "users:create";
    public const string Users_Read = "users:read";
    public const string Users_Update = "users:update";
    public const string Users_Delete = "users:delete";
    public const string Users_ManageRoles = "users:manage_roles";
    
    // Profile management
    public const string Profile_Read = "profile:read";
    public const string Profile_Update = "profile:update";
    public const string Profile_ViewOthers = "profile:view_others";
    
    // System administration
    public const string System_ViewLogs = "system:view_logs";
    public const string System_ManageSettings = "system:manage_settings";
    public const string System_Backup = "system:backup";
    
    // Data management
    public const string Data_Export = "data:export";
    public const string Data_Import = "data:import";
    public const string Data_Purge = "data:purge";
}

public static class PermissionPolicies
{
    public static void Configure(AuthorizationOptions options)
    {
        // User management policies
        options.AddPolicy(Permissions.Users_Create, policy => 
            policy.RequireClaim(Permissions.Users_Create, "true"));
        options.AddPolicy(Permissions.Users_Read, policy => 
            policy.RequireClaim(Permissions.Users_Read, "true"));
        options.AddPolicy(Permissions.Users_Update, policy => 
            policy.RequireClaim(Permissions.Users_Update, "true"));
        options.AddPolicy(Permissions.Users_Delete, policy => 
            policy.RequireClaim(Permissions.Users_Delete, "true"));
        options.AddPolicy(Permissions.Users_ManageRoles, policy => 
            policy.RequireClaim(Permissions.Users_ManageRoles, "true"));
            
        // Profile policies
        options.AddPolicy(Permissions.Profile_Read, policy => 
            policy.RequireClaim(Permissions.Profile_Read, "true"));
        options.AddPolicy(Permissions.Profile_Update, policy => 
            policy.RequireClaim(Permissions.Profile_Update, "true"));
        options.AddPolicy(Permissions.Profile_ViewOthers, policy => 
            policy.RequireClaim(Permissions.Profile_ViewOthers, "true"));
            
        // System administration policies
        options.AddPolicy(Permissions.System_ViewLogs, policy => 
            policy.RequireClaim(Permissions.System_ViewLogs, "true"));
        options.AddPolicy(Permissions.System_ManageSettings, policy => 
            policy.RequireClaim(Permissions.System_ManageSettings, "true"));
        options.AddPolicy(Permissions.System_Backup, policy => 
            policy.RequireClaim(Permissions.System_Backup, "true"));
            
        // Data management policies
        options.AddPolicy(Permissions.Data_Export, policy => 
            policy.RequireClaim(Permissions.Data_Export, "true"));
        options.AddPolicy(Permissions.Data_Import, policy => 
            policy.RequireClaim(Permissions.Data_Import, "true"));
        options.AddPolicy(Permissions.Data_Purge, policy => 
            policy.RequireClaim(Permissions.Data_Purge, "true"));
    }
}
```

### 3. Hierarchical Roles

```csharp
public static class RoleHierarchy
{
    public static readonly Dictionary<string, string[]> Hierarchy = new()
    {
        { "SuperAdmin", new[] { "Admin", "User" } },
        { "Admin", new[] { "User" } },
        { "User", new string[0] }
    };
    
    public static bool HasRole(ClaimsPrincipal user, string requiredRole)
    {
        var userRoles = user.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();
        
        // Check direct role
        if (userRoles.Contains(requiredRole))
            return true;
            
        // Check hierarchical roles
        foreach (var userRole in userRoles)
        {
            if (Hierarchy.ContainsKey(userRole) && 
                Hierarchy[userRole].Contains(requiredRole))
                return true;
        }
        
        return false;
    }
}
```

### 4. Time-Based Authorization

```csharp
public class TimeBasedRequirement : IAuthorizationRequirement
{
    public TimeSpan StartTime { get; set; }
    public TimeSpan EndTime { get; set; }
}

public class TimeBasedHandler : AuthorizationHandler<TimeBasedRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        TimeBasedRequirement requirement)
    {
        var now = DateTime.Now.TimeOfDay;
        if (now >= requirement.StartTime && now <= requirement.EndTime)
        {
            context.Succeed(requirement);
        }
        return Task.CompletedTask;
    }
}
```

### 5. Multi-Tenant Authorization

```csharp
public class TenantRequirement : IAuthorizationRequirement
{
    public string TenantClaimType { get; set; } = "tenant_id";
}

public class TenantHandler : AuthorizationHandler<TenantRequirement, ITenantResource>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        TenantRequirement requirement,
        ITenantResource resource)
    {
        var userTenantId = context.User.FindFirst(requirement.TenantClaimType)?.Value;
        if (userTenantId != null && userTenantId == resource.TenantId)
        {
            context.Succeed(requirement);
        }
        return Task.CompletedTask;
    }
}

public interface ITenantResource
{
    string TenantId { get; }
}
```

### 6. Feature Flag Authorization

```csharp
public class FeatureFlagRequirement : IAuthorizationRequirement
{
    public string FeatureName { get; set; }
    
    public FeatureFlagRequirement(string featureName)
    {
        FeatureName = featureName;
    }
}

public class FeatureFlagHandler : AuthorizationHandler<FeatureFlagRequirement>
{
    private readonly IFeatureFlagService _featureFlagService;
    
    public FeatureFlagHandler(IFeatureFlagService featureFlagService)
    {
        _featureFlagService = featureFlagService;
    }
    
    protected override async Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        FeatureFlagRequirement requirement)
    {
        var userId = context.User.FindFirst("userid")?.Value;
        var tenantId = context.User.FindFirst("tenant_id")?.Value;
        
        var isEnabled = await _featureFlagService.IsEnabledAsync(
            requirement.FeatureName, userId, tenantId);
            
        if (isEnabled)
        {
            context.Succeed(requirement);
        }
    }
}
```

## Implementation Examples

### 1. Endpoint Authorization

```csharp
// Simple policy-based
app.MapGet("/api/admin/users", GetAllUsers)
   .RequireAuthorization("admin");

// Permission-based
app.MapPost("/api/users", CreateUser)
   .RequireAuthorization(Permissions.Users_Create);

// Multiple requirements
app.MapDelete("/api/users/{id}", DeleteUser)
   .RequireAuthorization(policy => 
   {
       policy.RequireClaim(Permissions.Users_Delete, "true");
       policy.RequireRole("Admin", "SuperAdmin");
   });

// Custom authorization
app.MapPut("/api/users/{id}/profile", UpdateProfile)
   .RequireAuthorization("ownership");
```

### 2. Service-Level Authorization

```csharp
public class UserService
{
    private readonly IAuthorizationService _authorizationService;
    private readonly IHttpContextAccessor _httpContextAccessor;
    
    public async Task<User> GetUserAsync(string userId)
    {
        var user = _httpContextAccessor.HttpContext.User;
        var authResult = await _authorizationService.AuthorizeAsync(
            user, null, Permissions.Users_Read);
            
        if (!authResult.Succeeded)
            throw new UnauthorizedAccessException();
            
        // Get user logic...
    }
}
```

### 3. Conditional UI Authorization

```csharp
public class AuthorizationService
{
    private readonly IAuthorizationService _authService;
    
    public async Task<bool> CanUserAsync(ClaimsPrincipal user, string permission)
    {
        var result = await _authService.AuthorizeAsync(user, null, permission);
        return result.Succeeded;
    }
    
    public async Task<Dictionary<string, bool>> GetUserPermissionsAsync(ClaimsPrincipal user)
    {
        var permissions = new Dictionary<string, bool>();
        
        // Check all defined permissions
        var allPermissions = typeof(Permissions).GetFields()
            .Where(f => f.IsPublic && f.IsStatic && f.FieldType == typeof(string))
            .Select(f => f.GetValue(null).ToString());
            
        foreach (var permission in allPermissions)
        {
            permissions[permission] = await CanUserAsync(user, permission);
        }
        
        return permissions;
    }
}
```

## Best Practices

1. **Principle of Least Privilege**: Grant minimum necessary permissions
2. **Separation of Concerns**: Separate authentication from authorization
3. **Centralized Policy Management**: Define policies in one place
4. **Fail Secure**: Default to deny access
5. **Audit and Logging**: Log authorization decisions
6. **Regular Review**: Periodically review and update permissions
7. **Performance**: Cache authorization decisions when appropriate
8. **Testing**: Write tests for authorization logic

## Usage Recommendations

1. Start with simple role-based authorization
2. Add claims-based permissions for fine-grained control
3. Implement resource-based authorization for data ownership
4. Consider multi-tenancy if applicable
5. Add feature flags for A/B testing and gradual rollouts
6. Implement time-based restrictions if needed

Choose the concepts that best fit your application's requirements and gradually implement more sophisticated authorization as needed.