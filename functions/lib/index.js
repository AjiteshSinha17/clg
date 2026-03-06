"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onConnectionRequestCreated = exports.onCommunityMessageCreated = exports.onChatMessageCreated = exports.cloudinarySignUpload = void 0;
const admin = require("firebase-admin");
const firestore_1 = require("firebase-functions/v2/firestore");
const https_1 = require("firebase-functions/v2/https");
const params_1 = require("firebase-functions/params");
const crypto = require("crypto");
admin.initializeApp();
const CLOUDINARY_CLOUD_NAME = (0, params_1.defineSecret)('CLOUDINARY_CLOUD_NAME');
const CLOUDINARY_API_KEY = (0, params_1.defineSecret)('CLOUDINARY_API_KEY');
const CLOUDINARY_API_SECRET = (0, params_1.defineSecret)('CLOUDINARY_API_SECRET');
function assertAllowedFolder(folder) {
    // Keep this tight: only allow folders your app uses.
    const allowedPrefixes = [
        'chat_media/',
        'community_content/',
        'profile_images/',
        'college_ids/',
        'profile_banners/',
    ];
    if (!allowedPrefixes.some((p) => folder.startsWith(p))) {
        throw new https_1.HttpsError('permission-denied', 'Folder not allowed');
    }
}
exports.cloudinarySignUpload = (0, https_1.onCall)({
    secrets: [CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET],
}, async (req) => {
    if (!req.auth?.uid) {
        throw new https_1.HttpsError('unauthenticated', 'Sign-in required');
    }
    const data = (req.data ?? {});
    const folder = (data.folder ?? '');
    const publicId = (data.publicId ?? '');
    const timestamp = Number(data.timestamp);
    const resourceType = (data.resourceType ?? '');
    if (!folder || !publicId || !Number.isFinite(timestamp) || timestamp <= 0) {
        throw new https_1.HttpsError('invalid-argument', 'Missing folder/publicId/timestamp');
    }
    if (resourceType !== 'image' && resourceType !== 'raw') {
        throw new https_1.HttpsError('invalid-argument', 'Invalid resourceType');
    }
    assertAllowedFolder(folder);
    const cloudName = CLOUDINARY_CLOUD_NAME.value();
    const apiKey = CLOUDINARY_API_KEY.value();
    const apiSecret = CLOUDINARY_API_SECRET.value();
    if (!cloudName || !apiKey || !apiSecret) {
        throw new https_1.HttpsError('failed-precondition', 'Cloudinary secrets not configured');
    }
    // Cloudinary signature: sha1(sorted_params + api_secret)
    // We sign only the params we actually send from the client.
    const toSign = `folder=${folder}&public_id=${publicId}&timestamp=${timestamp}`;
    const signature = crypto
        .createHash('sha1')
        .update(toSign + apiSecret)
        .digest('hex');
    return {
        cloudName,
        apiKey,
        signature,
        timestamp,
    };
});
// Helper function to check if user wants notifications for personal chat
async function shouldNotifyPersonalChat(uid) {
    const userSnap = await admin.firestore().collection('users').doc(uid).get();
    if (!userSnap.exists)
        return true; // Default: enabled
    const data = userSnap.data();
    const prefs = data?.notificationPreferences;
    // Default to true if preferences not set
    return prefs?.personalChatEnabled !== false;
}
// Helper function to check if user wants notifications for community chat
async function shouldNotifyCommunityChat(uid) {
    const userSnap = await admin.firestore().collection('users').doc(uid).get();
    if (!userSnap.exists)
        return true; // Default: enabled
    const data = userSnap.data();
    const prefs = data?.notificationPreferences;
    return prefs?.communityChatEnabled !== false;
}
// Helper function to check if user wants notifications for roommate/connection requests
async function shouldNotifyRoommateRequest(uid) {
    const userSnap = await admin.firestore().collection('users').doc(uid).get();
    if (!userSnap.exists)
        return true; // Default: enabled
    const data = userSnap.data();
    const prefs = data?.notificationPreferences;
    return prefs?.roommateRequestEnabled !== false;
}
// Personal chat messages trigger
exports.onChatMessageCreated = (0, firestore_1.onDocumentCreated)('chats/{chatId}/messages/{messageId}', async (event) => {
    const chatId = event.params.chatId;
    const message = event.data?.data();
    if (!message)
        return;
    const senderId = message.senderId ?? '';
    const body = (message.content ?? '').toString();
    if (!senderId || !body)
        return;
    const chatSnap = await admin.firestore().collection('chats').doc(chatId).get();
    const chat = chatSnap.data() ?? {};
    const participants = chat.participants ?? [];
    const recipients = participants.filter((uid) => uid && uid !== senderId);
    if (recipients.length === 0)
        return;
    const senderName = message.senderName ?? 'New message';
    await Promise.all(recipients.map(async (uid) => {
        // Check if user has personal chat notifications enabled
        const shouldNotify = await shouldNotifyPersonalChat(uid);
        if (!shouldNotify)
            return; // Skip if disabled
        // 1) Write in-app notification
        await admin
            .firestore()
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .add({
            type: 'chat_message',
            title: senderName,
            body,
            chatId,
            fromUserId: senderId,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            read: false,
        });
        // 2) Send FCM push
        const userSnap = await admin.firestore().collection('users').doc(uid).get();
        const data = userSnap.data();
        const tokens = (data?.fcmTokens ?? []).filter(Boolean);
        if (tokens.length === 0)
            return;
        await admin.messaging().sendEachForMulticast({
            tokens,
            notification: {
                title: senderName,
                body,
            },
            data: {
                type: 'chat_message',
                chatId,
                fromUserId: senderId,
            },
            android: {
                priority: 'high',
            },
        });
    }));
});
// Community chat messages trigger
exports.onCommunityMessageCreated = (0, firestore_1.onDocumentCreated)('community_rooms/{roomId}/messages/{messageId}', async (event) => {
    const roomId = event.params.roomId;
    const message = event.data?.data();
    if (!message)
        return;
    const senderId = message.senderId ?? '';
    const body = (message.content ?? '').toString();
    if (!senderId || !body)
        return;
    const senderName = message.senderName ?? 'Community';
    const notificationTitle = `${senderName} (Community)`;
    // For community chat, notify all users who have the app installed
    // (In production, you might want to filter by active users or subscribers)
    const usersSnapshot = await admin.firestore().collection('users').get();
    await Promise.all(usersSnapshot.docs.map(async (userDoc) => {
        const uid = userDoc.id;
        // Don't notify the sender
        if (uid === senderId)
            return;
        // Check if user has community chat notifications enabled
        const shouldNotify = await shouldNotifyCommunityChat(uid);
        if (!shouldNotify)
            return; // Skip if disabled
        // 1) Write in-app notification
        await admin
            .firestore()
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .add({
            type: 'community_message',
            title: notificationTitle,
            body,
            roomId,
            fromUserId: senderId,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            read: false,
        });
        // 2) Send FCM push
        const data = userDoc.data();
        const tokens = (data?.fcmTokens ?? []).filter(Boolean);
        if (tokens.length === 0)
            return;
        await admin.messaging().sendEachForMulticast({
            tokens,
            notification: {
                title: notificationTitle,
                body,
            },
            data: {
                type: 'community_message',
                roomId,
                fromUserId: senderId,
            },
            android: {
                priority: 'high',
            },
        });
    }));
});
exports.onConnectionRequestCreated = (0, firestore_1.onDocumentCreated)('connection_requests/{requestId}', async (event) => {
    const request = event.data?.data();
    if (!request)
        return;
    const fromUserId = request.fromUserId ?? '';
    const toUserId = request.toUserId ?? '';
    const status = request.status ?? 'pending';
    if (!fromUserId || !toUserId || status !== 'pending')
        return;
    const shouldNotify = await shouldNotifyRoommateRequest(toUserId);
    if (!shouldNotify)
        return;
    const fromUserSnap = await admin.firestore().collection('users').doc(fromUserId).get();
    const fromName = fromUserSnap.data()?.name ?? 'Someone';
    await admin
        .firestore()
        .collection('users')
        .doc(toUserId)
        .collection('notifications')
        .add({
        type: 'connection_request',
        title: 'New connection request',
        body: `${fromName} wants to connect with you`,
        fromUserId,
        requestId: event.params.requestId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        read: false,
    });
    const toUserSnap = await admin.firestore().collection('users').doc(toUserId).get();
    const toData = toUserSnap.data();
    const tokens = (toData?.fcmTokens ?? []).filter(Boolean);
    if (tokens.length === 0)
        return;
    await admin.messaging().sendEachForMulticast({
        tokens,
        notification: {
            title: 'New connection request',
            body: `${fromName} wants to connect with you`,
        },
        data: {
            type: 'connection_request',
            fromUserId,
            requestId: event.params.requestId,
        },
        android: {
            priority: 'high',
        },
    });
});
//# sourceMappingURL=index.js.map