# Render + OneSignal + Resend setup (ClgJone)

This project uses a **Render web service** (in `server/`) to send notifications and emails without Firebase Cloud Functions.

## 1) Create OneSignal app

- Create a OneSignal app for your Android package name.
- Copy:
  - **OneSignal App ID**
  - **REST API Key**

## 2) Add OneSignal App ID to Flutter

Edit `lib/main.dart` and replace:

- `PASTE_YOUR_ONESIGNAL_APP_ID_HERE`

Then run:

```bash
flutter pub get
```

After login, the app saves the device id to Firestore:
- `users/{uid}.oneSignalId`

## 3) Create Firebase service account (for Render server)

Firebase Console → Project Settings → Service accounts → Generate new private key.

Copy the full JSON and set it on Render as a secret env var:
- `FIREBASE_SERVICE_ACCOUNT_JSON` = the entire JSON string

## 4) Deploy to Render

### Using `render.yaml` (recommended)
- Push repo to GitHub
- In Render: **New → Blueprint** → select the repo
- It will deploy `clgjone-notify-server` from `server/`

### Required environment variables (Render)
- `FIREBASE_SERVICE_ACCOUNT_JSON`
- `ONESIGNAL_APP_ID`
- `ONESIGNAL_REST_API_KEY`

### Optional (emails via Resend)
- `RESEND_API_KEY`
- `RESEND_FROM` (example: `ClgJone <no-reply@yourdomain.com>`)

## 5) Keep the Render service awake (free plan)

On Render free plan, the web service may sleep. When sleeping, Firestore listeners won’t run and pushes won’t send.

Fix: ping this endpoint every 5 minutes:
- `GET /healthz`

Use UptimeRobot or any cron pinger.

## 6) What gets notified

### Personal chat
Triggered when a new message is created in:
- `chats/{chatId}/messages/{messageId}`

Sent only if recipient has:
- `users/{uid}.notificationPreferences.personalChatEnabled == true`

### Community chat
Triggered when a new message is created in:
- `community_rooms/{roomId}/messages/{messageId}`

Sent only if user has:
- `users/{uid}.notificationPreferences.communityChatEnabled == true`

### Roommate connection requests
Triggered when a new request is created in:
- `connection_requests/{requestId}` with `status == 'pending'`

Sent only if recipient has:
- `users/{uid}.notificationPreferences.roommateRequestEnabled == true`

## 7) Verify server works

After deploy:
- open `https://<your-render-domain>/status`

You should see:
- `firebase: true`
- `oneSignalConfigured: true`
- `resendConfigured: true/false` (depending on whether you set Resend vars)

