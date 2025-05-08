// web/firebase-messaging-sw.js
importScripts('https://www.gstatic.com/firebasejs/10.11.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/10.11.0/firebase-messaging.js');

firebase.initializeApp({
  apiKey: 'AIzaSyAyWZOeT1a9AgsGmr74FgUt2pi7BWNQGvQ',
  authDomain: 'myclassroom-3996f.firebaseapp.com',
  projectId: 'myclassroom-3996f',
  storageBucket: 'myclassroom-3996f.firebasestorage.app',
  messagingSenderId: '1062358116698',
  appId: '1:1062358116698:ios:4176b88427980f289e2b63',
  measurementId: 'G-Y0Y1RV8C1X'
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
