importScripts('https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js');

firebase.initializeApp({
  apiKey: 'AIzaSyA6GFNxVPUGR9vw7o19rpZplYKfHE9wZiY',
  authDomain: 'colveg-67dae.firebaseapp.com',
  projectId: 'colveg-67dae',
  storageBucket: 'colveg-67dae.appspot.com',
  messagingSenderId: '696273535872',
  appId: '1:696273535872:web:ef6351c0d4803f829d3765',
});

const messaging = firebase.messaging();

// Configura las opciones de notificación
messaging.setBackgroundMessageHandler(function (payload) {
  console.log('[firebase-messaging-sw.js] Recibido el fondo de la notificación: ', payload);
  
  const notificationOptions = {
    body: payload.data.body,
    icon: '/icono.png',
  };

  return self.registration.showNotification(payload.data.title, notificationOptions);
});
