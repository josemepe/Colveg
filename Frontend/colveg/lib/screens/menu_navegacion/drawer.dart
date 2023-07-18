//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 29/05/2023
//SENA-CBA 2023

// se trae un navegador donde se puede navegar a otras pantallas

//importaciones de codigo
import 'dart:convert';
import 'package:colveg/screens/Usuario/perfil_mio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../chat/bandeja_entrada.dart';
import '../home_screen.dart';
import '../Producto/publicar.dart';
import '../login_registro/Login.dart';
import '../mapa/mapa_mapbox.dart';
import '../mapa/mapa_screen.dart';
import 'package:http/http.dart' as http;
import '../sistema/guardados/guardados.dart';
import '../sistema/notificaciones/notificaciones_general.dart';
import '../sistema/qr/scanerQr.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
//crear una clase de tipo stateles para que el usuario solo pueda   visualizar y llenar campos que se le permitan  todo lo de la pantalla
class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  //se crea valores que pueden recibir valores nulos
  String userName = ' ';
  String imageUser = ' ';
  String idUser = ' ';

  //se crea un metodo get que me devuelve un mapeo  de forma asincrona
  Future<Map<String, dynamic>> getUserDrawer() async {
    //estos finals se utiliza para recuperar unos tokens de autenticacion almacenados en una url de una api de django
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    //se crea una uri apartir de una url  la cual se hace una solicitud con el token para proporcionar la informacion
    final response = await http.get(
      Uri.parse('$url/sitem/usuario/'),
      headers: {'Authorization': '$token'},
    );

    //se esta haciendo la verificacion del estado de la respuesta de http y devuelve a los usuarios un 201
    if (response.statusCode == 201) {
      //se decodifica de formato JSON a un mapa de Dart utilizando la función json.decode(). El mapa decodificado se almacena en una variable llamada responseData.
      final Map<String, dynamic> responseData = json.decode(response.body);
      responseData['usuario'];
      print(responseData);
      return responseData;
      // Si el código de estado de la respuesta HTTP no es igual a 201, se lanza una excepción con un mensaje de er
    } else {
      throw Exception('Error al obtener los datos del usuario');
    }
  }

  //el método initState llama a la función asincrónica getUserDrawer, que devuelve un objeto Future. Cuando se resuelve el Future, se actualiza el estado del widget usando el método setState
  @override
  void initState() {
    super.initState();
    getUserDrawer().then((value) {
      setState(() {
        //se asignan a las variables userName e imageUser, que se utilizan para mostrar el nombre y la imagen del usuario
        userName = value['usuario']?[0]['user_name'];
        imageUser = value['usuario']?[0]['image_user'];
        idUser = value['usuario']?[0]['id'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Container(
                width: 400,
                height: double.infinity,
                color: const Color(0xFFF3ECB0),
                //se crea una columna
                child: Column(
                  //MainAxisAlignment se utiliza para alinear los widgets secundarios en el eje principal del contenedor.
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                      //se retorna un gesturedetector permite detectar diversos tipos de gestos táctiles realizados en la pantalla, como toques, arrastres, deslizamientos, etc
                      child: GestureDetector(
                        onTap: () {
                          //registro exitoso, navegar a la pantalla de inicio
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyPerfilPage()));
                        },
                        //se crea un hijo la cual contiene un circleavatar que tendra dentro una imagen que trae de la base de datos
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(imageUser),
                          radius: 70,
                        ),
                      ),
                    ),
                    //se crea una caja con el sixebox que nos haga un espacio
                    SizedBox(height: 5),
                    //se pone un texto
                    Text(
                      userName,
                      style: TextStyle(fontSize: 20),
                    ),
                    //se crea una caja con el sixebox que nos haga un espacio
                    SizedBox(height: 20),

                    Container(
                      height: 1,
                      color: Colors.grey,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    //se crea una caja con el sixebox que nos haga un espacio
                    SizedBox(height: 40),
                    Expanded(
                      // se utiliza para construir una lista de elementos con desplazamiento vertical
                      child: ListView(
                        children: [
                          // se utiliza comúnmente dentro de un ListView para representar cada elemento de la lista
                          ListTile(
                            //es una propiedad AppBar que se utiliza para mostrar  en el lado izquierdo
                            leading: const Icon(Icons.home),
                            title: const Text('Inicio'),
                            onTap: () {
                              //registro exitoso, navegar a la pantalla de inicio
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Inicio()));
                            },
                          ),
                          //se utiliza comúnmente dentro de un ListView para representar cada elemento de la lista
                          ListTile(
                            leading: const Icon(Icons.notifications),
                            title: const Text('Notificaciones'),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Notificacion()));
                            },
                          ),
                          //se utiliza comúnmente dentro de un ListView para representar cada elemento de la lista
                          //se utiliza comúnmente dentro de un ListView para representar cada elemento de la lista
                          ListTile(
                            leading: const Icon(Icons.qr_code),
                            title: const Text('Scanear'),
                            onTap: () {
                              if (kIsWeb) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Esta opción solo está disponible en la aplicación móvil.\nHaz clic aquí para descargarla:',
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 20),
                                            ElevatedButton(
                                              child: Text('Descargar aplicación'),
                                              onPressed: () {
                                                String downloadLink = 'https://example.com/download'; // Reemplaza con la dirección de descarga real
                                                // Agrega aquí el código para abrir el enlace de descarga
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );

                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => scanerQr()),
                                );
                              }
                            },
                          ),

                          ListTile(
                            leading: const Icon(Icons.post_add),
                            title: const Text('Publicar Producto'),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PublicarScreen()));
                            },
                          ),
                          //se utiliza comúnmente dentro de un ListView para representar cada elemento de la lista
                          ListTile(
                            leading: const Icon(Icons.bookmark),
                            title: const Text('Guardado'),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Guardados()));
                            },
                          ),
                          //se utiliza comúnmente dentro de un ListView para representar cada elemento de la lista
                          ListTile(
                            leading: const Icon(Icons.map_rounded),
                            title: const Text('Búsqueda cercana'),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MapMabox()));
                            },
                          ),
                          //se utiliza comúnmente dentro de un ListView para representar cada elemento de la lista
                          ListTile(
                            leading: const Icon(Icons.message),
                            title: const Text('Chats'),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BandejaEntrada()));
                            },
                          ),
                          //se crea una caja con el sixebox que nos haga un espacio
                          SizedBox(height: 70),
                          Container(
                            height: 1,
                            color: Colors.grey,
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                          ),
                          //se utiliza comúnmente dentro de un ListView para representar cada elemento de la lista
                          ListTile(
                            leading: Icon(
                              Icons.logout,
                              color: Colors.red[800],
                            ),
                            //se pone un texto
                            title: Text(
                              'Cerrar Sesión',
                              style: TextStyle(color: Colors.red[800]),
                            ),
                            onTap: () {
                              //registro exitoso, navegar a la pantalla de inicio
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ),
          );

  }
}
