# Book Management Concepts

This file contains the book management system concepts that were removed from the main application but preserved for future reference.

## Models

### Book Model
```csharp
public class Book
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public int Year { get; set; }
    public Author Author { get; set; } = new();
}
```

### Author Model
```csharp
public class Author
{
    public string UserId { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
}
```

### Update Book Request
```csharp
public record UpdateBookRequest(string Title, int Year);
```

## Repository Pattern

### IBookRepository Interface
```csharp
public interface IBookRepository
{
    Task<Book?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    Task UpdateAsync(Book book, CancellationToken cancellationToken);
}
```

### BookRepository Implementation
```csharp
public class BookRepository : IBookRepository
{
    private readonly List<Book> _books = new();

    public Task<Book?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
    {
        return Task.FromResult(_books.FirstOrDefault(b => b.Id == id));
    }

    public Task UpdateAsync(Book book, CancellationToken cancellationToken)
    {
        // For demo, assume update succeeds
        return Task.CompletedTask;
    }
}
```

## Authorization

### Book Author Requirement
```csharp
public class BookAuthorRequirement : IAuthorizationRequirement
{
}
```

### Book Author Handler
```csharp
public class BookAuthorHandler : AuthorizationHandler<BookAuthorRequirement, Author>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        BookAuthorRequirement requirement,
        Author resource)
    {
        var userId = context.User.FindFirst("userid")?.Value;
        if (userId is not null && userId == resource.UserId)
        {
            context.Succeed(requirement);
        }

        return Task.CompletedTask;
    }
}
```

## API Endpoints

### Book Endpoints
```csharp
public static class BookEndpoints
{
    public static void AddRoutes(this IEndpointRouteBuilder app)
    {
        app.MapPut("/api/books/{id}", Handle)
            .RequireAuthorization("books:update");
    }

    private static async Task<IResult> Handle(
        [FromRoute] Guid id,
        [FromBody] UpdateBookRequest request,
        IBookRepository repository,
        IAuthorizationService authService,
        ClaimsPrincipal user,
        CancellationToken cancellationToken)
    {
        var book = await repository.GetByIdAsync(id, cancellationToken);
        if (book is null)
        {
            return Results.NotFound($"Book with id {id} not found");
        }

        var requirement = new BookAuthorRequirement();

        var authResult = await authService.AuthorizeAsync(user, book.Author, requirement);
        if (!authResult.Succeeded)
        {
            return Results.Forbid();
        }

        book.Title = request.Title;
        book.Year = request.Year;

        await repository.UpdateAsync(book, cancellationToken);

        return Results.NoContent();
    }
}
```

## Authorization Policies

### Book-related policies that were configured:
- `books:create` - Policy for creating books
- `books:update` - Policy for updating books  
- `books:delete` - Policy for deleting books
- `books:read` - Policy for reading books

### Role Claims that were assigned:
- **SuperAdmin**: All book permissions (create, update, delete)
- **Admin**: All book permissions (create, update, delete)
- **User**: Read-only book permissions

## Service Registration

The following services were registered for book functionality:
```csharp
builder.Services.AddScoped<IBookRepository, BookRepository>();
builder.Services.AddScoped<IAuthorizationHandler, BookAuthorHandler>();
```

## Key Concepts Demonstrated

1. **Repository Pattern**: Clean separation between data access and business logic
2. **Authorization Requirements**: Custom authorization logic for resource-based access control
3. **Minimal API Endpoints**: Using ASP.NET Core minimal APIs for REST endpoints
4. **Policy-based Authorization**: Using claims-based policies for fine-grained permissions
5. **Role-based Access Control**: Different permission levels for different user roles

## Future Implementation Notes

If you want to re-implement book functionality:
1. Add the models back to `Models/` folder
2. Register the repository and authorization handler in `Program.cs`
3. Add the authorization policies back
4. Create the endpoint class and register the routes
5. Consider adding Entity Framework models for database persistence