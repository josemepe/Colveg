//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 18/06/2023
//SENA-CBA 2023

// se trae una pantalla donde veras todos tus mensajes

//importaciones de codigo
import 'dart:convert';
import 'package:colveg/screens/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../Usuario/perfil_mio.dart';
import '../menu_navegacion/drawer.dart';
import 'package:http/http.dart' as http;

import '../sistema/guardados/guardados.dart';

// se crea la clase statefull
class BandejaEntrada extends StatefulWidget {
  @override
  _BandejaEntradaState createState() => _BandejaEntradaState();
}

class _BandejaEntradaState extends State<BandejaEntrada> {
  String? userName =
      ' '; // Variable para almacenar el nombre de usuario (con un tipo anulable)
  String? imageUser =
      ' '; // Variable para almacenar la URL de la imagen del usuario (con un tipo anulable)
  String idUser =
      ' '; // Variable para almacenar la ID del usuario (con un tipo no anulable)

  Future<Map<String, dynamic>> getUser() async {
    final prefs = await SharedPreferences
        .getInstance(); // Obtener una instancia de SharedPreferences
    final token = prefs
        .getString('token'); // Obtenga el valor 'token' de SharedPreferences

    // Enviar una solicitud GET a la URL especificada con el token en el encabezado 'Autorización'
    final response = await http.get(
      Uri.parse('$url/sitem/usuario/'),
      headers: {'Authorization': '$token'},
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = json
          .decode(response.body); // Analiza el cuerpo de la respuesta como JSON
      responseData['usuario'];
      return responseData; // Devuelve los datos de respuesta
    } else {
      throw Exception(
          'Error al obtener los datos del usuario'); // Lanzar una excepción si la solicitud falla
    }
  }

  Future<List<dynamic>> getChats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('$url/chat/listChats/'),
        headers: {'Authorization': '$token'},
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final List<dynamic> responseData =
            json.decode(response.body)['list_chats'];
        print(responseData);
        return responseData;
      }
    } catch (e) {
      print('Error: $e');
    }

    return []; // Retornar una lista vacía en caso de error o respuesta vacía
  }

  void initState() {
    super.initState();

    // Llamamos a la función getChats
    getChats();

    // Obtenemos el usuario y actualizamos el estado con los datos obtenidos
    getUser().then((value) {
      setState(() {
        userName = value['usuario'][0]['user_name'];
        imageUser = value['usuario'][0]['image_user'];
        idUser = value['usuario'][0]['id'];
        print(userName);
      });
    });
  }

  Future<Map<String, dynamic>> getMensageRecibidos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    Map<String, dynamic> mensajes = {};

    try {
      // Enviar una solicitud HTTP GET
      final response = await http.get(
        Uri.parse('$url/chat/chat/$userName/'),
        headers: {'Authorization': '$token'},
      );

      // Comprobar si la respuesta es exitosa y no está vacía
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        // Decodificar el cuerpo de la respuesta de JSON a un mapa
        mensajes = jsonDecode(response.body);
        print(mensajes);
      }
    } catch (e) {
      // Manejar cualquier error que ocurra durante la solicitud
      print('Error: $e');
    }

    // Devuelve el mapa de mensajes
    return mensajes;
  }

  Future<Map<String, dynamic>> getMensage() async {
    // Obtener la instancia de SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // Obtener el token de SharedPreferences
    final token = prefs.getString('token');
    // Crea un mapa vacío para almacenar los mensajes
    Map<String, dynamic> mensajes = {};

    try {
      // Enviar una solicitud GET a la URL especificada
      final response = await http.get(
        Uri.parse('$url/chat/enviar/$userName/'),
        headers: {
          'Authorization': '$token'
        }, // Incluir el token en los encabezados
      );

      // Comprobar si la respuesta es exitosa y el cuerpo no está vacío
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        // Decodifica el cuerpo de la respuesta de JSON a un mapa
        mensajes = jsonDecode(response.body);
      }
    } catch (e) {
      // Manejar cualquier error que ocurra durante la solicitud
      print('Error: $e');
    }

    // Devuelve el mapa de mensajes
    return mensajes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        appBar: AppBar(
          // Establecer el color de fondo de la AppBar
          backgroundColor: const Color(0xFFF3ECB0),

          // Agregar un widget principal a la barra de aplicaciones
          leading: Builder(
            builder: (BuildContext context) {
              // Envuelva el widget principal en un GestureDetector para detectar toques
              return GestureDetector(
                onTap: () {
                  // Abre el cajón cuando se toca el widget principal
                  Scaffold.of(context).openDrawer();
                },
                child: CircleAvatar(
                  // Mostrar la imagen del usuario como widget principal
                  backgroundImage: NetworkImage(
                    imageUser!,
                  ),
                  radius: 12,
                ),
              );
            },
          ),

          // Agregar un widget de título a la barra de aplicaciones
          title: Text(
            // Mostrar el nombre del usuario como título
            userName!,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),

          // Agregar widgets de acción a la barra de aplicaciones
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                // Mostrar un icono de marcador
                Icons.bookmark,
                color: Colors.black,
              ),
              onPressed: () {
                // Navegar a la pantalla Guardados cuando se presiona el icono de marcador
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Guardados()),
                );
              },
            ),
          ],
        ),

        //MENU
        drawer: const MyDrawer(),

        //CUERPO APP
        body: Column(
          children: [
            Container(
              color: const Color(0xFF344D67),
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
                              backgroundImage:
                                  AssetImage('assets/agaucatechat.webp'),
                              radius: 12,
                            )),
                        SizedBox(
                          width: 200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(
                                  'Chats',
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
                        Navigator.pop(
                          context,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: FutureBuilder(
                  future: getChats(),
                  builder: ((context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                          itemCount: snapshot.data?.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: const Color(0xFF344D67),
                              //se retorna un gesturedetector permite detectar diversos tipos de gestos táctiles realizados en la pantalla, como toques, arrastres, deslizamientos, etc
                              child: GestureDetector(
                                onTap: () {
                                  // Navegar a una nueva pantalla
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                            receptorName: snapshot.data?[index]
                                                ['receptor'],
                                            imageReceptorName:
                                                snapshot.data?[index]
                                                    ['image_receptor'])),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.all(10),
                                      width: 50,
                                      height: 50,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: Icon(Icons.person,
                                          color: Color(0xFF344D67)),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot.data?[index]['receptor'],
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Expanded(
                                      child: SizedBox(),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(width: 8.0),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => ChatScreen(
                                                      receptorName:
                                                          snapshot.data?[index]
                                                              ['receptor'],
                                                      imageReceptorName: snapshot
                                                              .data?[index]
                                                          ['image_receptor'])),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: CircleBorder(),
                                            padding: EdgeInsets.all(8.0),
                                            primary: Colors.green,
                                          ),
                                          child: Text(
                                            '1',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    } else if (snapshot.hasError) {
                      return Text('Error al cargar los favoritos');
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  })),
            ),
          ],
        ));
  }
}
