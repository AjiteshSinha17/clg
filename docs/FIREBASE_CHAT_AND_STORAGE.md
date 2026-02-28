# Firebase Storage Error & Connect/Chat Implementation

## 1. "No object exists at the desired reference" (Firebase Storage)

### Why it occurs
- **After `putData()`**: You call `ref.getDownloadURL()` but the upload failed (e.g. permission denied, wrong bucket, network), so no object exists at that reference.
- **Wrong reference**: Using a different ref or bucket than the one you wrote to.
- **Wrong bucket**: App’s `storageBucket` in `firebase_options.dart` doesn’t match the project’s Storage bucket in Firebase Console.

### Possible causes
| Cause | What to check |
|-------|----------------|
| Incorrect path | Empty or invalid `userId`, `chatId`, or `roomId` in path. |
| Missing file | Upload failed; only `getDownloadURL()` was assumed to work. |
| Wrong user ID | Passing wrong or null `uid` into storage path. |
| Security rules | Storage rules block write/read for that path. |
| Bucket mismatch | `storageBucket` in app ≠ bucket in Firebase Console. |

### What we changed in code
- **Path sanitization**: All path segments (e.g. `userId`, `chatId`, `roomId`, file names) are sanitized so they’re non-empty and safe for Storage paths.
- **Single ref, clear errors**: Upload uses one `ref` for both `putData()` and `getDownloadURL()`. Errors are caught and rethrown with a clear message (including Firebase plugin/code).
- **FirebaseException**: Storage errors are caught so you see the real Firebase error (e.g. permission-denied, object-not-found) for debugging.

### Debugging steps
1. **Check bucket**: Firebase Console → Project Settings → General → Your app → `storageBucket`. Must match `lib/firebase_options.dart` → `storageBucket`.
2. **Regenerate config**: Run `flutterfire configure` and rebuild.
3. **Storage rules**: In Console → Storage → Rules, ensure authenticated users can write/read the paths you use (e.g. `profile_images/`, `chat_media/`).
4. **Log the ref**: Before `putData`, log `ref.fullPath`. If it’s wrong or empty, fix the IDs you pass in.

---

## 2. Firestore structure (connections + chat)

### User profiles
- **Collection**: `users`
- **Document ID**: `uid` (Firebase Auth UID)
- **Fields**: name, email, avatarUrl, bio, college, branch, year, roommate prefs, etc. (as in your `User` model).

### Connection requests
- **Collection**: `connection_requests`
- **Fields**: `fromUserId`, `toUserId`, `status` (`pending` | `accepted` | `rejected`), `createdAt`, `updatedAt`.
- **Index**: Composite index on `toUserId` (Ascending), `status` (Ascending), `createdAt` (Descending) for the “pending requests to me” query. Create in Firebase Console when prompted, or add to `firestore.indexes.json` and deploy.

### Accepted connections
- Derived from `connection_requests` where `status == 'accepted'`.
- No separate collection; chat is created on accept.

### Chat rooms (1:1)
- **Collection**: `chats`
- **Document fields**: `participants` (array of 2 UIDs), `lastMessage`, `lastMessageTime`, `unreadCounts` (map UID → number).
- **Subcollection**: `messages` — each message has `senderId`, `senderName`, `content`, `timestamp`, `type` (text/image/pdf), `fileUrl`, `fileName` when media.

### Chat media (download links)
- **Collection**: `chat_media` (personal) / `community_media` (community)
- **Fields**: `chatId` or `roomId`, `senderId`, `senderName`, `fileUrl`, `fileName`, `type`, `timestamp`.

---

## 3. Connect & Chat flow (Flutter + Firebase)

### Send connection request
```dart
await connectionService.sendRequest(otherUserId);
```
- Writes a document to `connection_requests` with `status: 'pending'`.

### Accept / Reject
```dart
// Accept: update request + create chat, then navigate
final chatId = await connectionService.acceptRequest(requestId);
context.push('/chat/$chatId', extra: otherUser);

// Reject
await connectionService.rejectRequest(requestId);
```

### Create chat after accept
- `ConnectionService.acceptRequest()` updates the request to `accepted` and calls `ChatService.createChat(fromUserId)` so the two users share one chat document. `createChat` is idempotent (returns existing chat if already present).

### Send / receive messages (real-time)
- **Send**: `ChatService.sendMessage(chatId, content)` or `sendMediaMessage(chatId, type, fileUrl, fileName: ...)`.
- **Receive**: `ChatService.getMessagesStream(chatId)` — listen to `chats/{chatId}/messages` ordered by `timestamp`.

---

## 4. Best practices

- **Security rules**: In Firestore, allow read/write for `chats` and `messages` only if the user’s UID is in `participants`. For `connection_requests`, allow create if authenticated; allow update only for the `toUserId` (for accept/reject).
- **Storage rules**: Restrict `profile_images/`, `chat_media/` (and similar) to authenticated users; optionally restrict paths by `userId`/`chatId` to avoid cross-user writes.
- **Scalability**: For very large message lists, use pagination (e.g. `limit(50)` and `startAfterDocument`) instead of loading the whole subcollection.
- **FCM**: Store FCM tokens in `users/{uid}` and use Cloud Functions (or your backend) to send notifications when a new message or connection request is created, so push works when the app is in the background or killed.
