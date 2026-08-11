---
name: mobile-developer
description: Use this skill when building React Native or Flutter apps with native integrations. For cross-platform UI, offline-first sync, push notifications, and App Store deployment workflows.
---

# Mobile Developer

Cross-platform mobile development expertise for React Native and Flutter applications.

## Overview

This skill guides you through building **production-grade mobile apps** that work seamlessly on both iOS and Android. It covers:

- **React Native / Flutter** component architecture
- **Native module integration** for device-specific features
- **Offline-first design** for unreliable network conditions
- **Push notifications & deep linking** for user engagement
- **App Store submission** with compliance checks

## 📋 Quick Start: New Mobile Project

```markdown
- [ ] Choose framework: React Native (Expo or bare) / Flutter
- [ ] Set up project structure with feature-based organization
- [ ] Configure native modules for required device APIs
- [ ] Implement navigation with type-safe routing
- [ ] Design offline-first data layer
- [ ] Set up push notification handlers (APNs + FCM)
- [ ] Configure deep linking / Universal Links
- [ ] Prepare release build and signing
- [ ] Test on both iOS and Android devices
```

## 📋 Quick Start: Feature Checklist

```markdown
- [ ] Create feature module: `src/features/{feature-name}/`
- [ ] Define types in `types/` subdirectory
- [ ] Create API service in `api/`
- [ ] Build UI components in `components/`
- [ ] Add custom hooks in `hooks/`
- [ ] Export public API from `index.ts`
- [ ] Handle platform-specific code with `.ios.ts` / `.android.ts`
```

---

## 🚫 Critical Rules

### Platform-Specific Code

```typescript
// ✅ Use Platform.select for simple cases
const styles = {
  shadow: Platform.select({
    ios: { shadowColor: '#000', shadowOffset: { width: 0, height: 2 } },
    android: { elevation: 4 },
  }),
};

// ✅ Use .ios.ts / .android.ts for complex logic
// Button.ios.ts
// Button.android.ts
import { Button } from './Button'; // Auto-resolves
```

### Offline-First Pattern

```typescript
// ✅ GOOD: Cache-first, sync in background
const data = await localDB.get(key);
syncManager.scheduleSync(); // Non-blocking

// ❌ BAD: Network-first causes poor UX offline
const data = await fetch(url); // Hangs if offline
```

### Push Notification Registration

```typescript
// ✅ Always handle both platforms
async function registerForPush() {
  if (Platform.OS === 'ios') {
    await messaging().requestPermission();
  }
  const token = await messaging().getToken();
  await sendTokenToServer(token);
}
```

---

## 📂 Topic Guides

### React Native Architecture
- Expo vs Bare workflow selection
- Navigation with React Navigation v6+
- State management (Zustand / Redux Toolkit)
- **[📖 Full Guide: references/react-native-guide.md](references/react-native-guide.md)**

### Flutter Architecture
- Widget composition patterns
- BLoC / Riverpod state management
- Platform channels for native code
- **[📖 Full Guide: references/flutter-guide.md](references/flutter-guide.md)**

### Native Module Integration
- Camera, sensors, biometrics
- Background tasks and services
- File system access
- **[📖 Full Guide: references/native-modules.md](references/native-modules.md)**

### Offline-First Design
- Local database (SQLite, Realm, Hive)
- Sync strategies and conflict resolution
- Network status monitoring
- **[📖 Full Guide: references/offline-first.md](references/offline-first.md)**

### Push Notifications
- APNs (iOS) configuration
- FCM (Android) configuration
- Rich notifications with images/actions
- **[📖 Full Guide: references/push-notifications.md](references/push-notifications.md)**

### App Store Deployment
- iOS: Certificates, provisioning profiles
- Android: Keystore, signing config
- CI/CD with Fastlane / EAS Build
- **[📖 Full Guide: references/app-store-deployment.md](references/app-store-deployment.md)**

---

## Protocols

### 1. Analyze Requirements
- Identify target platforms (iOS only, Android only, or both)
- List required native device features
- Determine offline requirements
- Plan notification strategy

### 2. Set Up Project Structure
- Initialize React Native (Expo/bare) or Flutter project
- Configure TypeScript / Dart strict mode
- Set up linting and formatting
- Create feature-based directory structure

### 3. Implement Core Features
- Build reusable UI components
- Implement navigation flow
- Add data fetching with proper caching
- Handle platform-specific differences

### 4. Add Native Integrations
- Configure required permissions (Info.plist / AndroidManifest)
- Integrate native modules or create bridges
- Test thoroughly on physical devices

### 5. Prepare for Release
- Generate app icons and splash screens
- Configure code signing
- Set up CI/CD pipeline
- Create App Store / Play Store listings

---

## 📚 Usage Examples

**User**: "Create a photo gallery app with offline viewing"
**Action**: Set up image caching, local SQLite for metadata, background sync for new photos

**User**: "Add push notifications to my React Native app"
**Action**: Configure FCM, set up APNs certificates, implement foreground/background handlers

**User**: "Integrate fingerprint authentication"
**Action**: Add react-native-biometrics or local_auth (Flutter), configure secure storage

**User**: "Prepare my app for App Store submission"
**Action**: Review guidelines, set up signing, create screenshots, write description

---

## 📊 Performance Optimization

| Area | React Native | Flutter |
|------|--------------|---------|
| List Rendering | Use `FlatList` with `getItemLayout` | Use `ListView.builder` |
| Image Loading | `FastImage` library | `cached_network_image` |
| Bundle Size | Enable Hermes, ProGuard | Use `--split-debug-info` |
| Startup Time | Lazy load features | Deferred components |
| Memory | Avoid large state trees | Use `const` constructors |

---

## 🛡️ Security Checklist

```markdown
- [ ] Store sensitive data in Keychain/Keystore, not AsyncStorage/SharedPrefs
- [ ] Enable certificate pinning for API calls
- [ ] Implement biometric authentication for sensitive actions
- [ ] Obfuscate release builds (ProGuard/R8 for Android)
- [ ] Never log sensitive information
- [ ] Validate all deep link parameters
```
