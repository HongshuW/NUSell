const admin = require("firebase-admin");
const functions = require("firebase-functions");

admin.initializeApp();
exports.onOfferAcceptedSendNotification = functions.firestore
    .document("/users/{userId}/offersMade/{productId}")
    .onUpdate((change, context) => {
        const productId = context.params.productId;
        const userId = context.params.userId;
        console.log(productId);
        console.log(userId);
        const docAfter = change.after.data();
        const docBefore = change.before.data();
        console.log(docAfter);

        if (docAfter['status'] == 'Accepted' && docBefore['status'] == 'Pending') {
            admin
                .firestore()
                .collection('users').doc(userId)
                .get()
                .then((querySnapshotUser) => {
                    if (querySnapshotUser.data()['androidNotificationToken'] != null) {
                        admin
                        .firestore()
                        .collection('posts').doc(productId)
                        .get()
                        .then((querySnapshotProduct) => {
                            const payload = {
                                notification: {
                                    title: `Your offer for "${querySnapshotProduct.data()['productName']}" has been accepted!`,
                                    body: `Go to offers made page to view`,
                                    badge: '1',
                                    sound: 'default'
                                },
                                data: {
                                    title: `Your offer for "${querySnapshotProduct.data()['productName']}" has been accepted!`,
                                    body: `Go to offers made page to view`,
                                    badge: '1',
                                    sound: 'default'
                                }
                            }

                            admin
                            .messaging()
                            .sendToDevice(querySnapshotUser.data()['androidNotificationToken'], payload)
                            .then(response => {
                                return console.log('Successfully sent message:', response);
                            })
                            .catch(error => {
                                return console.log('Error sending message:', error);
                            });
                        });
                    }
                });
        }

        if (docAfter['reviewDone'] == true && docBefore['reviewDone'] == false) {
            admin
                .firestore()
                .collection('posts').doc(productId)
                .get()
                .then((querySnapshotProduct) => {
                    const userTo = querySnapshotProduct.data()['user'];
                    admin
                        .firestore()
                        .collection('users').doc(userTo)
                        .get()
                        .then((querySnapshotUserTo) => {
                            if (querySnapshotUserTo.data()['androidNotificationToken'] != null) {
                                admin
                                    .firestore()
                                    .collection('users').doc(userId)
                                    .get()
                                    .then((querySnapshotUserFrom) => {
                                        const payload = {
                                            notification: {
                                                title: `You have received a new review from "${querySnapshotUserFrom.data()['username']}"`,
                                                body: `Go to reviews page to view`,
                                                badge: '1',
                                                sound: 'default'
                                            },
                                            data: {
                                                title: `You have received a new review from "${querySnapshotUserFrom.data()['username']}"`,
                                                body: `Go to reviews page to view`,
                                                badge: '1',
                                                sound: 'default'
                                            }
                                        }
            
                                        admin
                                        .messaging()
                                        .sendToDevice(querySnapshotUserTo.data()['androidNotificationToken'], payload)
                                        .then(response => {
                                            return console.log('Successfully sent message:', response);
                                        })
                                        .catch(error => {
                                            return console.log('Error sending message:', error);
                                        });
                                    })
                            }
                        });
                    });
        }
    });

exports.onAnotherOfferReceivedSendNotification = functions.firestore
    .document("/users/{userId}/offersReceived/{productId}")
    .onUpdate((change, context) => {
        const productId = context.params.productId;
        const userId = context.params.userId;
        console.log(productId);
        console.log(userId);
        const docAfter = change.after.data();
        const docBefore = change.before.data();
        console.log(docAfter);

        if (docAfter['offers'] != "" && (docAfter['offers'].length - docBefore['offers'].length == 1) ) {
            admin
                .firestore()
                .collection('users').doc(userId)
                .get()
                .then((querySnapshotUser) => {
                    if (querySnapshotUser.data()['androidNotificationToken'] != null) {
                        admin
                        .firestore()
                        .collection('posts').doc(productId)
                        .get()
                        .then((querySnapshotProduct) => {
                            const payload = {
                                notification: {
                                    title: `You have received another offer for "${querySnapshotProduct.data()['productName']}"!`,
                                    body: `Go to offers received page to view`,
                                    badge: '1',
                                    sound: 'default'
                                },
                                data: {
                                    title: `You have received another offer for "${querySnapshotProduct.data()['productName']}"!`,
                                    body: `Go to offers received to view`,
                                    badge: '1',
                                    sound: 'default'
                                }
                            }

                            admin
                            .messaging()
                            .sendToDevice(querySnapshotUser.data()['androidNotificationToken'], payload)
                            .then(response => {
                                return console.log('Successfully sent message:', response);
                            })
                            .catch(error => {
                                return console.log('Error sending message:', error);
                            });
                        });

                        
                    }
                });
        }
        

        return console.log('End of function');

    });

exports.onOfferReceivedSendNotification = functions.firestore
    .document("/users/{userId}/offersReceived/{productId}")
    .onCreate((snapshot, context) => {
        const productId = context.params.productId;
        const userId = context.params.userId;
        console.log(productId);
        console.log(userId);
        const doc = snapshot.data();
        console.log(doc);

        admin
        .firestore()
        .collection('users').doc(userId)
        .get()
        .then((querySnapshotUser) => {
            if (querySnapshotUser.data()['androidNotificationToken'] != null) {
                admin
                .firestore()
                .collection('posts').doc(productId)
                .get()
                .then((querySnapshotProduct) => {
                    const payload = {
                        notification: {
                            title: `You have received a new offer for "${querySnapshotProduct.data()['productName']}"!`,
                            body: `Go to offers received page to view`,
                            badge: '1',
                            sound: 'default'
                        },
                        data: {
                            title: `You have received a new offer for "${querySnapshotProduct.data()['productName']}"!`,
                            body: `Go to offers received to view`,
                            badge: '1',
                            sound: 'default'
                        }
                    }

                    admin
                    .messaging()
                    .sendToDevice(querySnapshotUser.data()['androidNotificationToken'], payload)
                    .then(response => {
                        return console.log('Successfully sent message:', response);
                    })
                    .catch(error => {
                        return console.log('Error sending message:', error);
                    });
                });

                
            }
        });

        return console.log('End of function');

    });

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