# 🔧 Quick Fix: Google Sign-In Error (5 minutes)

## Your SHA Fingerprints

**SHA-1:**
```
EA:50:BF:15:A5:0D:13:41:A4:66:FF:24:7C:C9:B0:1A:7F:C8:F6:E8
```

**SHA-256:**
```
7B:A3:77:4B:C5:49:AC:2B:3D:A7:AB:BE:F5:46:78:1C:BC:C5:56:EC:40:06:F2:97:F0:B2:14:F4:9C:25:66:C6
```

---

## Steps to Fix (Copy & Paste)

### 1. Open Firebase Console
👉 https://console.firebase.google.com/project/clgjone/settings/general

### 2. Add SHA Fingerprints
1. Scroll down to **"Your apps"** section
2. Find your **Android app** (package: `com.example.myapp`)
3. Click **"Add fingerprint"** button
4. Paste **SHA-1** (from above) → Click **"Save"**
5. Click **"Add fingerprint"** again
6. Paste **SHA-256** (from above) → Click **"Save"**

### 3. Enable Google Sign-In
1. Go to: https://console.firebase.google.com/project/clgjone/authentication/providers
2. Click on **"Google"** provider
3. Toggle **"Enable"** → Click **"Save"**

### 4. Download Updated google-services.json
1. Go back to: https://console.firebase.google.com/project/clgjone/settings/general
2. Scroll to **"Your apps"** → Android app
3. Click **"Download google-services.json"**
4. Replace `android/app/google-services.json` in your project

### 5. Rebuild App
```bash
flutter clean
flutter pub get
flutter run
```

---

## ✅ Verification

After completing the steps above:
- Wait 2-3 minutes for Firebase to process
- Try Google Sign-In again
- It should work! 🎉

---

## Still Not Working?

1. **Check google-services.json** - Open `android/app/google-services.json`
   - Look for `"oauth_client"` array
   - It should NOT be empty `[]`
   - Should contain at least one object with `client_id`

2. **Verify package name matches:**
   - `android/app/build.gradle.kts`: `applicationId = "com.example.myapp"`
   - `google-services.json`: `"package_name": "com.example.myapp"`

3. **Clear app data:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## Need Help?

See detailed guide: `GOOGLE_SIGNIN_SETUP.md`
