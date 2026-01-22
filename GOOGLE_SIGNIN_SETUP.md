# Google Sign-In Setup Guide

## Error: `ApiException: 10` (DEVELOPER_ERROR)

This error occurs when Google Sign-In is not properly configured in Firebase Console. Follow these steps:

---

## Step 1: Get Your SHA-1 and SHA-256 Fingerprints

### For Windows (PowerShell):

**Debug Keystore:**
```powershell
cd android
.\gradlew signingReport
```

Look for output like:
```
Variant: debug
Config: debug
Store: C:\Users\YourName\.android\debug.keystore
Alias: AndroidDebugKey
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

**OR use keytool directly:**
```powershell
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

---

## Step 2: Add SHA Fingerprints to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **clgjone**
3. Click the **⚙️ Settings** icon → **Project settings**
4. Scroll down to **Your apps** section
5. Find your **Android app** (package: `com.example.myapp`)
6. Click **Add fingerprint**
7. Paste your **SHA-1** fingerprint → Click **Save**
8. Click **Add fingerprint** again
9. Paste your **SHA-256** fingerprint → Click **Save**

---

## Step 3: Enable Google Sign-In in Firebase Authentication

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Find **Google** in the list
3. Click on it → **Enable** → **Save**

---

## Step 4: Download Updated google-services.json

1. In Firebase Console → **Project settings** → **Your apps**
2. Find your Android app
3. Click **Download google-services.json**
4. Replace `android/app/google-services.json` with the new file

---

## Step 5: Rebuild Your App

```bash
flutter clean
flutter pub get
flutter run
```

---

## Step 6: Verify OAuth Client is Created

After adding SHA fingerprints, Firebase should automatically create an OAuth client.

Check `android/app/google-services.json` - it should now have:
```json
"oauth_client": [
  {
    "client_id": "...",
    "client_type": 1,
    "android_info": {
      "package_name": "com.example.myapp",
      "certificate_hash": "YOUR_SHA1_HERE"
    }
  }
]
```

If it's still empty, wait a few minutes and download the file again.

---

## Troubleshooting

### Still getting error 10?

1. **Verify package name matches:**
   - `android/app/build.gradle.kts`: `applicationId = "com.example.myapp"`
   - `android/app/google-services.json`: `"package_name": "com.example.myapp"`
   - They must match exactly!

2. **Check Firebase Console:**
   - Authentication → Sign-in method → Google should be **Enabled**
   - Project settings → Your apps → Android app should show SHA-1 and SHA-256

3. **Clear app data and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. **For Release builds:**
   - You'll need to add SHA-1/SHA-256 from your **release keystore** too
   - Use the same process but with your release keystore file

---

## Quick Test

After setup, try Google Sign-In again. If it works, you'll see:
- Google account picker
- Permission request
- Successful sign-in

If you still get errors, check the exact error message and verify all steps above.
