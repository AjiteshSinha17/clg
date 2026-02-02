# Notification Preferences Setup

## What Was Added

### 1. **Notification Preferences Service**
- Created `lib/services/notification_preferences_service.dart`
- Manages user notification settings (personal chat & community chat)
- Stores preferences in Firestore: `users/{uid}.notificationPreferences`
- Provides real-time stream of preferences

### 2. **Settings Screen Updates**
- Added "Notifications" section to Settings screen
- Two toggle switches:
  - **Personal Chat Notifications** - Control notifications for 1:1 messages
  - **Community Chat Notifications** - Control notifications for community chat messages
- Real-time updates using StreamBuilder

### 3. **Cloud Functions Updates**
- Updated `functions/src/index.ts` to check user preferences before sending notifications
- Added helper functions:
  - `shouldNotifyPersonalChat()` - Checks if user wants personal chat notifications
  - `shouldNotifyCommunityChat()` - Checks if user wants community chat notifications
- Both functions default to `true` if preferences not set (backward compatible)

### 4. **Firestore Rules**
- Already allows users to update their own document (includes `notificationPreferences`)
- Added clarifying comment in rules

---

## How It Works

### User Flow:
1. User opens **Settings** screen
2. Sees "Notifications" section with two toggles
3. Toggles preferences on/off
4. Preferences saved to Firestore immediately
5. Cloud Functions check preferences before sending notifications

### Technical Flow:
```
User toggles setting
  ↓
NotificationPreferencesService.setPreferences()
  ↓
Firestore: users/{uid}.notificationPreferences = { personalChatEnabled: true/false, communityChatEnabled: true/false }
  ↓
Cloud Function receives new message
  ↓
Checks shouldNotifyPersonalChat() or shouldNotifyCommunityChat()
  ↓
If enabled → Send notification
If disabled → Skip notification
```

---

## Default Behavior

- **New users**: Both notifications enabled by default
- **Existing users**: Both notifications enabled (preferences created on first access)
- **If preferences missing**: Defaults to enabled (backward compatible)

---

## Testing

### Test Personal Chat Notifications:
1. Go to Settings → Toggle "Personal Chat Notifications" OFF
2. Have someone send you a personal message
3. You should NOT receive notification
4. Toggle back ON → Should receive notifications again

### Test Community Chat Notifications:
1. Go to Settings → Toggle "Community Chat Notifications" OFF
2. Have someone send a message in community chat
3. You should NOT receive notification
4. Toggle back ON → Should receive notifications again

---

## Firestore Structure

```javascript
users/{userId} {
  notificationPreferences: {
    personalChatEnabled: true,    // Default: true
    communityChatEnabled: true    // Default: true
  },
  // ... other user fields
}
```

---

## Deployment Steps

### 1. Deploy Cloud Functions (REQUIRED)
```bash
cd functions
npm install
npm run build
cd ..
firebase deploy --only functions
```

### 2. Deploy Firestore Rules (if needed)
```bash
firebase deploy --only firestore:rules
```

### 3. Test in App
- Open Settings
- Toggle notification preferences
- Test with actual messages

---

## Notes

- Preferences are stored per-user in Firestore
- Changes take effect immediately (no app restart needed)
- Cloud Functions check preferences on every message
- In-app notifications and push notifications both respect preferences
- Preferences sync across all user devices (same Firestore document)
