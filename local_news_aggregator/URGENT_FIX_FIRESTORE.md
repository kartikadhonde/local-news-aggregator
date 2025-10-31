# 🚨 URGENT: Fix Permission Error NOW

## You are seeing this error:

```
Error: [cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
```

## Why?

The **Firestore security rules** are currently blocking access to the feedback collection.

## Fix in 3 MINUTES ⏱️

### Step 1: Open Firebase Console

1. Go to: **https://console.firebase.google.com/**
2. Click on your project: **localnewsaggregator**

### Step 2: Navigate to Firestore Rules

1. In the left sidebar, click **"Firestore Database"**
2. Click the **"Rules"** tab at the top

### Step 3: Replace ALL Rules

**DELETE EVERYTHING** in the rules editor and paste this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function to check if user is admin
    function isAdmin() {
      return request.auth != null &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }

    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update, delete: if request.auth != null && request.auth.uid == userId;
    }

    // Feedback collection
    match /feedback/{feedbackId} {
      allow create: if request.auth != null;
      allow read, update, delete: if isAdmin();
    }

    // Searches collection
    match /searches/{searchId} {
      allow create: if request.auth != null;
      allow read: if isAdmin();
    }

    // Removed articles collection
    match /removed_articles/{articleId} {
      allow read: if request.auth != null;
      allow write: if isAdmin();
    }
  }
}
```

### Step 4: Publish

1. Click the big green **"Publish"** button at the top
2. Wait 10-30 seconds

### Step 5: Test

1. **Close and restart** your Flutter app completely
2. Try accessing the Feedback tab again
3. ✅ Error should be GONE!

---

## Still Not Working?

### Check #1: Admin Account

Make sure you have an admin account:

1. In Firebase Console → Firestore Database → **Data** tab
2. Click **users** collection
3. Find your admin user
4. Make sure it has a field: `isAdmin: true` (type: boolean)

### Check #2: Restart Everything

1. Stop the Flutter app completely
2. Run: `flutter clean && flutter pub get`
3. Restart the app

### Check #3: Rules Published?

1. Go back to Firebase Console → Firestore → Rules
2. Make sure you see the rules from Step 3 above
3. If not, repeat Step 3 and Step 4

---

## What This Does

✅ **feedback collection**:

- Any logged-in user can CREATE feedback
- Only admins can READ/UPDATE/DELETE feedback

✅ **users collection**:

- Users can read all users
- Users can only modify their own data

✅ **searches collection**:

- Any logged-in user can log searches
- Only admins can view search analytics

✅ **removed_articles collection**:

- Any logged-in user can see removed articles
- Only admins can add/remove from the list

---

## DO THIS NOW! ⏰

The permission error **CANNOT** be fixed from the Flutter code. You **MUST** update the Firestore rules in Firebase Console. It takes literally 2 minutes.

👉 **https://console.firebase.google.com/**
