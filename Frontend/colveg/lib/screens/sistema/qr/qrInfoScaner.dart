//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 29/05/2023
//SENA-CBA 2023
//se abre una camara que escanea un qr y te da info del el producto 

//importaciones de codigo
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';
import '../../home_screen.dart';
import '../../menu_navegacion/drawer.dart';
import '../guardados/guardados.dart';

// funcion que te trae  el nombre de el usuario 
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
    return responseData;
  } else {
    throw Exception('Error al obtener los datos del usuario');
  }
}


class QRInfoScreen extends StatefulWidget {
final String clasific;  // Variable de tipo String para almacenar la clasificación
final String image;  // Variable de tipo String para almacenar la imagen
final int orden;  // Variable de tipo entero para almacenar el orden
final String id;  // Variable de tipo String para almacenar el ID
final int valor;  // Variable de tipo String para almacenar el ID
final String autor;  // Variable de tipo String para almacenar el ID
final String fecha;  // Variable de tipo String para almacenar el ID
final String ubicacion;


  const QRInfoScreen(
  {
    super.key,  // Clave de super
    required this.clasific,  // Parámetro requerido: clasificación
    required this.image,  // Parámetro requerido: imagen
    required this.orden,  // Parámetro requerido: orden
    required this.id,
    required this.valor,  // Parámetro requerido: ID
    required this.autor,
    required this.fecha,
    required this.ubicacion
  }
);


  @override
  State<QRInfoScreen> createState() => _QRInfoScreenState();
}

class _QRInfoScreenState extends State<QRInfoScreen> {
  // se crea un tipo texto que trae usuario
  String userName= ' ';
  // se crea un tipo texto que trae nombre
  String name= ' ';
  // se crea un tipo texto que trae id del usuario 
  String userId = ' ';
  // se crea un tipo texto que trae imagen del usuario
  String imageUser = ' ';
  //se crea un booleano para saber si es administrador
  bool is_admin = false;

    @override
  void initState() {
    super.initState();
    // Obtener la información del usuario y almacenarlas en variables globales para su posterior uso
    getUser().then((value) {
      setState(() {
        userName = value['usuario'][0]['user_name'];
        imageUser = value['usuario'][0]['image_user'];
        userId = value['usuario'][0]['id'];
        is_admin = value['usuario'][0]['is_admin'];
        print(userName);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  backgroundColor: const Color(0xFFF3ECB0), // Establece el color de fondo de la barra de aplicaciones como amarillo claro
  leading: Builder(
    builder: (BuildContext context) {
      return GestureDetector(
        onTap: () {
          Scaffold.of(context).openDrawer();
        },
        child: CircleAvatar(
          backgroundImage: NetworkImage(
            imageUser, // Establece la imagen de fondo del avatar utilizando la URL proporcionada por 'imageUser'
          ),
          radius: 12, // Establece el radio del avatar en 12
        ),
      );
    },
  ),
  title: Text(
    userName, // Muestra el nombre de usuario en la barra de aplicaciones
    style: const TextStyle(
      color: Colors.black, // Establece el color del texto como negro
    ),
  ),
  actions: <Widget>[
    IconButton(
      icon: const Icon(
        Icons.bookmark,
        color: Colors.black, // Establece el color del icono como negro
      ),
      onPressed: () {
        // Navega a la página 'Guardados' cuando se presiona el botón
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

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('ruta_del_fondo.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Clasificación: ${widget.clasific}',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Cantidad ordenada: ${widget.orden}',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 8),
                Text(
                  'Ubicación donde la encuentras: ${widget.ubicacion}',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 8),
                Text(
                  'Precio: \$${widget.valor}',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 8),
                Text(
                  'Expira: ${widget.fecha}',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 8),
                Text(
                  'Perfil: ${widget.autor}',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 32),
                CachedNetworkImage(
                                                    width: 400,
                                                    height: 200,
                                                    imageUrl: widget.image,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context,
                                                            url) =>
                                                        const CircularProgressIndicator(),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        const Icon(Icons.error),
                                                  ),
                SizedBox(height: 32),
                ElevatedButton(
      onPressed: () {
        // Reemplaza la ruta actual con la página 'Inicio' cuando se presiona el botón
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Inicio()),
        );
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFFADE792),
      ),
      child: const Text('Cerrar'),  // Muestra el texto 'Cerrar' en el botón
    ),
              ],
            ),
          ),
        ),
     ),
  );
  }
}