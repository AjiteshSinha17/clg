import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import axios from 'axios';
import * as admin from 'firebase-admin';
import { Resend } from 'resend';

dotenv.config();

type NotificationPreferences = {
  personalChatEnabled?: boolean;
  communityChatEnabled?: boolean;
  roommateRequestEnabled?: boolean;
};

type UserDoc = {
  name?: string;
  oneSignalId?: string;
  notificationPreferences?: NotificationPreferences;
};

type MessageDoc = {
  senderId?: string;
  senderName?: string;
  content?: string;
  type?: string; // text | image | pdf
};

type ChatDoc = {
  participants?: string[];
};

type ConnectionRequestDoc = {
  fromUserId?: string;
  toUserId?: string;
  status?: string; // pending | accepted | rejected
};

const ONESIGNAL_APP_ID = process.env.ONESIGNAL_APP_ID ?? '';
const ONESIGNAL_REST_API_KEY = process.env.ONESIGNAL_REST_API_KEY ?? '';
const RESEND_API_KEY = process.env.RESEND_API_KEY ?? '';
const RESEND_FROM = process.env.RESEND_FROM ?? 'no-reply@example.com';

function requireEnv(name: string) {
  if (!process.env[name]) {
    console.warn(`[WARN] Missing env var: ${name}`);
  }
}

requireEnv('FIREBASE_SERVICE_ACCOUNT_JSON');
requireEnv('ONESIGNAL_APP_ID');
requireEnv('ONESIGNAL_REST_API_KEY');

function initFirebaseAdmin() {
  const saJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (!saJson) throw new Error('Missing FIREBASE_SERVICE_ACCOUNT_JSON');
  const serviceAccount = JSON.parse(saJson);

  if (admin.apps.length === 0) {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
  }
}

function base64Url(input: string) {
  return Buffer.from(input).toString('base64url');
}

async function createMarkerOnce(markerId: string, payload: Record<string, unknown>) {
  const ref = admin.firestore().collection('notification_markers').doc(markerId);
  await admin.firestore().runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (snap.exists) return;
    tx.set(ref, {
      ...payload,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
}

async function markerExists(markerId: string): Promise<boolean> {
  const snap = await admin.firestore().collection('notification_markers').doc(markerId).get();
  return snap.exists;
}

async function shouldNotify(uid: string, key: keyof NotificationPreferences): Promise<boolean> {
  const snap = await admin.firestore().collection('users').doc(uid).get();
  const data = (snap.data() as UserDoc | undefined) ?? {};
  const prefs = data.notificationPreferences ?? {};
  // default true
  return (prefs[key] as boolean | undefined) !== false;
}

async function getUser(uid: string): Promise<UserDoc | null> {
  const snap = await admin.firestore().collection('users').doc(uid).get();
  if (!snap.exists) return null;
  return (snap.data() as UserDoc | undefined) ?? null;
}

async function sendOneSignalToPlayer(oneSignalId: string, title: string, body: string, data: Record<string, string>) {
  if (!ONESIGNAL_APP_ID || !ONESIGNAL_REST_API_KEY) return;
  if (!oneSignalId) return;

  await axios.post(
    'https://onesignal.com/api/v1/notifications',
    {
      app_id: ONESIGNAL_APP_ID,
      include_player_ids: [oneSignalId],
      headings: { en: title },
      contents: { en: body },
      data,
      android_priority: 10,
    },
    {
      headers: {
        Authorization: `Basic ${ONESIGNAL_REST_API_KEY}`,
        'Content-Type': 'application/json',
      },
      timeout: 15000,
    },
  );
}

async function sendWelcomeEmail(toEmail: string, name: string) {
  if (!RESEND_API_KEY) return;
  const resend = new Resend(RESEND_API_KEY);
  await resend.emails.send({
    from: RESEND_FROM,
    to: [toEmail],
    subject: 'Welcome to ClgJone',
    html: `<p>Hi ${name},</p><p>Welcome to <b>ClgJone</b>!</p>`,
  });
}

async function sendPasswordResetEmailResend(email: string, resetLink: string) {
  if (!RESEND_API_KEY) return;
  const resend = new Resend(RESEND_API_KEY);
  await resend.emails.send({
    from: RESEND_FROM,
    to: [email],
    subject: 'Reset your ClgJone password',
    html: `<p>You requested a password reset for <b>ClgJone</b>.</p>
           <p><a href="${resetLink}">Click here to reset your password</a></p>
           <p>If you did not request this, you can safely ignore this email.</p>`,
  });
}

async function sendAccountActivityEmail(email: string, title: string, body: string) {
  if (!RESEND_API_KEY) return;
  const resend = new Resend(RESEND_API_KEY);
  await resend.emails.send({
    from: RESEND_FROM,
    to: [email],
    subject: title,
    html: `<p>${body}</p>`,
  });
}

async function notifyPersonalChat(messageRefPath: string, chatId: string, msg: MessageDoc, createdAtMs: number) {
  const senderId = msg.senderId ?? '';
  if (!senderId) return;
  const type = msg.type ?? 'text';
  const senderName = msg.senderName ?? 'New message';
  const body =
    type === 'image' ? 'Sent an image' : type === 'pdf' ? 'Sent a PDF' : (msg.content ?? '').toString();
  if (!body) return;

  const chatSnap = await admin.firestore().collection('chats').doc(chatId).get();
  const chat = (chatSnap.data() as ChatDoc | undefined) ?? {};
  const participants = chat.participants ?? [];
  const recipients = participants.filter((u) => u && u !== senderId);
  if (recipients.length === 0) return;

  await Promise.all(
    recipients.map(async (uid) => {
      const ok = await shouldNotify(uid, 'personalChatEnabled');
      if (!ok) return;

      const u = await getUser(uid);
      const oneSignalId = u?.oneSignalId ?? '';
      if (!oneSignalId) return;

      await sendOneSignalToPlayer(oneSignalId, senderName, body, {
        type: 'chat_message',
        chatId,
        fromUserId: senderId,
      });

      await admin.firestore().collection('users').doc(uid).collection('notifications').add({
        type: 'chat_message',
        title: senderName,
        body,
        chatId,
        fromUserId: senderId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        read: false,
        source: 'render',
        messageRefPath,
        messageCreatedAtMs: createdAtMs,
      });
    }),
  );
}

async function notifyCommunity(roomId: string, msg: MessageDoc, createdAtMs: number, messageRefPath: string) {
  const senderId = msg.senderId ?? '';
  if (!senderId) return;
  const type = msg.type ?? 'text';
  const senderName = msg.senderName ?? 'Community';
  const title = `${senderName} (Community)`;
  const body =
    type === 'image' ? 'Shared an image' : type === 'pdf' ? 'Shared a PDF' : (msg.content ?? '').toString();
  if (!body) return;

  // For small apps: fan-out by reading all users and filtering preferences.
  const usersSnap = await admin.firestore().collection('users').get();
  await Promise.all(
    usersSnap.docs.map(async (doc) => {
      const uid = doc.id;
      if (uid === senderId) return;
      const data = (doc.data() as UserDoc | undefined) ?? {};
      const prefs = data.notificationPreferences ?? {};
      if (prefs.communityChatEnabled === false) return;
      const oneSignalId = data.oneSignalId ?? '';
      if (!oneSignalId) return;

      await sendOneSignalToPlayer(oneSignalId, title, body, {
        type: 'community_message',
        roomId,
        fromUserId: senderId,
      });

      await admin.firestore().collection('users').doc(uid).collection('notifications').add({
        type: 'community_message',
        title,
        body,
        roomId,
        fromUserId: senderId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        read: false,
        source: 'render',
        messageRefPath,
        messageCreatedAtMs: createdAtMs,
      });
    }),
  );
}

async function notifyConnectionRequest(reqId: string, req: ConnectionRequestDoc, createdAtMs: number) {
  const toUserId = req.toUserId ?? '';
  const fromUserId = req.fromUserId ?? '';
  if (!toUserId || !fromUserId) return;
  if ((req.status ?? 'pending') !== 'pending') return;

  const ok = await shouldNotify(toUserId, 'roommateRequestEnabled');
  if (!ok) return;

  const from = await getUser(fromUserId);
  const fromName = from?.name ?? 'Someone';

  const to = await getUser(toUserId);
  const oneSignalId = to?.oneSignalId ?? '';
  if (!oneSignalId) return;

  const title = 'New connection request';
  const body = `${fromName} wants to connect with you`;

  await sendOneSignalToPlayer(oneSignalId, title, body, {
    type: 'connection_request',
    requestId: reqId,
    fromUserId,
  });

  await admin.firestore().collection('users').doc(toUserId).collection('notifications').add({
    type: 'connection_request',
    title,
    body,
    requestId: reqId,
    fromUserId,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    read: false,
    source: 'render',
    requestCreatedAtMs: createdAtMs,
  });
}

function startFirestoreListeners() {
  const db = admin.firestore();
  const bootMs = Date.now();

  // Messages (personal + community)
  db.collectionGroup('messages').onSnapshot(async (snap) => {
    const changes = snap.docChanges().filter((c) => c.type === 'added');
    for (const change of changes) {
      const doc = change.doc;
      const createTimeMs = doc.createTime?.toMillis?.() ?? 0;
      // Avoid notifying for existing docs on cold start
      if (createTimeMs && createTimeMs < bootMs - 5000) continue;

      const path = doc.ref.path; // e.g. chats/{chatId}/messages/{id} OR community_rooms/{roomId}/messages/{id}
      const markerId = base64Url(`msg:${path}`);
      if (await markerExists(markerId)) continue;

      const data = doc.data() as MessageDoc;
      if (path.startsWith('chats/')) {
        const parts = path.split('/');
        const chatId = parts[1];
        await createMarkerOnce(markerId, { kind: 'personal_message', path });
        await notifyPersonalChat(path, chatId, data, createTimeMs);
      } else if (path.startsWith('community_rooms/')) {
        const parts = path.split('/');
        const roomId = parts[1];
        await createMarkerOnce(markerId, { kind: 'community_message', path });
        await notifyCommunity(roomId, data, createTimeMs, path);
      }
    }
  });

  // Connection requests
  db.collection('connection_requests')
    .where('status', '==', 'pending')
    .onSnapshot(async (snap) => {
      const changes = snap.docChanges().filter((c) => c.type === 'added');
      for (const change of changes) {
        const doc = change.doc;
        const createTimeMs = doc.createTime?.toMillis?.() ?? 0;
        if (createTimeMs && createTimeMs < bootMs - 5000) continue;
        const path = doc.ref.path;
        const markerId = base64Url(`req:${path}`);
        if (await markerExists(markerId)) continue;
        await createMarkerOnce(markerId, { kind: 'connection_request', path });
        await notifyConnectionRequest(doc.id, doc.data() as ConnectionRequestDoc, createTimeMs);
      }
    });

  // Welcome email (new user doc)
  db.collection('users').onSnapshot(async (snap) => {
    const changes = snap.docChanges().filter((c) => c.type === 'added');
    for (const change of changes) {
      const doc = change.doc;
      const createTimeMs = doc.createTime?.toMillis?.() ?? 0;
      if (createTimeMs && createTimeMs < bootMs - 5000) continue;

      const path = doc.ref.path;
      const markerId = base64Url(`user:${path}`);
      if (await markerExists(markerId)) continue;

      const data = doc.data() as Record<string, unknown>;
      const email = (data['email'] as string | undefined) ?? '';
      const name = (data['name'] as string | undefined) ?? 'User';
      if (!email) continue;

      await createMarkerOnce(markerId, { kind: 'welcome_email', path });
      await sendWelcomeEmail(email, name);
    }
  });
}

async function main() {
  initFirebaseAdmin();

  const app = express();
  app.use(cors());
  app.use(express.json({ limit: '1mb' }));

  app.get('/', (_req, res) =>
    res.json({ service: 'clgjone-notify', status: 'ok', endpoints: ['/healthz', '/status'] })
  );
  app.get('/healthz', (_req, res) => res.json({ ok: true }));

  // Optional debug: validate env connectivity (do NOT expose secrets)
  app.get('/status', (_req, res) => {
    res.json({
      firebase: admin.apps.length > 0,
      oneSignalConfigured: Boolean(ONESIGNAL_APP_ID && ONESIGNAL_REST_API_KEY),
      resendConfigured: Boolean(RESEND_API_KEY),
    });
  });

  // Password reset email via Resend (alternative to Firebase built-in email)
  // Expects: { email: string }
  app.post('/email/password-reset', async (req, res) => {
    try {
      const { email } = req.body as { email?: string };
      if (!email) return res.status(400).json({ error: 'email is required' });

      const link = await admin.auth().generatePasswordResetLink(email);
      await sendPasswordResetEmailResend(email, link);
      res.json({ ok: true });
    } catch (e) {
      console.error('password-reset error', e);
      res.status(500).json({ error: 'failed to send reset email' });
    }
  });

  // Important account activity email (requires Firebase ID token in Authorization header)
  // Expects: { title: string, body: string }
  app.post('/email/account-activity', async (req, res) => {
    try {
      const authHeader = req.header('authorization') ?? req.header('Authorization');
      if (!authHeader?.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'missing bearer token' });
      }
      const idToken = authHeader.substring('Bearer '.length);
      const decoded = await admin.auth().verifyIdToken(idToken);

      const uid = decoded.uid;
      const userRecord = await admin.auth().getUser(uid);
      const email = userRecord.email;
      if (!email) return res.status(400).json({ error: 'user has no email' });

      const { title, body } = req.body as { title?: string; body?: string };
      if (!title || !body) {
        return res.status(400).json({ error: 'title and body are required' });
      }

      await sendAccountActivityEmail(email, title, body);
      res.json({ ok: true });
    } catch (e) {
      console.error('account-activity error', e);
      res.status(500).json({ error: 'failed to send activity email' });
    }
  });

  const port = Number(process.env.PORT ?? 3000);
  app.listen(port, () => {
    console.log(`Notify server listening on :${port}`);
  });

  // Start listeners after server is up
  startFirestoreListeners();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});