import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

export const sendPokeNotification = functions.https.onCall(async (request) => {
  // 1. Get Data
  const targetToken = request.data.targetToken;
  const senderName = request.data.senderName;
  const targetName = request.data.targetName;

  // 2. Validate
  if (!targetToken) {
    throw new functions.https.HttpsError('invalid-argument', 'Target token missing.');
  }

  // 3. Payload
  const message = {
    token: targetToken,
    notification: {
      title: `HeartCare: ${senderName}`,
      body: `Hey ${targetName}, take care of your health! ❤️`,
    },
    android: {
      priority: "high" as const,
      notification: { channelId: "poke_channel_id" },
    },
  };

  // 4. Send
  try {
    await admin.messaging().send(message);
    return { success: true };
  } catch (error) {
    console.error("FCM Error:", error);
    throw new functions.https.HttpsError('internal', 'Failed to send.');
  }
});