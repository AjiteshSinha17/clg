# clgjone-notify-server (Render)

Backend service to send:
- **OneSignal push notifications** for:
  - personal chat messages (`chats/{chatId}/messages/{messageId}`)
  - community chat messages (`community_rooms/{roomId}/messages/{messageId}`)
  - roommate/connection requests (`connection_requests/{requestId}`)
- **Resend welcome emails** when a new `users/{uid}` doc is created

This replaces Firebase Cloud Functions (Blaze not required).

## Render deploy

1. Push this repo to GitHub.
2. In Render, create a **Web Service** from the repo (or use `render.yaml`).
3. Set **Root Directory** = `server`.
4. Set environment variables (Secrets):

### Required
- `FIREBASE_SERVICE_ACCOUNT_JSON`: service account JSON string (full JSON).
- `ONESIGNAL_APP_ID`
- `ONESIGNAL_REST_API_KEY`

### Optional (emails)
- `RESEND_API_KEY`
- `RESEND_FROM` (example: `ClgJone <no-reply@yourdomain.com>`)

## Firestore fields used

In `users/{uid}`:
- `oneSignalId`: OneSignal player/subscription id from the Flutter app
- `notificationPreferences`:
  - `personalChatEnabled` (default true)
  - `communityChatEnabled` (default true)
  - `roommateRequestEnabled` (default true)

## Keeping Render awake (important)

If you are on a free plan and the service sleeps, listeners won’t run while sleeping.
To keep it awake, ping `GET /healthz` every 5 minutes (e.g. UptimeRobot).
