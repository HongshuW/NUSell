// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const admin = require("firebase-admin");
const functions = require("firebase-functions");

//var serviceAccount = require("/Users/liuzhilan/Documents/Development/orbital/learning/orbital2796_nusell/serviceAccountKey.json");

admin.initializeApp(
  //{credential: admin.credential.cert(serviceAccount)}
);
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
    .onUpdate((change, context) => {
        console.log('came in');
        const docAfter = change.after.data();
        console.log(docAfter.toString());
        
        const idFromIndex = docAfter['history'][docAfter.history.length - 1]['user'];
        const idFrom = docAfter['users'][idFromIndex];
        const idTo = docAfter['users'][1-idFromIndex];
        const contentMessage = docAfter['history'][docAfter.history.length - 1]['message'];
        functions.logger.log(contentMessage);
        // Get push token user to (receive)
        admin
        .firestore()
        .collection('users').doc(idTo)
        .get()
        .then(querySnapshotUserTo => {
            console.log(`Found user to: ${querySnapshotUserTo.data()['username']}`)
            if (querySnapshotUserTo.data()['androidNotificationToken'] != null) {
            // Get info user from (sent)
            admin
                .firestore()
                .collection('users')
                .doc(idFrom)
                .get()
                .then(querySnapshotUserFrom => {
                
                    console.log(`Found user from: ${querySnapshotUserFrom.data()['username']}`)
                    const payload = {
                    notification: {
                        title: `You have a message from "${querySnapshotUserFrom.data()['username']}"`,
                        body: contentMessage,
                        badge: '1',
                        sound: 'default'
                    }
                    }
                    // Let push to the target device
                    admin
                    .messaging()
                    .sendToDevice(querySnapshotUserTo.data()['androidNotificationToken'], payload)
                    .then(response => {
                        return console.log('Successfully sent message:', response);
                    })
                    .catch(error => {
                        return console.log('Error sending message:', error);
                    })
                
                })
            } else {
            console.log('Can not find pushToken target user')
            }
        
        })
        return console.log('End of function');
            
    });

    exports.helloWorld = functions.https.onRequest((request, response) => {
        response.send("Hello from Firebase!");
    });