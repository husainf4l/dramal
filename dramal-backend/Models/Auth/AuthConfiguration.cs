public class AuthConfiguration
{
    public string Key { get; set; } = string.Empty;
    public string Issuer { get; set; } = string.Empty;
    public string Audience { get; set; } = string.Empty;
    public int AccessTokenExpirationMinutes { get; set; } = 60; // 1 hour default
    public int RefreshTokenExpirationDays { get; set; } = 7; // 7 days default
}