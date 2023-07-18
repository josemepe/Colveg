//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 18/06/2023
//SENA-CBA 2023

// se trae una pantalla donde se establece la conexion con el websocket

//importaciones de codigo
import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    // Establece la conexión WebSocket
    channel =
        channel = WebSocketChannel.connect(Uri.parse('ws://127.0.0.1:8000/ws/notificacion/'));
  }

  @override
  void dispose() {
    super.dispose();
    // Cierra la conexión WebSocket al salir de la pantalla
    channel.stream.listen(
      (event) {
        print(json.decode(event));
      },
      onDone: () {
        print('Connection closed');
      },
      onError: (error) {
        print('Error: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: const Column(
        children: [
          // Aquí puedes mostrar los mensajes del chat y un campo de texto para enviar nuevos mensajes
        ],
        ),
    );
  }
}