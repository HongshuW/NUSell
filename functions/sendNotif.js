var admin = require("firebase-admin");
const functions = require("firebase-functions");

var serviceAccount = require("/Users/liuzhilan/Documents/Development/orbital/learning/orbital2796_nusell/serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});
// var registrationToken = 'dgLTCnRhQoqIIVH_Tu6LD4:APA91bFjqsuTB8sZWmaDPn2QpjUUUoes9DtR5qtayDdcopMU5fPnURFHZgUq0cA2ZBnrKBDtVOB9doSq4CrVP10O9RRokeUFllLLj8GSQduVN8NPrVSv100xU3HIMec2Lz8a_Y4O0KO_';




// var message = {
//     notification: {
//       title: '850',
//       body: '2:45'
//     },
//     //token: registrationToken
//   };
  
//   // Send a message to the device corresponding to the provided
//   // registration token.
//   admin.messaging().sendToDevice(registrationToken, message)
//     .then((response) => {
//       // Response is a message ID string.
//       console.log('Successfully sent message:', response);
//     })
//     .catch((error) => {
//       console.log('Error sending message:', error);
//     });


exports.onMessageSendNotification = functions.firestore
    .document("/chats/{docId}")
    .onUpdate(async (snapshot, context) => {
        console.log('came in');
        const doc = snap.data();
        console.log(doc);
        
        // 1) Get user connected to the feed
        // const userId = context.params.userId;
        // const userRef = admin.firestore().doc(`users/${userId}`);
        // const doc = await userRef.get();
        const idFrom = context.params.userId;
        if (idFrom == doc.users[0]) {
            const idTo = doc.users[1];
        } else {
            const idTo = doc.users[0];
        }
        const contentMessage = doc.history[doc.history.length - 1].message;

        // Get push token user to (receive)
        admin
        .firestore()
        .collection('users')
        .where('id', '==', idTo)
        .get()
        .then(querySnapshot => {
        querySnapshot.forEach(userTo => {
            console.log(`Found user to: ${userTo.data().username}`)
            if (userTo.data().androidNotificationToken != null) {
            // Get info user from (sent)
            admin
                .firestore()
                .collection('users')
                .where('id', '==', idFrom)
                .get()
                .then(querySnapshot2 => {
                querySnapshot2.forEach(userFrom => {
                    console.log(`Found user from: ${userFrom.data().username}`)
                    const payload = {
                    notification: {
                        title: `You have a message from "${userFrom.data().username}"`,
                        body: contentMessage,
                        badge: '1',
                        sound: 'default'
                    }
                    }
                    // Let push to the target device
                    admin
                    .messaging()
                    .sendToDevice(userTo.data().androidNotificationToken, payload)
                    .then(response => {
                        console.log('Successfully sent message:', response)
                    })
                    .catch(error => {
                        console.log('Error sending message:', error)
                    })
                })
                })
            } else {
            console.log('Can not find pushToken target user')
            }
        })
        })
        
        // // 2) Once we have user, check if they have a notification token; send notification, if they have a token
        // const androidNotificationToken = doc.data().androidNotificationToken;
        // const messageItem = snapshot.data();
        // if (androidNotificationToken != null) {
        // sendNotification(androidNotificationToken, messageItem);
        // } else {
        // console.log("No token for user, cannot send notification");
        // }

        // function sendNotification(androidNotificationToken, messageItem) {
        //     let body;

        //     body = `New message: ${
        //         messageItem.message
        //       }`;

        //     // 4) Create message for push notification
        //     const messageToSend = {
        //         notification: { body },
        //         token: androidNotificationToken,
        //         data: { recipient: userId }
        //     };

        //     // 5) Send message with admin.messaging()
        //     admin
        //     .messaging()
        //     .send(message)
        //     .then(response => {
        //         // Response is a message ID string
        //         console.log("Successfully sent message", response);
        //     })
        //     .catch(error => {
        //         console.log("Error sending message", error);
        //     });

        // }        
    });