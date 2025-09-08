# SkiniorX - Flutter App with GetX

A modern Flutter application implementing GetX state management with Apple-style design, dark/light theme configuration, and authentication flow.

## Features Implemented

### ✅ GetX State Management

- Latest GetX version (4.6.6) installed and configured
- Reactive state management for authentication and theme
- GetStorage for persistent data storage

### ✅ Dark/Light Theme Configuration

- Beautiful Apple-style themes for both light and dark modes
- Automatic theme persistence using GetStorage
- Theme toggle button in app bar
- iOS-inspired color schemes and design patterns

### ✅ Authentication Flow

- Automatic navigation to login page if user is not authenticated
- Splash screen with app branding
- Login and signup functionality with form validation
- Persistent authentication state

### ✅ Apple-Style Login Page

- Clean, modern design inspired by Apple's design language
- Tabbed interface with Login and Sign Up tabs
- Beautiful form fields with proper validation
- Loading states and user feedback
- Smooth animations and transitions

## Project Structure

```
lib/
├── app/
│   ├── controllers/
│   │   ├── auth_controller.dart     # Authentication logic
│   │   └── theme_controller.dart    # Theme management
│   ├── models/                      # Data models (expandable)
│   ├── routes/
│   │   ├── app_routes.dart         # Route constants
│   │   └── app_pages.dart          # Route configuration
│   ├── themes/
│   │   └── app_themes.dart         # Light and dark themes
│   ├── views/
│   │   ├── splash_view.dart        # Splash screen
│   │   ├── login_view.dart         # Login/Signup page
│   │   └── home_view.dart          # Main home screen
│   └── services/                   # Services (expandable)
└── main.dart                       # App entry point
```

## Key Components

### ThemeController

- Manages light/dark theme switching
- Persists user theme preference
- Reactive theme updates across the app

### AuthController

- Handles login and signup functionality
- Manages authentication state
- Persistent login sessions
- Simple validation for demo purposes

### Apple-Style Design Elements

- iOS blue color scheme (#007AFF for light, #0A84FF for dark)
- Rounded corners and clean typography
- Card-based layouts with proper spacing
- Native iOS-style input fields and buttons

## Usage

### Running the App

```bash
flutter pub get
flutter run
```

### Default Credentials

For demo purposes, any email with a password of 6+ characters will work for both login and signup.

### Theme Switching

- Use the theme toggle button in the app bar
- Theme preference is automatically saved and restored

### Navigation Flow

1. **Splash Screen** → Shows app logo and checks authentication
2. **Login Page** → If not authenticated, shows login/signup tabs
3. **Home Page** → If authenticated, shows main app interface

## Dependencies

- `get: ^4.6.6` - State management and navigation
- `get_storage: ^2.1.1` - Local storage for preferences
- `cupertino_icons: ^1.0.8` - iOS-style icons

## Future Enhancements

- Real authentication backend integration
- Profile management
- Advanced skin care features
- Push notifications
- Social login options
