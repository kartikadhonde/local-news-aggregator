# Authentication & Profile Features

## New Features Added

### 1. **Welcome/Landing Page** (`welcome_screen.dart`)
- Beautiful gradient header with app branding
- Shows top 5 world news headlines
- Login and Register buttons
- Accessible without authentication

### 2. **Login Page** (`login_screen.dart`)
- Email and password authentication
- Form validation
- Password visibility toggle
- Navigation to registration page
- Loading state during authentication

### 3. **Registration Page** (`register_screen.dart`)
- User registration with name, email, and password
- Password confirmation validation
- Form validation for all fields
- Automatic login after successful registration

### 4. **Profile Page** (`profile_screen.dart`)
- Displays user information (name, email, location, bio)
- Profile picture support (URL-based)
- Edit profile button
- Settings and help sections (placeholders)
- Logout functionality with confirmation dialog

### 5. **Edit Profile Page** (`edit_profile_screen.dart`)
- Edit name, location, and bio
- Profile image URL input
- Real-time preview of changes
- Form validation
- Save changes to persistent storage

### 6. **Main Screen** (`main_screen.dart`)
- Bottom navigation bar
- Two tabs: News and Profile
- News tab shows Local and Global news
- Profile tab shows user profile

## File Structure

```
lib/
├── models/
│   ├── news.dart
│   └── user.dart              # NEW: User model
├── screens/
│   ├── edit_profile_screen.dart   # NEW: Edit profile
│   ├── global_tab.dart
│   ├── home_screen.dart       # OLD: Replaced by main_screen.dart
│   ├── local_tab.dart
│   ├── login_screen.dart      # NEW: Login page
│   ├── main_screen.dart       # NEW: Main app screen with navigation
│   ├── profile_screen.dart    # NEW: User profile
│   ├── register_screen.dart   # NEW: Registration page
│   └── welcome_screen.dart    # NEW: Landing page
├── services/
│   ├── auth_service.dart      # NEW: Authentication service
│   ├── location_service.dart
│   └── news_service.dart
├── widgets/
│   └── news_card.dart
├── api_key.dart
└── main.dart                  # UPDATED: Added Provider & Auth
```

## How It Works

### Authentication Flow
1. App starts → Check if user is logged in
2. If not logged in → Show Welcome Screen
3. User can browse top news or Login/Register
4. After login/registration → Navigate to Main Screen
5. Main Screen has News and Profile tabs

### Data Storage
- Uses `SharedPreferences` for local data persistence
- User credentials stored locally (for demo purposes)
- Profile data persists across app restarts

### State Management
- Uses `Provider` package for state management
- `AuthService` manages authentication state
- Real-time UI updates when user data changes

## Features

✅ User Registration
✅ User Login
✅ Logout with confirmation
✅ Profile viewing
✅ Profile editing
✅ Profile picture (URL-based)
✅ Persistent storage
✅ Form validation
✅ Loading states
✅ Error handling
✅ Bottom navigation
✅ Guest browsing (top news on welcome page)

## Usage

### To Test:
1. Run the app
2. You'll see the Welcome Screen with top news
3. Click "Register" to create an account
4. Fill in the form and submit
5. You'll be automatically logged in
6. Explore the News tab (Local/Global)
7. Go to Profile tab to see your profile
8. Click edit icon to modify your profile
9. Logout from the profile page

### Test Credentials:
Since this is a demo app, you can register any user. Data is stored locally in SharedPreferences.

## Security Note

⚠️ **This is a demo implementation**: Passwords are stored in plain text in SharedPreferences. In a production app, you should:
- Use proper backend authentication (Firebase, Auth0, custom API)
- Hash passwords
- Use secure token-based authentication
- Implement proper session management
