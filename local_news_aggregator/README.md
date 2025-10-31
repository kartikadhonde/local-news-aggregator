# Local News Aggregator

A simplified Flutter mobile news app with Firebase authentication, cloud storage, and user feedback system.

## 🎯 Platforms Supported

- **Android** ✅
- **iOS** ✅

## Quick Start

### 1. Set up Firebase

Follow the detailed instructions in [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

Key steps:

- Create a Firebase project
- Enable Email/Password authentication
- Set up Cloud Firestore with security rules
- Run `flutterfire configure` in this directory
- Run `flutter pub get`

### 2. Run the app

```bash
flutter run
```

## Features

### 🔐 Authentication & User Management

- ✅ **User Registration** - Create account with email/password (Firebase Auth)
- ✅ **User Login** - Secure sign-in with Firebase Authentication
- ✅ **Profile Management** - User profiles stored in Cloud Firestore
- ✅ **Profile Updates** - Edit profile and sync changes to Firebase in real-time
- ✅ **Persistent Sessions** - Auto-login with Firebase auth state
- ✅ **Secure Logout** - Sign out from Firebase Auth

### 📰 News Features

- 📰 Local news based on city/state/country filters
- 🌍 Global news headlines
- 🔍 Filter news by location
- 📌 Save default location preferences in Firebase

### 💬 Feedback System

- ✅ **User Feedback** - Submit feedback directly from profile screen
- ✅ **Firebase Storage** - Feedback stored in Cloud Firestore `feedback` collection
- ✅ **Admin Review** - Admins can view, resolve, and manage all user feedback
- ✅ **Real-time Updates** - Feedback appears instantly in admin dashboard

### 🛡️ Admin Features

- 🔒 **Admin Login** - Secure admin access (email: `admin@mail.com`)
- 📊 **Admin Dashboard** - Separate interface for admin tasks
- 📝 **Feedback Management** - Review and respond to user feedback
- 🚫 **Content Moderation** - Remove inappropriate news articles

## Architecture

### Simplified Project Structure

```
local_news_aggregator/
├── android/               # Android platform files
├── ios/                   # iOS platform files
├── lib/
│   ├── models/
│   │   ├── news.dart           # News article model
│   │   └── user.dart           # User model
│   ├── screens/
│   │   ├── admin_main_screen.dart
│   │   ├── admin_review_feedback_screen.dart
│   │   ├── edit_profile_screen.dart
│   │   ├── feedback_screen.dart
│   │   ├── global_tab.dart
│   │   ├── local_tab.dart
│   │   ├── login_screen.dart
│   │   ├── main_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── register_screen.dart
│   │   └── welcome_screen.dart
│   ├── services/
│   │   ├── auth_service.dart   # Firebase Auth integration
│   │   └── news_service.dart   # NewsAPI integration
│   ├── widgets/
│   │   └── news_card.dart      # Reusable news card widget
│   ├── api_key.dart            # NewsAPI key
│   ├── firebase_options.dart   # Firebase config
│   └── main.dart               # App entry point
├── .gitignore
├── pubspec.yaml
├── README.md
└── FIREBASE_SETUP.md
```

### Authentication Flow

1. **Registration**: User registers → Firebase Auth creates account → Firestore document created
2. **Login**: User logs in → Firebase Auth validates → Firestore profile loaded
3. **Profile Update**: User updates profile → Firestore document updated in real-time
4. **Logout**: User logs out → Firebase Auth signs out → Local state cleared

### Feedback Flow

1. **User**: Profile Screen → Send Feedback → Submit to Firebase
2. **Storage**: Feedback saved to `feedback` collection with user info and timestamp
3. **Admin**: Admin Dashboard → Feedback Tab → View/Resolve/Delete feedback

### Data Structure

**Firestore Collection: `users`**

```javascript
users/{userId} {
  id: string
  email: string
  name: string
  isAdmin: boolean
  bio: string?
  location: string?
  profileImageUrl: string?
  defaultCity: string?
  defaultState: string?
  defaultCountry: string?
  defaultCountryCode: string?
}
```

**Firestore Collection: `feedback`**

```javascript
feedback/{feedbackId} {
  message: string
  userId: string
  userEmail: string
  createdAt: timestamp
  status: string  // 'new' or 'resolved'
}
```

**Firestore Collection: `removed_articles`**

```javascript
removed_articles/{articleId} {
  url: string
  reason: string?
  removedAt: timestamp
  removedBy: string  // admin userId
}
```

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User documents
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Feedback collection
    match /feedback/{feedbackId} {
      allow create: if request.auth != null;  // Any user can submit
      allow read, update, delete: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;  // Admin only
    }

    // Removed articles (admin only)
    match /removed_articles/{articleId} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
  }
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

## Testing the Feedback System

### As a User:

1. Register/Login as a regular user
2. Go to **Profile** tab
3. Tap **"Send Feedback"**
4. Enter your feedback message
5. Tap **"Send"**

### As an Admin:

1. Login with admin credentials:
   - Email: `admin@mail.com`
   - Password: `admin`
2. Admin Dashboard opens automatically
3. Navigate to **"Feedback"** tab
4. View all submitted feedback
5. Mark as resolved or delete

### Verify in Firebase Console:

1. Go to Firebase Console → Firestore Database
2. Check `feedback` collection
3. See real-time feedback documents

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.5.0 # NewsAPI requests
  provider: ^6.1.0 # State management
  url_launcher: ^6.2.0 # Open articles in browser
  firebase_core: ^3.6.0 # Firebase core
  firebase_auth: ^5.3.1 # Firebase Authentication
  cloud_firestore: ^5.4.4 # Cloud Firestore database
```

## Support

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for troubleshooting and detailed setup instructions.
