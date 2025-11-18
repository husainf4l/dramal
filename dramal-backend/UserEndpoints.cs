using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Models.Auth;
using Models.Users;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

public static class UserEndpoints
{
    public static void AddRoutes(this IEndpointRouteBuilder app)
    {
        app.MapPost("/api/users/login", Handle);
        app.MapPost("/api/users/refresh", RefreshHandle);
    }

    private static async Task<IResult> Handle(
        [FromBody] LoginUserRequest request,
        IOptions<AuthConfiguration> authOptions,
        UserManager<User> userManager,
        SignInManager<User> signInManager,
        ApplicationDbContext db,
        CancellationToken cancellationToken)
    {
        var user = await userManager.FindByEmailAsync(request.Email);
        if (user is null)
        {
            return Results.NotFound("User not found");
        }

        var result = await signInManager.CheckPasswordSignInAsync(user, request.Password, false);
        if (!result.Succeeded)
        {
            return Results.Unauthorized();
        }

        var token = await GenerateJwtToken(user, authOptions.Value, userManager);
        var refreshToken = GenerateRefreshToken();
        db.RefreshTokens.Add(new RefreshToken { Token = refreshToken, UserId = user.Id, ExpiresAt = DateTime.Now.AddDays(7) });
        await db.SaveChangesAsync(cancellationToken);

        return Results.Ok(new { Token = token, RefreshToken = refreshToken });
    }

    private static async Task<IResult> RefreshHandle(
        [FromBody] RefreshTokenRequest request,
        ApplicationDbContext db,
        IOptions<AuthConfiguration> authOptions,
        UserManager<User> userManager,
        CancellationToken cancellationToken)
    {
        var storedToken = await db.RefreshTokens.FirstOrDefaultAsync(rt => rt.Token == request.RefreshToken && !rt.IsRevoked && rt.ExpiresAt > DateTime.Now, cancellationToken);
        if (storedToken is null)
        {
            return Results.Unauthorized();
        }

        var user = await userManager.FindByIdAsync(storedToken.UserId);
        if (user is null)
        {
            return Results.Unauthorized();
        }

        var newToken = await GenerateJwtToken(user, authOptions.Value, userManager);
        var newRefreshToken = GenerateRefreshToken();

        storedToken.IsRevoked = true;
        db.RefreshTokens.Add(new RefreshToken { Token = newRefreshToken, UserId = user.Id, ExpiresAt = DateTime.Now.AddDays(7) });
        await db.SaveChangesAsync(cancellationToken);

        return Results.Ok(new { Token = newToken, RefreshToken = newRefreshToken });
    }

    private static async Task<string> GenerateJwtToken(User user, AuthConfiguration authConfiguration, UserManager<User> userManager)
    {
        var roles = await userManager.GetRolesAsync(user);
        var roleClaims = await userManager.GetClaimsAsync(user);

        List<Claim> claims = new()
        {
            new(JwtRegisteredClaimNames.Sub, user.Email!),
            new("userid", user.Id)
        };

        foreach (var role in roles)
        {
            claims.Add(new Claim("role", role));
        }

        foreach (var roleClaim in roleClaims)
        {
            claims.Add(new Claim(roleClaim.Type, roleClaim.Value));
        }

        var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(authConfiguration.Key));
        var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: authConfiguration.Issuer,
            audience: authConfiguration.Audience,
            claims: claims,
            expires: DateTime.Now.AddMinutes(30),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    private static string GenerateRefreshToken()
    {
        return Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));
    }
}