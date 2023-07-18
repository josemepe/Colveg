//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 29/05/2023
//SENA-CBA 2023

//se ejecuta la aplicacion 

// import 'package:colveg/firebase_options.dart';

import 'package:colveg/firebase_options.dart';
import 'package:colveg/screens/chat/cli_chat.dart';

// import 'package:colveg/screens/home_screen.dart';

import 'package:colveg/screens/login_registro/Login.dart';
import 'package:colveg/screens/sistema/qr/scanerQr.dart';
// import 'package:colveg/screens/sistema/qr/scanerQr.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';

String? registrationToken;

Future<void> getRegistrationToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  try {
    registrationToken = await messaging.getToken();
    print('Token de registro: $registrationToken');
  } catch (e) {
    print('Error al obtener el token de registro: $e');
  }
}

void main() async {
  if (kIsWeb) {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
        await getRegistrationToken();
  } else if (Platform.isWindows) {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.windows);
    await getRegistrationToken();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        // options: DefaultFirebaseOptions.android
        );
    await getRegistrationToken();
  }

  runApp(const Myapp());
}
String url = 'http://35.208.48.25:8000';
String webSocket = '35.208.48.25:8000';

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  
  // @override
  // void initState() {
  //   initializeDefault();
  //   }
  @override
  
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'colveg',
      initialRoute: '/',
      theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.cyan[800],
          hintColor: Color.fromARGB(255, 24, 89, 209)),
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(builder: (BuildContext context) {
          switch (settings.name) {
            default:
<<<<<<< HEAD
              return  LoginCard();
=======
              return LoginScreen();
>>>>>>> origin/Chica
          }
        });
      },
    );
  }
}
