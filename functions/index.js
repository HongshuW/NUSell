const admin = require("firebase-admin");
const functions = require("firebase-functions");

admin.initializeApp();
exports.onMessageSendNotification = functions.firestore
    .document("/chats/{docId}")
    .onUpdate((change, context) => {
        console.log('came in');
        const docBefore = change.before.data();
        const docAfter = change.after.data();
        console.log(docAfter.toString());
        if (docBefore['history'].length == docAfter['history'].length) {
            return console.log('Nothing to change');
        }
        
        const idFromIndex = docAfter['history'][docAfter.history.length - 1]['user'];
        const idFrom = docAfter['users'][idFromIndex];
        const idTo = docAfter['users'][1-idFromIndex];
        const contentMessage = docAfter['history'][docAfter.history.length - 1]['message'];
        console.log(contentMessage);
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
                        },
                        data: {
                            title  : `You have a message from "${querySnapshotUserFrom.data()['username']}"`,
                            body : contentMessage,
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