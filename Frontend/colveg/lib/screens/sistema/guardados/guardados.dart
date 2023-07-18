//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 29/05/2023
//SENA-CBA 2023

// se muestra las publicaciones guardadas

//importaciones de codigo
import 'dart:convert';
import 'package:colveg/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constant/card.dart';
import '../../../main.dart';
import '../../menu_navegacion/drawer.dart';
import 'package:http/http.dart' as http;

//se trae la clase de tipo stateful para poder modificar agragar todo lo que queramos
class Guardados extends StatefulWidget {
  @override
  _GuardadosState createState() => _GuardadosState();
}

class _GuardadosState extends State<Guardados> {
  //se crea valores que pueden recibir valores nulos
  String? userName = ' ';
  String? imageUser = ' ';
  String idUser = ' ';

  //Se define una función asincrónica llamada getUser, que se utiliza para obtener los datos del usuario.
  Future<Map<String, dynamic>> getUser() async {
    //Se obtiene una instancia de SharedPreferences utilizando el método getInstance. Luego,
    //se recupera el valor del token almacenado en SharedPreferences utilizando getString y se asigna a la variable token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    //Se define la URL a la cual se realizará la solicitud GET para obtener los datos del usuario. La URL en este caso es 'http://127.0.0.1:8000/sitem/usuario/'

    //Se realiza una solicitud HTTP GET a la URL especificada utilizando el token de autorización en los encabezados. La respuesta se almacena en la variable response.
    final response = await http.get(
      Uri.parse('$url/sitem/usuario/'),
      headers: {'Authorization': '$token'},
    );

    //Se verifica si el código de estado de la respuesta es 201 (creado). Si es así,
    // se decodifica el cuerpo de la respuesta como un mapa (responseData) utilizando json.decode(). Luego, se imprime el mapa por consola y se devuelve.
    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      responseData['usuario'];
      print(responseData);
      return responseData;
      //Si el código de estado de la respuesta no es 201, se lanza una excepción con un mensaje de error indicando que ocurrió un error al obtener los datos del usuario
    } else {
      throw Exception('Error al obtener los datos del usuario');
    }
  }

  @override
  //El método initState() se llama automáticamente cuando el widget se inserta en el árbol de widgets y se inicializa. Aquí, se llama al método initState()
  void initState() {
    super.initState();
    //Se llama al método _getFavorites() que parece ser una función asincrónica definida en otro lugar. Esta función devuelve los favoritos relacionados con el usuario actual. El resultado de la función se recibe a través del parámetro data.
    //Luego, se actualiza el estado del widget llamando a setState() y asignando el valor de los favoritos a la variable favorites.
    _getFavorites().then((data) {
      setState(() {
        favorites = data;
      });
    });

    getUser().then((value) {
      setState(() {
        userName = value['usuario'][0]['user_name'];
        imageUser = value['usuario'][0]['image_user'];
        print(userName);
      });
    });
  }

  //Se define una función asincrónica llamada _getFavorites, que se utiliza para obtener una lista de favoritos.
  Future<List<dynamic>> _getFavorites() async {
    //Se obtiene una instancia de SharedPreferences utilizando el método getInstance.
    // Luego, se recupera el valor del token almacenado en SharedPreferences utilizando getString y se asigna a la variable token.
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    //Se crea una lista vacía llamada favorites para almacenar los favoritos.
    List<dynamic> favorites = [];
    //Se realiza una solicitud HTTP GET a la URL especificada ('http://127.0.0.1:8000/sitem/favoritos/') con el token de autorización en los encabezados.
    final response = await http.get(
      Uri.parse('$url/sitem/favoritos/'),
      headers: {'Authorization': '$token'},
    );
    //Se verifica si el código de estado de la respuesta es 200 (éxito). Si es así, se decodifica el cuerpo de la respuesta como un mapa (responseData) utilizando json.decode(). Luego, se verifica si responseData['favorites'] no es nulo y se asigna a la variable favorites
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['favorites'] != null) {
        favorites = responseData['favorites'];
      }
      print(responseData);

      return favorites;
    } else {
      print('Falló la solicitud con estado ${response.statusCode}');
    }
    //Se muestra por consola el valor actual de favorites y se devuelve favorites
    print(favorites);
    return favorites;
  }

  //se crea un array
  List favorites = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //AppBar se utiliza para representar la barra de la aplicación
        appBar: AppBar(
          backgroundColor: const Color(0xFFF3ECB0),
          //es una propiedad AppBar que se utiliza para mostrar  en el lado izquierdo
          leading: Builder(
            builder: (BuildContext context) {
              //se retorna un gesturedetector permite detectar diversos tipos de gestos táctiles realizados en la pantalla, como toques, arrastres, deslizamientos, etc
              return GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                //se crea un hijo la cual contiene un circleavatar que tendra dentro una imagen que trae de la base de datos
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    imageUser!,
                  ),
                  radius: 12,
                ),
              );
            },
          ),
          //se pone un texto
          title: Text(
            userName!,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            //IconButton representa un botón que muestra un icono
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
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    'Favoritos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Inicio()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          //se crea una caja con el sixebox que nos haga un espacio
          const SizedBox(height: 20),
          //se crea una fila
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('token');
                      http.delete(
                        Uri.parse(
                            '$url/sitem/delete_favoritos/'),
                        headers: {'Authorization': '$token'},
                      );
                      setState(() {
                        favorites.clear();
                      });
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Eliminar todo',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          //se crea una caja con el sixebox que nos haga un espacio
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder(
              future: _getFavorites(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final id = favorites[index]['pk'];
                      final name = favorites[index]['name'];  
                      //se crea una carta
                      return InkWell(
                        onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyCard(idProduc: id!, title: name,), // Pasar el 'id' a MyCard
                                ),
                              );
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => MyCard(idProduc: id!)), // Reemplaza 'DetalleScreen' con el nombre de tu pantalla de destino
                          // );
                        },
                        child: Card(
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
                                child: CircleAvatar(
                                  radius: 25.0,
                                  backgroundImage: NetworkImage(
                                    favorites[index]['image_user'],
                                  ),
                                ),
                              ),
                              //se crea una columna
                              Column(
                                children: [
                                  Text(
                                    favorites[index]['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  //se pone un texto
                      
                                  Text(
                                    favorites[index]['author'],
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
                              //IconButton representa un botón que muestra un icono
                              IconButton(
                                icon: const Icon(
                                  Icons
                                      .delete, // Icono de eliminar de Material Design
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  final token = prefs.getString('token');
                                  final id = snapshot.data?[index]['id'];
                                  http.delete(
                                    Uri.parse(
                                        '$url/sitem/favoritos/$id/'),
                                    headers: {'Authorization': '$token'},
                                  );
                                  setState(() {
                                    favorites.removeAt(index);
                                  });
                                },
                              )
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
              },
            ),
          )
        ]));
  }
}
