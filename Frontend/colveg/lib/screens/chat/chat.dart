import 'dart:async';
import 'dart:convert';
import 'package:colveg/screens/chat/bandeja_entrada.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../menu_navegacion/drawer.dart';
import 'package:http/http.dart' as http;
import '../sistema/guardados/guardados.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatMessage {
  final String message;
  final bool isSentByMe;
  final DateTime date;

  ChatMessage(
      {required this.message, required this.isSentByMe, required this.date});
}

class ChatScreen extends StatefulWidget {
  final String imageReceptorName;
  final String receptorName;

  const ChatScreen(
      {Key? key, required this.imageReceptorName, required this.receptorName});
  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String userName = ' ';
  String imageUser = ' ';
  String idUser = ' ';

  late WebSocketChannel channel;
  late WebSocketChannel receptor;
  // ignore: deprecated_member_use
  void listenForMessages() {
    receptor.stream.listen((message) {
      // Recibir el mensaje del canal
      final receivedMessage = jsonDecode(message);
      print(receivedMessage);

      // Obtener el texto del mensaje
      final messageText = receivedMessage['message'];
      final senderId = receivedMessage['senderId'];
      // Actualizar la interfaz de usuario con el mensaje recibido
      if (senderId != idChat) {
        setState(() {
          _messages.add(ChatMessage(
              message: messageText, isSentByMe: false, date: DateTime.now()));
        });
        print('mensaje recivido');
      }
    });
  }

  Future<Map<String, dynamic>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$url/sitem/usuario/'),
      headers: {'Authorization': '$token'},
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      responseData['usuario'];
      print(responseData);
      return responseData;
    } else {
      throw Exception('Error al obtener los datos del usuario');
    }
  }

  Future<Map<String, dynamic>> getMensageRecibidos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final nameReceptor = widget.receptorName;
    Map<String, dynamic> mensajes = {};

    try {
      final response = await http.get(
        Uri.parse('$url/chat/chat/$nameReceptor/'),
        headers: {'Authorization': '$token'},
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decodedBody = jsonDecode(response.body);
        if (decodedBody is Map<String, dynamic>) {
          mensajes = decodedBody;
          print(mensajes);
        } else {
          print('Error: Response body is not a valid Map');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
    return mensajes;
  }

  Future<Map<String, dynamic>> getMensage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final nameReceptor = widget.receptorName;
    Map<String, dynamic> mensajes = {};

    try {
      final response = await http.get(
        Uri.parse('$url/chat/enviar/$nameReceptor/'),
        headers: {'Authorization': '$token'},
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decodedBody = jsonDecode(response.body);
        if (decodedBody is Map<String, dynamic>) {
          mensajes = decodedBody;
          print(mensajes);
        } else {
          print('Error: Response body is not a valid Map');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
    return mensajes;
  }

  Future<Map<String, dynamic>> getIdChat() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final nameReceptor = widget.receptorName;
    Map<String, dynamic> ids = {};

    try {
      final response = await http.get(
        Uri.parse('$url/chat/id/$nameReceptor/'),
        headers: {'Authorization': '$token'},
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final dynamic decodedBody = jsonDecode(response.body);
        if (decodedBody is Map<String, dynamic>) {
          ids = decodedBody;
        } else {
          print('Error: Response body is not a valid List');
        }
      }
    } catch (e) {
      print('Error: $e');
    }

    return ids;
  }

  List<ChatMessage> _messages = [];
  String idChat = '';
  String receptorId = '';

  @override
  void initState() {
    super.initState();

    getMensage().then((value) {
      List<ChatMessage> newMessages = [];
      final mensajes = value['mensajes_enviados'];
      print(mensajes);
      print(value);
      if (mensajes is Map<String, dynamic> && mensajes.isNotEmpty) {
        mensajes.forEach((key, mensaje) {
          String message = mensaje['mensaje_enviado'];
          DateTime date = DateTime.parse(mensaje['fecha']);
          bool isSentByMe =
              true; // Asigna un valor adecuado a esta variable según tu lógica
          newMessages.add(ChatMessage(
              message: message, isSentByMe: isSentByMe, date: date));
        });
      }

      if (newMessages.isEmpty) {
        print('No hay mensajes');
      } else {
        setState(() {
          _messages += newMessages;
        });
      }
    });

    // Timer.periodic(Duration(seconds: 5), (timer) {}
    getMensageRecibidos().then((value) {
      List<ChatMessage> newMessages = [];
      final mensajes = value['chats'];
      print(mensajes);
      print(value);
      if (mensajes is Map<String, dynamic> && mensajes.isNotEmpty) {
        mensajes.forEach((key, mensaje) {
          String message = mensaje['mensaje_enviado'];
          DateTime date = DateTime.parse(mensaje['fecha']);
          bool isSentByMe =
              false; // Asigna un valor adecuado a esta variable según tu lógica
          newMessages.add(ChatMessage(
              message: message, isSentByMe: isSentByMe, date: date));
        });
      }

      if (newMessages.isEmpty) {
        print('No hay mensajes');
      } else {
        setState(() {
          _messages += newMessages;
        });
      }
    });

    getUser().then((value) {
      setState(() {
        userName = value['usuario'][0]['user_name'];
        imageUser = value['usuario'][0]['image_user'];
        idUser = value['usuario'][0]['id'];
      });
      // getMensajes();
      // listenForMessages();

      getIdChat().then((value) {
        setState(() {
          receptorId = value['id_receptor'];
          idChat = value['id'];
        });

        // Mover la llamada a listenForMessages() aquí
        channel = WebSocketChannel.connect(
            Uri.parse('ws://$webSocket/ws/chat/room/$idChat/'));
        receptor = WebSocketChannel.connect(
            Uri.parse('ws://$webSocket/ws/chat/room/$receptorId/'));
        listenForMessages();
      });
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    receptor.sink.close();
    super.dispose();
  }

  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // funcion para ordenar lo mensajes del mas antiguo al mas reciente
    _messages.sort((a, b) => a.date.compareTo(b.date));
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 250, 250, 250),
        appBar: AppBar(
          backgroundColor: Color(0xFFF3ECB0),
          leading: Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    imageUser,
                  ),
                  radius: 12,
                ),
              );
            },
          ),
          title: Text(
            userName,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.bookmark,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Guardados()));
              },
            ),
          ],
        ),

        //MENU
        drawer: MyDrawer(),

        //CUERPO APP
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/fondochat.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Container(
                color: Color(0xFF344D67),
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 250,
                      child: Row(
                        children: [
                          SizedBox(
                            height: 50,
                            width: 50,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                widget.imageReceptorName,
                              ),
                              radius: 12,
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text(
                                    widget.receptorName,
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 250, 250, 250),
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (_messages.isEmpty) {
                      return const Center(
                        child: Text('No hay mensajes'),
                      );
                    } else {
                      final ChatMessage message = _messages[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: message.isSentByMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: message.isSentByMe
                                    ? Color.fromARGB(255, 232, 221, 123)
                                    : Color.fromARGB(255, 144, 231, 69),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              child: Text(
                                message.message,
                                style: TextStyle(
                                  color: message.isSentByMe
                                      ? Color.fromARGB(255, 0, 0, 0)
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
              Container(
                color: Color(0xFFF3ECB0),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _textEditingController,
                          decoration: InputDecoration(
                            hintText: 'Escribe un mensaje',
                            hintStyle: TextStyle(
                              color: Colors.black,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () async {
                        final String messageText = _textEditingController.text;
                        final prefs = await SharedPreferences.getInstance();
                        final token = prefs.getString('token');
                        print(token);
                        final nameReceptor = widget.receptorName;
                        channel.sink.add(jsonEncode({
                          'message': messageText,
                          'senderId': idChat,
                        }));

                        // enviar la información del registro al servidor
                        final response = await http.post(
                          Uri.parse(
                              '$url/chat/enviar/$nameReceptor/'),
                          headers: {
                            'Authorization': '$token',
                          },
                          body: jsonEncode({'mensaje_enviado': messageText}),
                        );
                        if (response.statusCode == 201) {
                          // getMensageRecibidos();
                          // registro exitoso, navegar a la pantalla de inicio
                          setState(() {
                            _messages.add(ChatMessage(
                                message: messageText,
                                isSentByMe: true,
                                date: DateTime.now()));
                          });
                          _textEditingController.clear();

                         final response = await http.post(
                            Uri.parse('$url/sitem/enviar-notificacion/$nameReceptor/'),
                            headers: {'Authorization': '$token'},
                          
                            body: jsonEncode({
                                'mensaje': messageText,
                            }),
                          );

                          if (response.statusCode == 200) {
                            print('Notificación enviada');
                          } else {
                            print('Error al enviar la notificación');
                          }

                        } else {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al registrar el usuario'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
