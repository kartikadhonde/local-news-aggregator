# 📝 Feedback System Setup Guide

## ✅ What Was Fixed

The feedback system has been updated with:

1. **Better error handling** - Shows actual error messages
2. **Improved admin interface** - Beautiful UI with expandable cards
3. **Date formatting** - Proper timestamp display
4. **User validation** - Checks if user is logged in before submitting
5. **Firestore security rules** - Proper permissions for feedback

---

## 🔥 CRITICAL: Update Firestore Security Rules

### Step 1: Go to Firebase Console

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Firestore Database** (left sidebar)
4. Click on the **Rules** tab at the top

### Step 2: Replace Rules

**DELETE** all existing rules and **PASTE** the following:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function to check if user is admin
    function isAdmin() {
      return request.auth != null &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }

    // User documents - users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Feedback collection
    // - Any authenticated user can CREATE feedback
    // - Only admins can READ, UPDATE, and DELETE feedback
    match /feedback/{feedbackId} {
      // Allow any authenticated user to submit feedback
      allow create: if request.auth != null;

      // Only admins can read all feedback
      allow read: if isAdmin();

      // Only admins can update feedback (e.g., mark as resolved)
      allow update: if isAdmin();

      // Only admins can delete feedback
      allow delete: if isAdmin();
    }

    // Removed articles - admins can moderate content
    match /removed_articles/{articleId} {
      allow read: if request.auth != null;
      allow write: if isAdmin();
    }
  }
}
```

### Step 3: Publish Rules

Click the **"Publish"** button at the top right.

⚠️ **IMPORTANT**: Without these rules, feedback submission will fail with "permission denied" error!

---

## 👤 Create Admin Account

### Method 1: In the App (Recommended)

1. **Register** a new account in the app:

   - Email: `admin@mail.com` (or any email you want)
   - Password: `admin` (or any password you want)
   - Name: `Admin`

2. **Go to Firebase Console**:

   - Navigate to **Firestore Database** → **Data** tab
   - Find the `users` collection
   - Click on your newly created user document

3. **Add admin field**:

   - Click **"Add field"**
   - Field name: `isAdmin`
   - Type: **boolean**
   - Value: **true** ✅
   - Click **"Update"**

4. **Restart the app** and login again - you'll see the Admin Dashboard!

### Method 2: Using Firebase Console Directly

1. Go to **Firestore Database** → **Data**
2. Click on `users` collection (create it if it doesn't exist)
3. Click **"Add document"**
4. Document ID: (auto-generate or use your Firebase Auth UID)
5. Add fields:
   ```
   email: "admin@mail.com"
   name: "Admin"
   isAdmin: true (boolean)
   id: "<same as document ID>"
   ```

---

## 🧪 Testing the Feedback System

### As a Regular User:

1. **Login** as a regular user (not admin)
2. Go to **Profile** tab
3. Tap **"Send Feedback"**
4. Enter message: "Test feedback from user"
5. Tap **"Send"**
6. Should see success message: "Feedback sent successfully. Thank you!" ✅

### As an Admin:

1. **Login** with admin credentials
2. Admin Dashboard opens automatically
3. Navigate to **"Feedback"** tab
4. You should see:
   - All submitted feedback
   - User details (name, email, timestamp)
   - Status (NEW or RESOLVED)
   - Options to mark as resolved or delete

### If Feedback Submission Fails:

Check the error message shown in the app. Common issues:

1. **"Permission denied"**

   - ✅ Solution: Update Firestore security rules (see above)

2. **"You must be logged in to send feedback"**

   - ✅ Solution: Make sure you're logged in

3. **"Failed to send feedback: [some error]"**
   - ✅ Check your internet connection
   - ✅ Verify Firebase project is set up correctly
   - ✅ Check Firebase Console → Firestore Database is enabled

---

## 📊 Verify in Firebase Console

1. Go to **Firestore Database** → **Data** tab
2. You should see these collections:

   - ✅ `users` - User profiles
   - ✅ `feedback` - User feedback submissions
   - ✅ `removed_articles` - Admin-removed articles (if any)

3. Click on `feedback` collection to see submitted feedback documents

---

## 🎨 Admin Features

The admin can:

- ✅ **View all feedback** in an expandable card interface
- ✅ **See user details** (name, email, timestamp)
- ✅ **Mark as resolved** - Changes status from NEW to RESOLVED
- ✅ **Mark as new** - Changes status from RESOLVED back to NEW
- ✅ **Delete feedback** - Permanently removes feedback
- ✅ **Real-time updates** - New feedback appears instantly

---

## 🔍 Troubleshooting

### Feedback Not Appearing in Admin Dashboard

1. **Check Firestore rules** - Must allow admin to read feedback
2. **Verify admin account** - User document must have `isAdmin: true`
3. **Check collection name** - Must be exactly `feedback`
4. **Look for errors** - Check debug console for error messages

### "Permission Denied" Error

```
✅ Update Firestore security rules (see Step 2 above)
✅ Make sure rules are published
✅ Wait a few seconds for rules to propagate
```

### Admin Dashboard Not Showing

```
✅ Verify isAdmin field is set to true (boolean, not string)
✅ Logout and login again
✅ Check that email matches exactly
```

### Timestamp Shows "Just now" or "Unknown date"

```
✅ This is normal for newly created feedback
✅ Wait a few seconds for Firebase to set server timestamp
✅ Refresh the admin screen
```

---

## 📱 App Flow

### User Flow:

```
Login/Register
  ↓
Profile Screen
  ↓
Tap "Send Feedback"
  ↓
Feedback Screen
  ↓
Enter message → Submit
  ↓
Success! ✅
```

### Admin Flow:

```
Login as Admin
  ↓
Admin Dashboard (automatic)
  ↓
Feedback Tab
  ↓
View all feedback
  ↓
Mark as resolved / Delete
```

---

## 🚀 Next Steps

1. ✅ Update Firestore security rules
2. ✅ Create admin account with `isAdmin: true`
3. ✅ Test feedback submission as regular user
4. ✅ Test feedback review as admin
5. ✅ Deploy your app!

---

## 📚 Additional Resources

- [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Cloud Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firebase Console](https://console.firebase.google.com/)

---

**Need Help?** Check the error messages in the app - they now show detailed information about what went wrong!
