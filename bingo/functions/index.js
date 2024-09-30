const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Cloud Function to trigger on changes in the "bin_data" collection
exports.sendNotificationOnHighFill = functions.firestore
    .document("bin_data/{binId}")
    .onUpdate(async (change, context) => {
      // Get the new value of the document
      const newValue = change.after.data();
      const fillPercent = newValue.fill_percent;

      // Log the bin ID and fill percentage for debugging
      console.log(`Bin ID: ${context.params.binId}, Fill Percent: ${fillPercent}`);

      // Check if fill_percent exceeds 75
      if (typeof fillPercent === 'number' && fillPercent > 75) {
        console.log(`Bin ${context.params.binId} has exceeded 75% fill. Sending notification...`);

        try {
          // Query Firestore for users with accountType 'worker' and area 1
          const workersSnapshot = await admin.firestore().collection("users")
              .where("accountType", "==", "worker")
              .where("area", "==", 1) // Filter for workers in area 1
              .get();

          // Collect FCM tokens from the workers' documents
          const tokens = [];
          workersSnapshot.forEach((doc) => {
            const userData = doc.data();
            if (userData.fcmToken) { // Ensure the worker has an FCM token
              tokens.push(userData.fcmToken);
            }
          });

          // Log the FCM tokens for debugging
          console.log(`Found ${tokens.length} FCM tokens for workers in area 1`);

          // Send the notification to one random worker in area 1 (if there are any tokens)
          if (tokens.length > 0) {
            // Pick one random token
            const randomIndex = Math.floor(Math.random() * tokens.length);
            const selectedToken = tokens[randomIndex];

            const payload = {
              notification: {
                title: "Bin Fill Alert!",
                body: `Bin ${context.params.binId} is ${fillPercent}% full. Time to empty it!`,
                clickAction: "FLUTTER_NOTIFICATION_CLICK",
              },
            };

            // Send the notification to the selected token
            const response = await admin.messaging().sendToDevice(selectedToken, payload);
            console.log("Successfully sent notification to one worker in area 1:", response);
          } else {
            console.log("No FCM tokens found for workers in area 1.");
          }
        } catch (error) {
          console.error("Error sending notification:", error);
        }
      } else {
        console.log(`Bin ${context.params.binId} is below 75% fill.`);
      }

      return null;
    });
