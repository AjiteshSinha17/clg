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

### Resend (emails) – required for welcome, password reset, account activity

1. **Create Resend account**: https://resend.com → Sign up (free tier: 100 emails/day)
2. **Get API key**: Resend Dashboard → API Keys → Create API Key → copy the key (starts with `re_`)
3. **Verify domain** (for production):
   - Resend Dashboard → Domains → Add domain
   - Add the DNS records they provide (MX, TXT, etc.)
   - Until verified, you can only send to your own email (for testing)
4. **Add to Render** (Dashboard → your service → Environment):
   - `RESEND_API_KEY` = your API key (e.g. `re_xxxxxxxx`) — set as **Secret**
   - `RESEND_FROM` = sender address, e.g. `ClgJone <onboarding@resend.dev>` (Resend’s test domain) or `ClgJone <no-reply@yourdomain.com>` (after domain verification)

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

