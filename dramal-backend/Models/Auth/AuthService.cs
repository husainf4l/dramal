using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens;
using Models.Users;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Options;
using Microsoft.EntityFrameworkCore;

namespace Models.Auth;

public interface IAuthService
{
    Task<AuthResponse> RegisterAsync(RegisterInput input);
    Task<AuthResponse> LoginAsync(LoginInput input);
    Task<AuthResponse> RefreshTokenAsync(RefreshTokenInput input);
    Task<bool> RevokeTokenAsync(string refreshToken);
}

public class AuthService : IAuthService
{
    private readonly UserManager<User> _userManager;
    private readonly ApplicationDbContext _context;
    private readonly AuthConfiguration _authConfig;

    public AuthService(
        UserManager<User> userManager,
        ApplicationDbContext context,
        IOptions<AuthConfiguration> authConfig)
    {
        _userManager = userManager;
        _context = context;
        _authConfig = authConfig.Value;
    }

    public async Task<AuthResponse> RegisterAsync(RegisterInput input)
    {
        var existingUser = await _userManager.FindByEmailAsync(input.Email);
        if (existingUser != null)
        {
            throw new ArgumentException("User with this email already exists.");
        }

        var user = new User
        {
            UserName = input.Email,
            Email = input.Email,
            FirstName = input.FirstName,
            LastName = input.LastName
        };

        var result = await _userManager.CreateAsync(user, input.Password);
        if (!result.Succeeded)
        {
            var errors = string.Join(", ", result.Errors.Select(e => e.Description));
            throw new ArgumentException($"User registration failed: {errors}");
        }

        // Assign default User role
        await _userManager.AddToRoleAsync(user, "User");

        return await GenerateAuthResponseAsync(user);
    }

    public async Task<AuthResponse> LoginAsync(LoginInput input)
    {
        var user = await _userManager.FindByEmailAsync(input.Email);
        if (user == null || !await _userManager.CheckPasswordAsync(user, input.Password))
        {
            throw new UnauthorizedAccessException("Invalid email or password.");
        }

        return await GenerateAuthResponseAsync(user);
    }

    public async Task<AuthResponse> RefreshTokenAsync(RefreshTokenInput input)
    {
        var refreshToken = await _context.RefreshTokens
            .Include(rt => rt.User)
            .FirstOrDefaultAsync(rt => rt.Token == input.RefreshToken && !rt.IsRevoked);

        if (refreshToken == null || refreshToken.ExpiresAt < DateTime.UtcNow)
        {
            throw new UnauthorizedAccessException("Invalid or expired refresh token.");
        }

        // Revoke the old refresh token
        refreshToken.IsRevoked = true;
        await _context.SaveChangesAsync();

        return await GenerateAuthResponseAsync(refreshToken.User);
    }

    public async Task<bool> RevokeTokenAsync(string refreshToken)
    {
        var token = await _context.RefreshTokens
            .FirstOrDefaultAsync(rt => rt.Token == refreshToken && !rt.IsRevoked);

        if (token == null)
        {
            return false;
        }

        token.IsRevoked = true;
        await _context.SaveChangesAsync();
        return true;
    }

    private async Task<AuthResponse> GenerateAuthResponseAsync(User user)
    {
        var roles = await _userManager.GetRolesAsync(user);
        var claims = await _userManager.GetClaimsAsync(user);

        var tokenClaims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, user.Id),
            new(ClaimTypes.Name, user.UserName!),
            new(ClaimTypes.Email, user.Email!),
            new("firstName", user.FirstName),
            new("lastName", user.LastName)
        };

        // Add role claims
        tokenClaims.AddRange(roles.Select(role => new Claim(ClaimTypes.Role, role)));

        // Add user claims
        tokenClaims.AddRange(claims);

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_authConfig.Key));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var expiration = DateTime.UtcNow.AddMinutes(_authConfig.AccessTokenExpirationMinutes);

        var token = new JwtSecurityToken(
            issuer: _authConfig.Issuer,
            audience: _authConfig.Audience,
            claims: tokenClaims,
            expires: expiration,
            signingCredentials: creds
        );

        var refreshToken = new RefreshToken
        {
            UserId = user.Id,
            Token = GenerateRefreshToken(),
            ExpiresAt = DateTime.UtcNow.AddDays(_authConfig.RefreshTokenExpirationDays),
            IsRevoked = false
        };

        _context.RefreshTokens.Add(refreshToken);
        await _context.SaveChangesAsync();

        return new AuthResponse
        {
            Token = new JwtSecurityTokenHandler().WriteToken(token),
            RefreshToken = refreshToken.Token,
            Expiration = expiration,
            User = new UserInfo
            {
                Id = user.Id,
                Email = user.Email!,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Roles = roles.ToList()
            }
        };
    }

    private static string GenerateRefreshToken()
    {
        var randomNumber = new byte[32];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(randomNumber);
        return Convert.ToBase64String(randomNumber);
    }
}