# Firebase Setup Instructions

## Prerequisites

1. A Google account
2. Flutter SDK installed
3. FlutterFire CLI installed (`dart pub global activate flutterfire_cli`)

## Firebase Project Setup

### 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Enter a project name (e.g., "Local News Aggregator")
4. Follow the setup wizard (Google Analytics is optional)

### 2. Enable Authentication

1. In your Firebase project, navigate to **Build** > **Authentication**
2. Click **Get started**
3. Go to the **Sign-in method** tab
4. Enable **Email/Password** authentication
5. Click **Save**

### 3. Set up Cloud Firestore

1. Navigate to **Build** > **Firestore Database**
2. Click **Create database**
3. Choose **Start in production mode** (or test mode for development)
4. Select a Cloud Firestore location closest to your users
5. Click **Enable**

### 4. Configure Firestore Security Rules

Replace the default rules with the following to enable user authentication, feedback system, and admin features:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User documents - users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Feedback collection - any authenticated user can submit, only admins can manage
    match /feedback/{feedbackId} {
      allow create: if request.auth != null;
      allow read, update, delete: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }

    // Removed articles - admins can moderate content
    match /removed_articles/{articleId} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
  }
}
```

**Important:** Copy these exact rules to your Firebase Console > Firestore Database > Rules tab and click "Publish".

## Flutter App Configuration

### 5. Install FlutterFire CLI (if not already installed)

```bash
dart pub global activate flutterfire_cli
```

**If you get "flutterfire is not recognized" error on Windows:**

The executable isn't on your PATH. Add it using one of these methods:

**Method 1: Add to PATH via System Settings (Recommended)**

1. Press `Win + X` and select "System"
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Under "User variables", select "Path" and click "Edit"
5. Click "New" and add: `C:\Users\YOUR_USERNAME\AppData\Local\Pub\Cache\bin`
   - Replace `YOUR_USERNAME` with your actual Windows username
6. Click "OK" on all dialogs
7. **Restart your terminal** (or VS Code) for changes to take effect

**Method 2: Use Full Path (Quick Fix)**
Instead of `flutterfire configure`, use:

```powershell
& "$env:LOCALAPPDATA\Pub\Cache\bin\flutterfire.bat" configure
```

### 6. Configure Firebase for your Flutter app

Run this command in your project root directory:

```bash
flutterfire configure
```

This will:

- Prompt you to select the Firebase project
- Ask which platforms to configure (select **android** and **ios** only - other platforms removed)
- Generate configuration files automatically

**Note:** This project is optimized for mobile (Android/iOS) only. Desktop and web platforms have been removed for simplicity.

### 7. Install Dependencies

The required Firebase packages are already in `pubspec.yaml`. Install them:

```bash
flutter pub get
```

## Verification

### 8. Create Admin Account

After the app is running, you need to create an admin account manually:

1. Register a new account in the app with email: `admin@mail.com`
2. Go to Firebase Console → Firestore Database
3. Find the user document with email `admin@mail.com` in the `users` collection
4. Click the document and add a new field:
   - Field: `isAdmin`
   - Type: `boolean`
   - Value: `true`
5. Save the document

Now when you login with `admin@mail.com`, you'll see the Admin Dashboard instead of the regular user interface.

### 9. Test the Integration

1. Run the app: `flutter run`
2. Try to register a new account
3. Submit feedback from Profile screen
4. Login as admin to view feedback
5. Check Firebase Console:
   - **Authentication** > **Users** should show your users
   - **Firestore Database** > **Data** should show `users`, `feedback`, and `removed_articles` collections

## Important Notes

### Platform-Specific Setup

#### Android

- The `flutterfire configure` command automatically adds `google-services.json` to `android/app/`
- Make sure your `android/app/build.gradle` has minimum SDK version 21 or higher

#### iOS

- The command adds `GoogleService-Info.plist` to `ios/Runner/`
- Run `cd ios && pod install` if you haven't already

#### Web/Desktop Platforms

- **Not supported** - Web, Windows, Linux, and macOS platforms have been removed from this project for simplicity
- The app is optimized for mobile (Android/iOS) only

### Security Best Practices

1. **Never commit sensitive files to version control:**

   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)
   - Add them to `.gitignore` if sharing code publicly

2. **Update Firestore Rules for production:**

   - The current rules support user authentication, feedback system, and admin features
   - Review and adjust based on your app's requirements
   - Ensure admin users have `isAdmin: true` field in their user documents

3. **Enable App Check (recommended for production):**
   - Protects your backend resources from abuse
   - Configure in Firebase Console > Build > App Check

## Troubleshooting

### Common Issues

**Firebase not initializing:**

- Ensure `Firebase.initializeApp()` is called before `runApp()` in `main.dart`
- Check that `firebase_options.dart` exists and is properly imported

**Authentication errors:**

- Verify Email/Password is enabled in Firebase Console
- Check internet connectivity
- Review error messages in debug console

**Firestore permission denied:**

- Verify security rules allow the operation
- Ensure user is authenticated (`FirebaseAuth.instance.currentUser != null`)
- Check that the document path matches security rule patterns

**Build errors:**

- Run `flutter clean` then `flutter pub get`
- For Android: Check `android/build.gradle` and `android/app/build.gradle` versions
- For iOS: Run `cd ios && pod install --repo-update`

## Migration from Local Storage

The app previously used `shared_preferences` for local storage. This has been replaced with Firebase Cloud Firestore.

**Removed Files & Folders:**

- ❌ `test/` - Placeholder tests
- ❌ `windows/` - Windows platform support
- ❌ `linux/` - Linux platform support
- ❌ `macos/` - macOS platform support
- ❌ `web/` - Web platform support
- ❌ `lib/screens/home_screen.dart` - Replaced by `main_screen.dart`
- ❌ `lib/services/location_service.dart` - Unused location service
- ❌ `FIREBASE_MIGRATION.md` - Migration documentation (no longer needed)
- ❌ `FEATURES.md` - Consolidated into README.md

The app now focuses on **Android and iOS only** for a simpler, more maintainable codebase.

## Additional Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
