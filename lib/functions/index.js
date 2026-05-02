const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNewMessageNotification = functions.firestore
  .document("conversations/{convoId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const senderUid = message.sender;
    const receiverUid = message.receiver;
    const text = message.text;

    // Get receiver's FCM token
    const userDoc = await admin.firestore()
      .collection("users")
      .doc(receiverUid)
      .get();

    const token = userDoc.data()?.fcmToken;
    if (!token) return;

    // Get sender name
    const senderDoc = await admin.firestore()
      .collection("users")
      .doc(senderUid)
      .get();

    const senderName = senderDoc.data()?.name || "New Message";

    // Notification payload
    const payload = {
      notification: {
        title: senderName,
        body: text,
      },
      data: {
        convoId: context.params.convoId,
        senderUid: senderUid,
      },
    };

    // Send push notification
    await admin.messaging().sendToDevice(token, payload);
  });
