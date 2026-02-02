import * as admin from 'firebase-admin';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';

admin.initializeApp();

type ChatDoc = {
  participants?: string[];
};

type MessageDoc = {
  senderId?: string;
  senderName?: string;
  senderAvatarUrl?: string;
  content?: string;
  timestamp?: admin.firestore.Timestamp;
};

type NotificationPreferences = {
  personalChatEnabled?: boolean;
  communityChatEnabled?: boolean;
};

type UserDoc = {
  fcmTokens?: string[];
  notificationPreferences?: NotificationPreferences;
};

// Helper function to check if user wants notifications for personal chat
async function shouldNotifyPersonalChat(uid: string): Promise<boolean> {
  const userSnap = await admin.firestore().collection('users').doc(uid).get();
  if (!userSnap.exists) return true; // Default: enabled

  const data = userSnap.data() as UserDoc | undefined;
  const prefs = data?.notificationPreferences;
  
  // Default to true if preferences not set
  return prefs?.personalChatEnabled !== false;
}

// Helper function to check if user wants notifications for community chat
async function shouldNotifyCommunityChat(uid: string): Promise<boolean> {
  const userSnap = await admin.firestore().collection('users').doc(uid).get();
  if (!userSnap.exists) return true; // Default: enabled

  const data = userSnap.data() as UserDoc | undefined;
  const prefs = data?.notificationPreferences;
  
  // Default to true if preferences not set
  return prefs?.communityChatEnabled !== false;
}

// Personal chat messages trigger
export const onChatMessageCreated = onDocumentCreated(
  'chats/{chatId}/messages/{messageId}',
  async (event) => {
    const chatId = event.params.chatId as string;
    const message = event.data?.data() as MessageDoc | undefined;
    if (!message) return;

    const senderId = message.senderId ?? '';
    const body = (message.content ?? '').toString();
    if (!senderId || !body) return;

    const chatSnap = await admin.firestore().collection('chats').doc(chatId).get();
    const chat = (chatSnap.data() as ChatDoc | undefined) ?? {};
    const participants = chat.participants ?? [];
    const recipients = participants.filter((uid) => uid && uid !== senderId);
    if (recipients.length === 0) return;

    const senderName = message.senderName ?? 'New message';

    await Promise.all(
      recipients.map(async (uid) => {
        // Check if user has personal chat notifications enabled
        const shouldNotify = await shouldNotifyPersonalChat(uid);
        if (!shouldNotify) return; // Skip if disabled

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
        const data = userSnap.data() as UserDoc | undefined;
        const tokens = (data?.fcmTokens ?? []).filter(Boolean);
        if (tokens.length === 0) return;

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
      }),
    );
  },
);

// Community chat messages trigger
export const onCommunityMessageCreated = onDocumentCreated(
  'community_rooms/{roomId}/messages/{messageId}',
  async (event) => {
    const roomId = event.params.roomId as string;
    const message = event.data?.data() as MessageDoc | undefined;
    if (!message) return;

    const senderId = message.senderId ?? '';
    const body = (message.content ?? '').toString();
    if (!senderId || !body) return;

    const senderName = message.senderName ?? 'Community';
    const notificationTitle = `${senderName} (Community)`;

    // For community chat, notify all users who have the app installed
    // (In production, you might want to filter by active users or subscribers)
    const usersSnapshot = await admin.firestore().collection('users').get();
    
    await Promise.all(
      usersSnapshot.docs.map(async (userDoc) => {
        const uid = userDoc.id;
        // Don't notify the sender
        if (uid === senderId) return;

        // Check if user has community chat notifications enabled
        const shouldNotify = await shouldNotifyCommunityChat(uid);
        if (!shouldNotify) return; // Skip if disabled

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
        const data = userDoc.data() as UserDoc | undefined;
        const tokens = (data?.fcmTokens ?? []).filter(Boolean);
        if (tokens.length === 0) return;

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
      }),
    );
  },
);

