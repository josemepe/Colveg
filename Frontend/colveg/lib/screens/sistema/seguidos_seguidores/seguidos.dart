//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 29/05/2005
//SENA-CBA 2023

// esta pantalla va a mostrar los seguidos de las personas y de uno

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
class SeguidosScreen extends StatefulWidget {
  const SeguidosScreen({super.key});

  @override
  State<SeguidosScreen> createState() => _SeguidosScreenState();
}

class _SeguidosScreenState extends State<SeguidosScreen> {
  //se crean variables de tipo final  para declararla
  final bool isFollowed = false;
  final int counter = 1;
  String userName = ' ';
  String imageUser = ' ';
  String idUser = ' ';

  //se crea un metodo get que me devuelve un mapeo  de forma asincrona
  Future<Map<String, dynamic>> getUserDrawer() async {
    //estos finals se utiliza para recuperar unos tokens de autenticacion almacenados en una url de una api de django
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    const url = 'http://127.0.0.1:8000/sitem/usuario/';

    //se crea una uri apartir de una url  la cual se hace una solicitud con el token para proporcionar la informacion
    final response = await http.get(
      Uri.parse(url),
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


  @override
  void initState() {
    super.initState();
    getSeguidos().then((data) {
      setState(() {
        listSeguidos = data;
      });
    });
        getUserDrawer().then((value) {
      setState(() {
        //se asignan a las variables userName e imageUser, que se utilizan para mostrar el nombre y la imagen del usuario
        userName = value['usuario']?[0]['user_name'];
        imageUser = value['usuario']?[0]['image_user'];
        idUser = value['usuario']?[0]['id'];
      });
    });
  }

  //Se define una función asincrónica llamada getSeguidos, que se utiliza para obtener una lista de seguidos.
  Future<List<dynamic>> getSeguidos() async {
    //Se obtiene una instancia de SharedPreferences utilizando el método getInstance. Luego,
    //se recupera el valor del token almacenado en SharedPreferences utilizando getString y se asigna a la variable token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    //Se crea una lista vacía llamada favorites para almacenar los favoritos.
    List<dynamic> listSeguidos = [];
    //Se realiza una solicitud HTTP GET a la URL especificada ('http://127.0.0.1:8000/sitem/favoritos/') con el token de autorización en los encabezados
    final response = await http.get(
      Uri.parse('$url/sitem/seguidos/'),
      headers: {'Authorization': '$token'},
    );
    //Se verifica si el código de estado de la respuesta es 200 (éxito). Si es así, se decodifica el cuerpo de la respuesta como un mapa (responseData) utilizando json.decode().
    //Luego, se verifica si responseData['favorites'] no es nulo y se asigna a la variable favorites
    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['follow_list'] != null) {
        listSeguidos = responseData['follow_list'];
      }
      print(responseData);

      return listSeguidos;
    } else {
      print('Falló la solicitud con estado ${response.statusCode}');
    }
    //Se muestra por consola el valor actual de favorites y se devuelve favorites
    print(listSeguidos);
    return listSeguidos;
  }

  //se crea un array
  List listSeguidos = [];

  //se crean variables de tipo final  para declararla
  final bool _isFollowing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      //AppBar se utiliza para representar la barra de la aplicación
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
                    imageUser,
                  ),
                  radius: 12,
                ),
              );
            },
          ),

          // Agregar un widget de título a la barra de aplicaciones
          title: Text(
            // Mostrar el nombre del usuario como título
            userName,
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

      //my drawer
      drawer: const MyDrawer(),

      //se crea una columna
      body: Column(
        children: [
          Container(
            color: const Color(0xFF344D67),
            height: 70,
            //se crea una fila
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Seguidos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  //IconButton representa un botón que muestra un icono
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyPerfilPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          //se crea una caja con el sixebox que nos haga un espacio
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder(
              future: getSeguidos(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: listSeguidos.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: const Color(0xFF344D67),
                        //se crea una fila
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
                              //se crea un hijo la cual contiene un circleavatar que tendra dentro una imagen que trae de la base de datos
                              child: CircleAvatar(
                                radius: 25.0,
                                backgroundImage: NetworkImage(
                                  listSeguidos[index]['image_user'],
                                ),
                              ),
                            ),

                            //se pone un texto
                            Text(
                              listSeguidos[index]['user_name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Expanded(
                              child: SizedBox(),
                            ),

                            //se crea un boton
                            ElevatedButton(
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final token = prefs.getString('token');
                                var follow = {
                                  'image_user': listSeguidos[index]
                                      ['image_user'],
                                  'user_name': listSeguidos[index]['user_name'],
                                  'user_id': listSeguidos[index]['user_id']
                                };

                                // Si ya se está siguiendo al usuario, eliminar la relación de seguimiento
                                var response = await http.delete(
                                  Uri.parse('$url/sitem/seguidos/'),
                                  headers: {'Authorization': '$token'},
                                  body: jsonEncode(follow),
                                );
                                if (response.statusCode == 201) {
                                  setState(() {
                                    listSeguidos.removeAt(index);
                                  });
                                }
                              },
                              //se crea una caja con el sixebox
                              child: SizedBox(
                                width: 100,
                                height: 40,
                                child: Center(
                                  child: Text(
                                    _isFollowing ? 'Dejar de seguir' : 'Seguir',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Color.fromARGB(255, 214, 93, 93),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error al cargar los favoritos');
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
