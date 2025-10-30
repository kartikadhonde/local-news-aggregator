# Local News Aggregator - Firebase Integration

A Flutter news app with Firebase authentication and cloud storage for user profiles.

## Quick Start

### 1. Set up Firebase
Follow the detailed instructions in [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

Key steps:
- Create a Firebase project
- Enable Email/Password authentication  
- Set up Cloud Firestore
- Run `flutterfire configure` in this directory
- Run `flutter pub get`

### 2. Run the app
```bash
flutter run
```

## Features

### Firebase-Powered Features
- ✅ **User Registration** - Create account with email/password stored securely in Firebase Auth
- ✅ **User Login** - Sign in with Firebase Authentication
- ✅ **Profile Management** - User profiles stored in Cloud Firestore
- ✅ **Profile Updates** - Edit profile and sync changes to Firebase in real-time
- ✅ **Persistent Sessions** - Auto-login with Firebase auth state
- ✅ **Secure Logout** - Sign out from Firebase Auth

### News Features
- 📰 Local news based on location filters
- 🌍 Global news headlines
- 🔍 Search and filter by city, state, country
- 📌 Save default location preferences in Firebase

## Architecture

### Authentication Flow
1. User registers → Firebase Auth creates account → Firestore document created
2. User logs in → Firebase Auth validates → Firestore profile loaded
3. User updates profile → Firestore document updated in real-time
4. User logs out → Firebase Auth signs out → Local state cleared

### Data Structure

**Firestore Collection: `users`**
```javascript
users/{userId} {
  id: string
  email: string
  name: string
  bio: string?
  location: string?
  profileImageUrl: string?
  defaultCity: string?
  defaultState: string?
  defaultCountry: string?
  defaultCountryCode: string?
}
```

### Security
- Firebase Auth handles password hashing and security
- Firestore rules ensure users can only access their own data
- No passwords stored in Firestore
- Auth tokens managed by Firebase SDK

## Configuration Files

After running `flutterfire configure`, you'll have:
- `lib/firebase_options.dart` - Auto-generated Firebase config
- `android/app/google-services.json` - Android config (don't commit)
- `ios/Runner/GoogleService-Info.plist` - iOS config (don't commit)

## Support

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for troubleshooting and detailed setup instructions.
