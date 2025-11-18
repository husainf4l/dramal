using HotChocolate;

namespace Models.Auth;

[MutationType]
public class AuthResolver
{
    public async Task<AuthResponse> Register(
        RegisterInput input,
        [Service] IAuthService authService)
    {
        return await authService.RegisterAsync(input);
    }

    public async Task<AuthResponse> Login(
        LoginInput input,
        [Service] IAuthService authService)
    {
        return await authService.LoginAsync(input);
    }

    public async Task<AuthResponse> RefreshToken(
        RefreshTokenInput input,
        [Service] IAuthService authService)
    {
        return await authService.RefreshTokenAsync(input);
    }

    public async Task<bool> RevokeToken(
        RefreshTokenInput input,
        [Service] IAuthService authService)
    {
        return await authService.RevokeTokenAsync(input.RefreshToken);
    }
}