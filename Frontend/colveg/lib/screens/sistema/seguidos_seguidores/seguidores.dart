//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 29/05/2023
//SENA-CBA 2023
//se mira los seguidores  de la persona y los de uno

//importaciones de codigo
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';
import '../../Usuario/perfil_mio.dart';
import '../../menu_navegacion/drawer.dart';
import 'package:http/http.dart' as http;

import '../guardados/guardados.dart';

//se trae la clase de tipo stateful para poder modificar agragar todo lo que queramos

class Seguidors extends StatefulWidget {
  const Seguidors({super.key, required this.userName});
  final String userName;

  @override
  State<Seguidors> createState() => _SeguidorsState();
}

class _SeguidorsState extends State<Seguidors> {
  //se crea valores que pueden recibir valores nulos
  String userName = ' ';
  String imageUser = ' ';

  final Map<String, bool> _isFollowed = {};

  Future<List<dynamic>> getSeguidores() async {
    // Se define la URL de la API que se utilizará para obtener los seguidores.

    List<dynamic> listSeguidores = [];
    // Se declara una lista vacía que contendrá los seguidores.

    final response =
        await http.get(Uri.parse('$url/sitem/seguidores/${widget.userName}/'));
    // Se realiza una solicitud GET a la URL utilizando la biblioteca http.

    if (response.statusCode == 200) {
      // Si la solicitud se realizó correctamente (código de estado 200 OK).

      final Map<String, dynamic> responseData = json.decode(response.body);
      // Se decodifica la respuesta JSON obtenida en un mapa de cadenas y dinámicos.

      listSeguidores = responseData['follower_list'];
      // Se asigna la lista de seguidores obtenida del mapa decodificado.

      print(listSeguidores);
      // Se imprime la lista de seguidores en la consola para fines de depuración.

      return listSeguidores;
      // Se devuelve la lista de seguidores obtenida.
    } else {
      throw Exception('Error al obtener los datos del usuario');
      // Si la solicitud no se realizó correctamente, se lanza una excepción con un mensaje de error.
    }
  }

  Future<List<dynamic>> getSeguidos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    // Se obtiene el token de autenticación guardado en las preferencias compartidas.

    List<dynamic> listSeguidos = [];
    // Se declara una lista vacía que contendrá los seguidos.

    final response = await http.get(
      Uri.parse('$url/sitem/seguidos/'),
      headers: {'Authorization': '$token'},
    );
    // Se realiza una solicitud GET a la URL especificada, utilizando el token de autenticación en los encabezados de la solicitud.

    if (response.statusCode == 201) {
      // Si la solicitud se realizó correctamente (código de estado 201 CREATED).

      final Map<String, dynamic> responseData = json.decode(response.body);
      // Se decodifica la respuesta JSON obtenida en un mapa de cadenas y dinámicos.

      if (responseData['follow_list'] != null) {
        listSeguidos = responseData['follow_list'];
      }
      // Si la lista de seguidos en la respuesta no es nula, se asigna a la variable `listSeguidos`.

      print(responseData);
      // Se imprime la respuesta JSON en la consola para fines de depuración.

      return listSeguidos;
      // Se devuelve la lista de seguidos obtenida.
    } else {
      print('Falló la solicitud con estado ${response.statusCode}');
      // Si la solicitud no se realizó correctamente, se imprime un mensaje de error con el código de estado en la consola.
    }

    print(listSeguidos);
    // Se imprime la lista de seguidos (puede ser una lista vacía) en la consola.

    return listSeguidos;
    // Se devuelve la lista de seguidos obtenida (que puede ser una lista vacía en caso de error).
  }

  Future<bool> _getIsFollowing(String cardId) async {
    final seguidos = await getSeguidos();
    // Se obtiene la lista de seguidos llamando a la función `getSeguidos()`.

    final follow = {
      'image_user':
          listSeguidores.isNotEmpty ? listSeguidores[0]['image_seguidor'] : ' ',
      'user_name':
          listSeguidores.isNotEmpty ? listSeguidores[0]['user_seguidor'] : ' '
    };
    // Se crea un mapa `follow` con la información de imagen de usuario y nombre de usuario.
    // Si la lista `listSeguidores` no está vacía, se asigna la primera imagen de seguidor y el primer nombre de seguidor.
    // De lo contrario, se asignan cadenas vacías.

    final isFollowing =
        seguidos.any((element) => element['user_name'] == follow['user_name']);
    // Se verifica si algún elemento de la lista `seguidos` tiene el mismo nombre de usuario que `follow`.
    // Si se encuentra una coincidencia, `isFollowing` se establece en `true`; de lo contrario, se establece en `false`.

    _isFollowed[cardId] = isFollowing; // Actualiza el estado del botón
    // Se actualiza el estado del botón identificado por `cardId` en el mapa `_isFollowed` con el valor de `isFollowing`.

    return isFollowing;
    // Se devuelve el valor de `isFollowing`.
  }

  Future<void> actualizarSeguimiento(String cardId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    // Se obtiene el token de las preferencias compartidas.
    // Se define la URL para la solicitud HTTP.

    var follow = {
      'image_user':
          listSeguidores.isNotEmpty ? listSeguidores[0]['image_seguidor'] : '',
      'user_name':
          listSeguidores.isNotEmpty ? listSeguidores[0]['user_seguidor'] : ''
    };
    // Se crea un mapa `follow` con la información de imagen de usuario y nombre de usuario.
    // Si la lista `listSeguidores` no está vacía, se asigna la primera imagen de seguidor y el primer nombre de seguidor.
    // De lo contrario, se asignan cadenas vacías.

    if (_isFollowed[cardId]!) {
      // Si el botón está siendo seguido, se envía una solicitud DELETE para dejar de seguir.
      var response = await http.delete(
        Uri.parse('$url/sitem/seguidos/'),
        headers: {'Authorization': '$token'},
        body: jsonEncode(follow),
      );
      // Se realiza la solicitud DELETE con la URL, los encabezados y el cuerpo especificados.

      if (response.statusCode == 201) {
        // Si la respuesta tiene un estado 201 (éxito), se actualiza el estado del botón a false.
        setState(() {
          _isFollowed[cardId] = false;
        });
      }
    } else {
      // Si el botón no está siendo seguido, se envía una solicitud POST para seguir.
      var response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': '$token'},
        body: jsonEncode(follow),
      );
      // Se realiza la solicitud POST con la URL, los encabezados y el cuerpo especificados.

      if (response.statusCode == 201) {
        // Si la respuesta tiene un estado 201 (éxito), se actualiza el estado del botón a true.
        setState(() {
          _isFollowed[cardId] = true;
        });
      }
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    // Se obtiene el token de las preferencias compartidas.
    // Se define la URL para la solicitud HTTP.

    final response = await http.get(
      Uri.parse('$url/sitem/usuario/'),
      headers: {'Authorization': '$token'},
    );
    // Se realiza una solicitud GET con la URL y los encabezados especificados.

    if (response.statusCode == 201) {
      // Si la respuesta tiene un estado 201 (éxito), se decodifica el cuerpo de la respuesta en un mapa.

      final Map<String, dynamic> responseData = json.decode(response.body);
      // Se decodifica el cuerpo de la respuesta en un mapa llamado `responseData`.

      responseData['usuario'];
      // Se accede a la clave 'usuario' en el mapa `responseData`, pero no se hace nada con ella.

      return responseData;
      // Se devuelve el mapa `responseData`.
    } else {
      throw Exception('Error al obtener los datos del usuario');
      // Si la respuesta no tiene un estado 201, se lanza una excepción con un mensaje de error.
    }
  }

  @override
  void initState() {
    super.initState();

    // Se llama al método `getUser` para obtener los datos del usuario.
    getUser().then((value) {
      userName = value['usuario'][0]['user_name'];
      imageUser = value['usuario'][0]['image_user'];

      // Se llama al método `getSeguidores` para obtener la lista de seguidores.
      getSeguidores().then((seguidores) {
        setState(() {
          listSeguidores = seguidores;

          // Se itera sobre la lista de seguidores.
          listSeguidores.forEach((seguidor) {
            String cardId = seguidor['id'];
            _isFollowed[cardId] =
                false; // Inicializa todos los valores como false

            // Se llama al método `_getIsFollowing` para verificar si el usuario sigue al seguidor actual.
            _getIsFollowing(cardId).then((isFollowing) {
              setState(() {
                _isFollowed[cardId] =
                    isFollowing; // Actualiza el estado del botón
              });
            });
          });
        });
      });
    });
  }

  List listSeguidos = []; // Se declara una lista vacía llamada "listSeguidos"
  List listSeguidores =
      []; // Se declara una lista vacía llamada "listSeguidores"
  final int _counter =
      1; // Se declara una variable entera "counter" con valor 1

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 250, 250),

      appBar: AppBar(
        backgroundColor: const Color(
            0xFFF3ECB0), // Establece el color de fondo de la app bar
        leading: Builder(
          // Define el widget que se muestra en el extremo izquierdo de la app bar
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Scaffold.of(context)
                    .openDrawer(); // Abre el drawer (panel lateral) cuando se toca este widget
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  imageUser, // Establece la imagen de fondo del avatar circular
                ),
                radius: 12, // Establece el radio del avatar circular
              ),
            );
          },
        ),
        title: Text(
          userName, // Muestra el nombre de usuario en el centro de la app bar
          style: const TextStyle(
            color: Colors.black, // Establece el color del texto del título
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons
                  .bookmark, // Muestra el icono de marcador de libro en la app bar
              color: Colors.black, // Establece el color del icono
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Guardados()), // Navega a la pantalla "Guardados" al presionar este botón
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Seguidores',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal:
                          15), // Agrega un espacio de relleno horizontal alrededor del botón
                  child: IconButton(
                    icon: const Icon(Icons
                        .arrow_back), // Muestra el icono de flecha hacia atrás
                    color: Colors.white, // Establece el color del icono
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const MyPerfilPage()), // Navega a la página "MyPerfilPage" al presionar este botón
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              const Text(
                'Seguidores', // Muestra el texto "Seguidores"
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.left,
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Pepito Perez', // Muestra el texto "Pepito Perez"
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Text(
                    'Tus seguidos son $_counter', // Muestra el texto "Tus seguidos son" seguido del valor de la variable _counter
                    style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder(
                future: getSeguidores(),
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: listSeguidores.length,
                        itemBuilder: (context, index) {
                          final cardId = listSeguidores[index]['id'];
                          return Card(
                            color: const Color(0xFF344D67),
                            child: Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(
                                      10), // Establece un margen de 10 píxeles en todos los lados del contenedor
                                  width:
                                      50, // Establece el ancho del contenedor en 50 píxeles
                                  height:
                                      50, // Establece la altura del contenedor en 50 píxeles
                                  decoration: const BoxDecoration(
                                    shape: BoxShape
                                        .circle, // Establece la forma del contenedor como un círculo
                                    color: Colors
                                        .white, // Establece el color de fondo del contenedor como blanco
                                  ),
                                  child: CircleAvatar(
                                    radius:
                                        25.0, // Establece el radio del círculo interno del avatar en 25 píxeles
                                    backgroundImage: NetworkImage(
                                      listSeguidores[index][
                                          'image_seguidor'], // Carga la imagen de fondo desde la URL especificada en listSeguidores[index]['image_seguidor']
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start, // Alinea el contenido del Column a la izquierda
                                  children: [
                                    Text(
                                      listSeguidores[index][
                                          'user_seguidor'], // Muestra el nombre de usuario del seguidor
                                      style: const TextStyle(
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
                                if (listSeguidores[index]['user_seguidor'] !=
                                    userName)
                                  ElevatedButton(
                                    onPressed: () async {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final token = prefs.getString('token');

                                      if (_isFollowed[cardId] == false) {
                                        // Realiza una solicitud HTTP POST para seguir al usuario
                                        var response = await http.post(
                                          Uri.parse('$url/sitem/seguidos/'),
                                          headers: {'Authorization': '$token'},
                                          body: jsonEncode({
                                            'image_user': listSeguidores[index]
                                                ['image_seguidor'],
                                            'user_name': listSeguidores[index]
                                                ['user_seguidor'],
                                          }),
                                        );

                                        if (response.statusCode == 201) {
                                          // Actualiza el estado para indicar que ahora se sigue al usuario
                                          setState(() {
                                            _isFollowed[cardId] = true;
                                          });
                                        }
                                      } else {
                                        // Realiza una solicitud HTTP DELETE para dejar de seguir al usuario
                                        var response = await http.delete(
                                          Uri.parse('$url/sitem/seguidos/'),
                                          headers: {'Authorization': '$token'},
                                          body: jsonEncode({
                                            'image_user': listSeguidores[index]
                                                ['image_seguidor'],
                                            'user_name': listSeguidores[index]
                                                ['user_seguidor'],
                                          }),
                                        );

                                        if (response.statusCode == 201) {
                                          // Actualiza el estado para indicar que se dejó de seguir al usuario
                                          setState(() {
                                            _isFollowed[cardId] = false;
                                          });
                                        }
                                      }
                                    },
                                    child: SizedBox(
                                      width:
                                          100, // Establece el ancho del SizedBox en 100
                                      height:
                                          40, // Establece la altura del SizedBox en 40
                                      child: Center(
                                        child: Text(
                                          _isFollowed[cardId] ??
                                                  false // Evalúa el valor de _isFollowed[cardId], si es nulo, se utiliza el valor false como valor predeterminado
                                              ? "Dejar de seguir" // Si _isFollowed[cardId] es verdadero, muestra el texto "Dejar de seguir"
                                              : "Seguir tambien", // Si _isFollowed[cardId] es falso, muestra el texto "Seguir tambien"
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors
                                                  .white), // Establece el estilo del texto con un tamaño de fuente de 13 y color blanco
                                        ),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      primary: _isFollowed[cardId] ?? false
                                          ? const Color(0xFFC55E5E)
                                          : const Color(0xFFADE792),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        });
                  } else if (snapshot.hasError) {
                    return const Text('Error al cargar los favoritos');
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                })),
          ),
        ],
      ),
    );
  }
}
