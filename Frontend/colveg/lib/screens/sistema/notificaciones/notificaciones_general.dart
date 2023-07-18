//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 14/06/2023
//SENA-CBA 2023

//nos muestra las notificaciones de toda la aplicacion de tus seguidos seguidores likes y demas

//importaciones de codigo

import 'dart:convert';
import 'package:colveg/screens/sistema/guardados/guardados.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constant/card.dart';
import '../../../main.dart';
import '../../menu_navegacion/drawer.dart';
import 'package:http/http.dart' as http;
// Future para traer el listado de productos

Future<List<dynamic>> getReport() async {
  // Crea una lista vacía llamada report que se utilizará para almacenar el informe
  List<dynamic> report = [];
  // Obtiene una instancia de SharedPreferences para obtener el token de autorización
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  // Establece la URL del informe en la variable url

  // Realiza una solicitud HTTP GET a la URL especificada, incluyendo el token de autorización en los encabezados
  try {
    final response = await http.get(
      Uri.parse('$url/sitem/reportes/'),
      headers: {'Authorization': '$token'},
    );
    // Verifica si la respuesta tiene un código de estado 200 (éxito)
    if (response.statusCode == 200) {
      // Si la respuesta es exitosa, decodifica el cuerpo de la respuesta en formato JSON.
      final decodedBody = jsonDecode(response.body);
      // Si el cuerpo decodificado contiene la clave 'reportes', asigna su valor a la lista report
      if (decodedBody['reportes'] != null) {
        report = decodedBody['reportes'];
      }
    }
  } catch (e) {
    print('Error: $e');
  }
  // Retorna la lista report, que puede contener los datos del informe obtenidos de la respuesta.
  return report;
}

Future<List<dynamic>> getPedidos() async {
  // Crea una lista vacía llamada pedidos que se utilizará para almacenar los pedidos.
  List<dynamic> pedidos = [];
  // Obtiene una instancia de SharedPreferences para obtener el token de autorización.
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  // establece la URL de los pedidos en la variable ur

  // Realiza una solicitud HTTP GET a la URL especificada, incluyendo el token de autorización en los encabezados.
  try {
    final response = await http.get(
      Uri.parse('$url/sitem/generate_qr_code/'),
      headers: {'Authorization': '$token'},
    );

    // Verifica si la respuesta tiene un código de estado 200 (éxito)
    if (response.statusCode == 200) {
      // Si la respuesta es exitosa, decodifica el cuerpo de la respuesta en formato JSON
      final decodedBody = jsonDecode(response.body);
      // Si el cuerpo decodificado contiene la clave 'pedidos', asigna su valor a la lista pedidos
      // En caso de que ocurra una excepción durante la solicitud, imprime un mensaje de error
      if (decodedBody['pedidos'] != null) {
        pedidos = decodedBody['pedidos'];
      }
    }
  } catch (e) {
    print('Error: $e');
  }

  // Retorna la lista pedidos, que puede contener los datos de los pedidos obtenidos de la respuesta.
  return pedidos;
}

Future<List<dynamic>> getNotific() async {
  // Crea una lista vacía llamada notific que se utilizará para almacenar las notificaciones.
  List<dynamic> notific = [];
  // Obtiene una instancia de SharedPreferences para obtener el token de autorización
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  // Establece la URL de las notificaciones en la variable ur

  // Realiza una solicitud HTTP GET a la URL especificada, incluyendo el token de autorización en los encabezados.
  try {
    final response = await http.get(
      Uri.parse('$url/sitem/notificaciones/'),
      headers: {'Authorization': '$token'},
    );

    // Verifica si la respuesta tiene un código de estado 200 (éxito)
    if (response.statusCode == 200) {
      // Si la respuesta es exitosa, decodifica el cuerpo de la respuesta en formato JSON
      final decodedBody = jsonDecode(response.body);

      // Si el cuerpo decodificado contiene la clave 'notificaciones', asigna su valor a la lista notific.
      if (decodedBody['notificaciones'] != null) {
        notific = decodedBody['notificaciones'];
      }
    }
  } catch (e) {
    print('Error: $e');
  }
  // Retorna la lista notific, que puede contener los datos de las notificaciones obtenidos de la respuesta.
  return notific;
}

class Notificacion extends StatefulWidget {
  @override
  _CardPageState createState() => _CardPageState();
}

class _CardPageState extends State<Notificacion> {
  List<dynamic> listNotifications = [];
  List<dynamic> segudores = [];
  List<dynamic> notificaciones = [];
  final Map<String, Color> ColorNotification = {};

  @override
  void initState() {
    super.initState();

    // Obtener reportes
    getReport().then((report) {
      setState(() {
        // Agregar los reportes a la lista de notificaciones existente
        listNotifications.addAll(report);
        if (listNotifications.isNotEmpty) {
          // Establecer un color para las notificaciones de tipo 'reporte'
          ColorNotification['reporte'] = const Color.fromRGBO(197, 94, 94, 1);
        }
      });

      // Mapear cada reporte a un formato específico y agregarlo a la lista de notificaciones
      notificaciones.addAll(report.map((notification) {
        return {
          ...notification,
          'tipo': 'reporte',
        };
      }));
    });

    // Obtener pedidos
    getPedidos().then((pedidos) {
      setState(() {
        // Agregar los pedidos a la lista de notificaciones existente
        listNotifications.addAll(pedidos);
        if (listNotifications.isNotEmpty) {
          // Establecer un color para las notificaciones de tipo 'pedidos'
          ColorNotification['pedidos'] =
              const Color.fromRGBO(173, 231, 146, 0.758);
        }
      });

      // Mapear cada pedido a un formato específico y agregarlo a la lista de notificaciones
      notificaciones.addAll(pedidos.map((notification) {
        return {
          ...notification,
          'tipo': 'pedidos',
        };
      }));
    });

    // Obtener notificaciones generales
    getNotific().then((notific) {
      setState(() {
        // Agregar las notificaciones a la lista de seguidores existente
        segudores.addAll(notific);
        // Establecer un color para las notificaciones de tipo 'seguidor'
        ColorNotification['seguidor'] = const Color.fromRGBO(52, 77, 103, 1);
      });

      // Mapear cada notificación a un formato específico y agregarlo a la lista de notificaciones
      notificaciones.addAll(notific.map((notification) {
        return {
          ...notification,
          'tipo': 'seguidor',
        };
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF3ECB0),
        //leading: Es el widget que se coloca en el lado izquierdo de la barra de navegación. En este caso, se utiliza un IconButton
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        // actions: Es una lista de widgets que se colocan en el lado derecho de la barra de navegación.
        //En este caso, se utiliza un IconButton con el ícono de marcador (Icons.bookmark) en color negro. Al hacer clic en el botón, se navega a la pantalla Guardados
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
      drawer: const MyDrawer(),

      //CUERPO APP
      body: Column(
        children: [
          Container(
            // Establece el color de fondo del contenedor como azul oscuro
            color: const Color(0xFF344D67),
            height: 70, // Establece la altura del contenedor en 70

            child: Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Alinea los elementos de la fila equitativamente

              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextButton(
                    onPressed: () {
                      // Navega a la página 'Notificacion' cuando se presiona el botón
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Notificacion()),
                      );
                    },
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.yellow),
                    ),
                    child: const Text(
                      'General',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w200,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextButton(
                    onPressed: () {
                      setState(() {});
                      // Actualiza el estado actual y, actualmente, no realiza una navegación a ninguna página
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => NotVendido()));
                    },
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.yellow),
                    ),
                    child: const Text(
                      'vendidos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w200,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextButton(
                    onPressed: () {
                      // Navega a la página 'Notificacion' cuando se presiona el botón
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Notificacion()),
                      );
                    },
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.yellow),
                    ),
                    child: const Text(
                      'Entrega',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w200,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SizedBox(
              child: FutureBuilder(
                future: getReport(),
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: notificaciones.length,
                      itemBuilder: (context, index) {
                        // Aquí puedes acceder a cada elemento de la lista combinada (reportes y notificaciones)
                        String userName = notificaciones[index][
                            'userName']; // Obtener el nombre de usuario de la notificación actual
                        String?
                            id; // Variable opcional para almacenar el ID de la notificación
                        
                        String name = ' '; // Variable opcional para almacenar el ID de la notificación

                        String?
                            producPedido; // Variable opcional para almacenar el producto del pedido
                        String tipoNotificacion = notificaciones[index][
                            'tipo']; // Obtener el tipo de notificación de la notificación actual

                        Color
                            color; // Variable para almacenar el color de la notificación
                        String
                            subtitulo; // Variable para almacenar el subtitulo de la notificación

                        if (tipoNotificacion == 'reporte') {

                          color = ColorNotification['reporte']!;
                          subtitulo =
                              'Motivo: ${notificaciones[index]['reporte']}, publicación: ${notificaciones[index]['namePublic']}, autor de la publicación: ${notificaciones[index]['nameAutho']}';
                          id = '${notificaciones[index]['idPublic']}';
                          name = '${notificaciones[index]['namePublic']}';

                        } else if (tipoNotificacion == 'seguidor') {

                          color = ColorNotification['seguidor']!;
                          subtitulo = 'Te empezó a seguir';
                          id = '${notificaciones[index]['id']}';

                        } else if (tipoNotificacion == 'pedidos') {

                          color = ColorNotification['pedidos']!;
                          subtitulo =
                              'vendedor:  ${notificaciones[index]['author']}';
                          producPedido =
                              'Pedido: ${notificaciones[index]['userName']} vendedor:  ${notificaciones[index]['author']}';
                          id = '${notificaciones[index]['id']}';

                        } else {
                          // Tipo de notificación desconocido
                          color = Colors.white;
                          subtitulo = 'nada';
                        }

                        return Card(
                          color: color,
                          child: GestureDetector(
                            onTap: () {
                              if (tipoNotificacion == 'reporte') {
                                Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyCard(idProduc: id!, title: name,), // Pasar el 'id' a MyCard
                                ),
                              );
                              } else if (tipoNotificacion == 'pedidos') {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(producPedido!),
                                      content: Expanded(
                                        child: Image.network(
                                            notificaciones[index]['imageQr']),
                                      ),
                                      actions: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              // TextButton(
                                              //   child: const Text('Ir a la publicación'),
                                              //   onPressed: () {
                                              //     Navigator.of(context).pop();
                                              //   },
                                              // ),
                                              TextButton(
                                                child: const Text('Cerrar'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
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
                                  child: const Icon(
                                    Icons.person,
                                    color: Color(0xFF344D67),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$userName',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        subtitulo,
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return const Text('Error al cargar los favoritos');
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }),
              ),
            ),
          )
        ],
      ),
    );
  }
}
