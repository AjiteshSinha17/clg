# Notification System Setup Guide

## What Was Fixed

### 1. **Added Community Chat Notifications**
- The Cloud Function now triggers for **both**:
  - Personal chats: `chats/{chatId}/messages/{messageId}`
  - Community chat: `community_rooms/{roomId}/messages/{messageId}`

### 2. **Fixed Notification Initialization**
- Notifications now initialize **after user logs in** (in `AuthProvider`)
- FCM token is saved to `users/{uid}.fcmTokens` when user authenticates

### 3. **Background Notification Support**
- Added background message handler for when app is closed/backgrounded

---

## What You Need to Do

### Step 1: Install Flutter Dependencies
```bash
flutter pub get
```

### Step 2: Deploy Cloud Functions (REQUIRED)

**First time setup:**
```bash
cd functions
npm install
npm run build
cd ..
firebase deploy --only functions
```

**After making changes:**
```bash
cd functions
npm run build
cd ..
firebase deploy --only functions
```

### Step 3: Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

### Step 4: Test on Your Phone

1. **Install the app on your phone** (not web)
2. **Login** → FCM token should be saved automatically
3. **Send a message from web** in community chat
4. **Check your phone** → Should receive push notification

---

## How to Verify It's Working

### Check FCM Token is Saved:
1. Go to Firebase Console → Firestore
2. Open `users/{your-uid}` document
3. Look for `fcmTokens` field → Should contain an array with your token

### Check Cloud Functions are Deployed:
1. Go to Firebase Console → Functions
2. You should see: `onChatMessageCreated` and `onCommunityMessageCreated`
3. Status should be "Active"

### Test Flow:
1. User A (web) sends message in community chat
2. User B (phone) should receive:
   - **Push notification** (system notification)
   - **In-app notification** (visible in Notifications screen)

---

## Troubleshooting

### Not receiving notifications?

1. **Check FCM token exists:**
   - Firestore → `users/{uid}` → `fcmTokens` should have values

2. **Check Functions are deployed:**
   - Firebase Console → Functions → Should show 2 functions active

3. **Check Functions logs:**
   - Firebase Console → Functions → Click function → View logs
   - Look for errors when message is sent

4. **Verify notification permissions:**
   - Android: Settings → Apps → ClgJone → Notifications (should be enabled)
   - The app requests permission on first launch

5. **Test with personal chat first:**
   - Send a personal message (1:1 chat)
   - If that works, community chat should work too

---

## Important Notes

- **Web app won't receive push notifications** (FCM doesn't work well on web)
- **Notifications only work on mobile** (Android/iOS)
- **Community chat sends notifications to ALL users** (you might want to filter this later)
- **Functions must be deployed** for notifications to work

---

## Next Steps (Optional Improvements)

1. **Filter community notifications** - Only notify active users or subscribers
2. **Add notification preferences** - Let users choose what notifications they want
3. **Deep linking** - Tap notification → Opens the specific chat
4. **Notification badges** - Show unread count on app icon
