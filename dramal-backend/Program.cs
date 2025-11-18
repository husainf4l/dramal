using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Models.Auth;
using Models.Users;
using Models.Children;
using System.Security.Claims;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();
builder.Services.AddSwaggerGen();

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql("Host=149.200.251.12;Port=5432;Username=husain;Password=tt55oo77;Database=aqlaanauth"));

builder.Services.AddIdentity<User, IdentityRole>()
    .AddEntityFrameworkStores<ApplicationDbContext>()
    .AddDefaultTokenProviders();

// Register vaccine services
builder.Services.AddScoped<Dramal.Models.Vaccines.IVaccineService, Dramal.Models.Vaccines.VaccineService>();
builder.Services.AddScoped<Dramal.Models.Vaccines.IVaccineScheduleService, Dramal.Models.Vaccines.VaccineScheduleService>();

builder.Services.Configure<AuthConfiguration>(builder.Configuration.GetSection("AuthConfiguration"));

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration["AuthConfiguration:Issuer"],
        ValidAudience = builder.Configuration["AuthConfiguration:Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(builder.Configuration["AuthConfiguration:Key"]!))
    };
});

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("books:create", policy => policy.RequireClaim("books:create"));
    options.AddPolicy("books:update", policy => policy.RequireClaim("books:update"));
    options.AddPolicy("books:delete", policy => policy.RequireClaim("books:delete"));

    options.AddPolicy("users:create", policy => policy.RequireClaim("users:create", "true"));
    options.AddPolicy("users:update", policy => policy.RequireClaim("users:update"));
    options.AddPolicy("users:delete", policy => policy.RequireClaim("users:delete"));
});

var app = builder.Build();

// Seed roles
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    var roleManager = services.GetRequiredService<RoleManager<IdentityRole>>();
    var context = services.GetRequiredService<ApplicationDbContext>();
    context.Database.EnsureCreated();

    string[] roleNames = { "SuperAdmin", "Admin", "User" };
    foreach (var roleName in roleNames)
    {
        if (!await roleManager.RoleExistsAsync(roleName))
        {
            await roleManager.CreateAsync(new IdentityRole(roleName));
        }
    }

    // Add claims to roles
    var superAdminRole = await roleManager.FindByNameAsync("SuperAdmin");
    if (superAdminRole != null)
    {
        await roleManager.AddClaimAsync(superAdminRole, new Claim("users:create", "true"));
        await roleManager.AddClaimAsync(superAdminRole, new Claim("users:update", "true"));
        await roleManager.AddClaimAsync(superAdminRole, new Claim("users:delete", "true"));
        await roleManager.AddClaimAsync(superAdminRole, new Claim("books:create", "true"));
        await roleManager.AddClaimAsync(superAdminRole, new Claim("books:update", "true"));
        await roleManager.AddClaimAsync(superAdminRole, new Claim("books:delete", "true"));
    }

    var adminRole = await roleManager.FindByNameAsync("Admin");
    if (adminRole != null)
    {
        await roleManager.AddClaimAsync(adminRole, new Claim("users:create", "true"));
        await roleManager.AddClaimAsync(adminRole, new Claim("users:update", "true"));
        await roleManager.AddClaimAsync(adminRole, new Claim("users:delete", "true"));
        await roleManager.AddClaimAsync(adminRole, new Claim("books:create", "true"));
        await roleManager.AddClaimAsync(adminRole, new Claim("books:update", "true"));
        await roleManager.AddClaimAsync(adminRole, new Claim("books:delete", "true"));
    }

    var userRole = await roleManager.FindByNameAsync("User");
    if (userRole != null)
    {
        await roleManager.AddClaimAsync(userRole, new Claim("users:read", "true"));
        await roleManager.AddClaimAsync(userRole, new Claim("books:read", "true"));
    }
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthentication();
app.UseAuthorization();

app.UseHttpsRedirection();

// Add routes
UserEndpoints.AddRoutes(app);

app.UseHttpsRedirection();

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
{
    var forecast =  Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast");

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
