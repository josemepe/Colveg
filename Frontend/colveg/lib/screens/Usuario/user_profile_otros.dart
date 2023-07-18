//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 18/06/2005
//SENA-CBA 2023
//esta pantalla muestra los perfiles de las demas personas

//importaciones de codigo

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/reporte.dart';
import '../Producto/editarprodu.dart';
import '../menu_navegacion/drawer.dart';
import '../Usuario/perfil_mio.dart';
import '../sistema/guardados/guardados.dart';
import '../sistema/seguidos_seguidores/seguidores.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HisPerfilPage extends StatefulWidget {
  const HisPerfilPage({
    Key? key,
    required this.userName, // Nombre de usuario
    required this.imageUser, // Imagen de usuario
    required this.is_admin, // Indica si el usuario es administrador o no
  }) : super(key: key);

  final String userName; // Nombre de usuario
  final String imageUser; // Imagen de usuario
  final bool is_admin; // Indica si el usuario es administrador o no
  

  @override
  State<HisPerfilPage> createState() => _HisPerfilPageState();
}

// Clase de estado correspondiente al StatefulWidget
class _HisPerfilPageState extends State<HisPerfilPage> {
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

  Future<List<dynamic>> getMiProduc() async {
    // Obtener la instancia de SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Obtener el token almacenado en SharedPreferences
    final token = prefs.getString('token');

    // Crear listas vacías para almacenar los productos
    List<dynamic> produc = [];
    List<dynamic> miProduc = [];

    // Definir la URL del endpoint para obtener los productos
    var url = 'http://127.0.0.1:8000/produc/producto/';

    try {
      // Realizar una solicitud GET al servidor con el token en los encabezados
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': '$token'},
      );

      // Verificar si la respuesta del servidor tiene un código de estado 201 (éxito)
      if (response.statusCode == 201) {
        // Decodificar la respuesta JSON y obtener la lista de productos
        produc = jsonDecode(response.body)['produc'];

        // Filtrar la lista de productos para obtener solo los productos del autor especificado en widget.userName
        miProduc = produc
            .where((product) => product['author'] == widget.userName)
            .toList();

        // Imprimir la lista de productos filtrados
        print(miProduc);
      }
    } catch (e) {
      // Capturar y mostrar cualquier error ocurrido durante la solicitud
      print('Error: $e');
    }

    // Devolver la lista de productos filtrados
    return miProduc;
  }

  //  es una variable booleana que indica si se está siguiendo algo o alguien
  bool _isFollowing = false;
  // es una lista que contiene elementos
  List producMios = [];

  // Este mapa se utiliza para almacenar información sobre si un elemento ha sido marcado como "gustado" o no
  final Map<String, bool> _isLiked = {};
  // se utiliza para almacenar información sobre si un elemento ha sido guardado o no
  final Map<String, bool> _isSaved = {};
  // Este mapa se utiliza para almacenar información sobre el número de "me gusta" que ha recibido un elemento.
  final Map<String, num> numLikes = {};
  

  @override
  void initState() {
    super.initState();
    // _getIsFollowing para obtener un valor booleano que indica si el usuario está siguiendo algo o no
    _getIsFollowing().then((isFollowing) {
      setState(() {
        _isFollowing = isFollowing;
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


  Future<List<dynamic>> getSeguidos() async {
    // Obtener las preferencias compartidas
    final prefs = await SharedPreferences.getInstance();
    // Obtener el token almacenado en las preferencias compartidas
    final token = prefs.getString('token');
    // Crear una lista vacía para almacenar los seguidos
    List<dynamic> listSeguidos = [];
    // Realizar una solicitud HTTP GET para obtener los seguidos
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/sitem/seguidos/'),
      headers: {'Authorization': '$token'},
    );
    // Verificar si la solicitud fue exitosa (código de estado 201)
    if (response.statusCode == 201) {
      // Decodificar la respuesta en formato JSON
      final Map<String, dynamic> responseData = json.decode(response.body);
      // Verificar si la respuesta contiene una lista de seguidos
      if (responseData['follow_list'] != null) {
        // Asignar la lista de seguidos a la variable correspondiente
        listSeguidos = responseData['follow_list'];
      }
      // Imprimir los datos de la respuesta (para fines de depuración)
      print(responseData);

      // Devolver la lista de seguidos
      return listSeguidos;
    } else {
      // La solicitud no fue exitosa, imprimir el estado de la solicitud
      print('Falló la solicitud con estado ${response.statusCode}');
    }
    // Imprimir la lista de seguidos (puede estar vacía en caso de error)
    print(listSeguidos);
    // Devolver la lista de seguidos (puede estar vacía en caso de error)
    return listSeguidos;
  }

  Future<bool> _getIsFollowing() async {
    final seguidos =
        await getSeguidos(); // Obtener la lista de usuarios seguidos
    final follow = {
      'image_user': widget.imageUser, // Imagen del usuario actual
      'user_name': widget.userName, // Nombre de usuario actual
    };
    final isFollowing = seguidos.any((element) =>
        element['user_name'] ==
        follow[
            'user_name']); // Comprobar si el usuario actual está en la lista de seguidos
    return isFollowing; // Devolver el resultado
  }

  Future<void> actualizarSeguimiento() async {
    final prefs = await SharedPreferences
        .getInstance(); // Obtiene una instancia de SharedPreferences
    final token = prefs
        .getString('token'); // Obtiene el token guardado en SharedPreferences
    var url = 'http://127.0.0.1:8000/sitem/seguidos/'; // URL del endpoint

    var follow = {
      'image_user': widget.imageUser, // Imagen del usuario a seguir
      'user_name': widget.userName, // Nombre de usuario a seguir
    };

    if (_isFollowing) {
      // Si ya se está siguiendo al usuario
      var response = await http.delete(
        // Realiza una solicitud DELETE al servidor
        Uri.parse(url),
        headers: {
          'Authorization': '$token'
        }, // Incluye el token de autorización en los encabezados
        body: jsonEncode(
            follow), // Convierte el objeto follow a formato JSON y lo incluye en el cuerpo de la solicitud
      );

      if (response.statusCode == 201) {
        // Si la respuesta del servidor es exitosa (código 201)
        // _eliminarSeguidores(); // Lógica para eliminar seguidores
        setState(() {
          _isFollowing =
              false; // Actualiza el estado para indicar que ya no se está siguiendo
        });
      }
    } else {
      // Si no se está siguiendo al usuario
      var response = await http.post(
        // Realiza una solicitud POST al servidor
        Uri.parse(url),
        headers: {
          'Authorization': '$token'
        }, // Incluye el token de autorización en los encabezados
        body: jsonEncode(
            follow), // Convierte el objeto follow a formato JSON y lo incluye en el cuerpo de la solicitud
      );

      if (response.statusCode == 201) {
        // Si la respuesta del servidor es exitosa (código 201)
        // _agregarSeguidores(); // Lógica para agregar seguidores
        // _agregarSeguidoPerfilMio(); // Lógica para agregar el usuario seguido al perfil actual
        setState(() {
          _isFollowing =
              true; // Actualiza el estado para indicar que se está siguiendo
        });
      }
    }
  }

  //seguidos
  int _numSeguidos = 0;

  // agrega el seguidor

  // elimina seguidor
  void _eliminarSeguido() {
    setState(() {
      _numSeguidos--;
    });
  }

  //seguidores
  int _numSeguidores = 0;

  // agrega seguidores
  void _agregarSeguidores() {
    setState(() {
      _numSeguidores++;
    });
  }

  // elimina seguidores
  void _eliminarSeguidores() {
    setState(() {
      _numSeguidores--;
    });
  }

  //favoritos
  int _favoritos = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

      //MENU
      drawer: const MyDrawer(),

      body: Column(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                //se crea un hijo la cual contiene un circleavatar que tendra dentro una imagen que trae de la base de datos
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    widget.imageUser,
                  ),
                ),
                const SizedBox(height: 10),
                //se pone un texto
                Text(
                  widget.userName,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                //se crea un boton
                ElevatedButton(
                  onPressed: () {
                    actualizarSeguimiento();
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
                    primary: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                //se crea una fila
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        //se crea un texbutton para que sea el texto una especie de boton
                        child: TextButton(
                      onPressed: () {
                        //registro exitoso, navegar a la pantalla de inicio
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Seguidors(userName: widget.userName),
                          ),
                        );
                      },

                      //se crea una columna
                      child: Column(
                        children: [
                          //se pone un texto
                          Text(
                            _numSeguidores.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          const Text(
                            'Seguidores',
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    )),
                    Expanded(
                        //se crea un texbutton para que sea el texto una especie de boton
                        child: TextButton(
                      onPressed: () {},
                      //se crea una columna
                      child: Column(
                        children: [
                          //se pone un texto
                          Text(
                            _numSeguidos.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          const Text(
                            'Seguidos',
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    )),
                    Expanded(
                      //se crea un texbutton para que sea el texto una especie de boton
                      child: TextButton(
                        onPressed: () {},
                        //se crea una columna
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.message, color: Colors.black),
                            SizedBox(
                                width:
                                    8), // Añade un espacio entre el icono y el texto
                            //se pone un texto
                            Text(
                              'Contacto',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        //se crea un texbutton para que sea el texto una especie de boton
                        child: TextButton(
                      onPressed: () {},
                      //se crea una columna
                      child: Column(
                        children: [
                          //se pone un texto
                          Text(
                            _favoritos.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          //se pone un texto
                          const Text(
                            'Likes',
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 10),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: const Divider(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                SizedBox(
                  width: 900,
                  child: FutureBuilder<List<dynamic>>(
                      // se espera el producto para traer y llenar los campos
                      future: getMiProduc(),
                      builder: ((context, snapshot) {
                        if (snapshot.hasData) {
                          List<dynamic>? miProduc = snapshot.data;
                          producMios = miProduc!;

                          return ListView.builder(
                              itemCount: producMios.length,
                              // Método que construye cada elemento de la lista
                              itemBuilder: (context, index) {
                                final idProducMio = producMios[index][
                                    'id']; // Obtener el id del producto en la posición actual
                                final namAuthor = producMios[index][
                                    'author']; // Obtener el autor del producto en la posición actual
                                final namePublic = producMios[index][
                                    'name']; // Obtener el nombre del producto en la posición actual
                                DateTime fechaActual =
                                    DateTime.now(); // Obtener la fecha actual
                                final String fechaVencimiento = producMios[
                                        index][
                                    'fecha']; // Obtener la fecha de vencimiento del producto en la posición actual
                                DateFormat format = DateFormat(
                                    'yyyy-M-d'); // Crear un formato de fecha
                                DateTime fechaVencimientoObj = format.parse(
                                    fechaVencimiento); // Convertir la fecha de vencimiento en formato de cadena a un objeto DateTime
                                if (fechaVencimientoObj.isBefore(fechaActual)) {
                                  return const Text(' ');
                                } else {
                                  return SizedBox(
                                    width: 900,
                                    //se crea una carta
                                    child: Card(
                                        elevation: 2.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        //se crea una columna
                                        child: Column(
                                            mainAxisAlignment:
                                                //MainAxisAlignment se utiliza para alinear los widgets secundarios en el eje principal del contenedor.
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              //se crea una fila
                                              Row(
                                                children: <Widget>[
                                                  if (producMios[index]
                                                          ['author'] ==
                                                      widget.userName)
                                                    //se retorna un gesturedetector permite detectar diversos tipos de gestos táctiles realizados en la pantalla, como toques, arrastres, deslizamientos, etc
                                                    GestureDetector(
                                                        onTap: () {
                                                          //registro exitoso, navegar a la pantalla de inicio
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          const MyPerfilPage()));
                                                        },
                                                        // se utiliza en el diseño de interfaces gráficas para establecer un espacio de relleno alrededor de un widget
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10.0),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              //registro exitoso, navegar a la pantalla de inicio
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              const MyPerfilPage()));
                                                            },
                                                            // se utiliza en el diseño de interfaces gráficas para establecer un espacio de relleno alrededor de un widget
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .all(
                                                                      10.0),
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  //registro exitoso, navegar a la pantalla de inicio
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              const MyPerfilPage()));
                                                                },
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 25.0,
                                                                  backgroundImage:
                                                                      NetworkImage(
                                                                    producMios[
                                                                            index]
                                                                        [
                                                                        'image_user'],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )),
                                                  if (producMios[index]
                                                          ['author'] !=
                                                      widget.userName)
                                                    GestureDetector(
                                                      onTap: () {
                                                        //registro exitoso, navegar a la pantalla de inicio
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => HisPerfilPage(
                                                                    userName: producMios[
                                                                            index]
                                                                        [
                                                                        'author'],
                                                                    imageUser: producMios[
                                                                            index]
                                                                        [
                                                                        'image_user'],
                                                                    is_admin: widget
                                                                        .is_admin)));
                                                      },
                                                      // se utiliza en el diseño de interfaces gráficas para establecer un espacio de relleno alrededor de un widget
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        //se retorna un gesturedetector permite detectar diversos tipos de gestos táctiles realizados en la pantalla, como toques, arrastres, deslizamientos, etc
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            //registro exitoso, navegar a la pantalla de inicio
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => HisPerfilPage(
                                                                        userName: producMios[index]
                                                                            [
                                                                            'author'],
                                                                        imageUser:
                                                                            producMios[index][
                                                                                'image_user'],
                                                                        is_admin:
                                                                            widget.is_admin)));
                                                          },
                                                          //se crea un hijo la cual contiene un circleavatar que tendra dentro una imagen que trae de la base de datos
                                                          child: CircleAvatar(
                                                            radius: 25.0,
                                                            backgroundImage:
                                                                NetworkImage(
                                                              producMios[index][
                                                                  'image_user'],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  // se utiliza en el diseño de interfaces gráficas para establecer un espacio de relleno alrededor de un widget
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 5.0,
                                                      ),
                                                      //se pone un texto
                                                      child: Text(
                                                        producMios[index]
                                                            ['author'],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20.0,
                                                        ),
                                                      )),
                                                  const Spacer(),
                                                  PopupMenuButton<String>(
                                                    // Icon para el botón de menú emergente
                                                    icon: const Icon(
                                                      Icons.more_vert,
                                                      color: Colors.black,
                                                    ),
                                                    // Offset  de la posición del menú emergente
                                                    offset:
                                                        const Offset(-20, 30),
                                                    // Color de fondo del menú emergente
                                                    color: Colors.amber[50],
                                                    // Generador de elementos para el menú emergente
                                                    itemBuilder: (context) => [
                                                      // Elemento de menú emergente para editar (se muestra si el usuario es administrador)
                                                      if (widget.is_admin ==
                                                          true)
                                                        const PopupMenuItem(
                                                          value: 'edit',
                                                          child: Row(
                                                            children: <Widget>[
                                                              Icon(Icons.edit,
                                                                  color: Colors
                                                                      .amber),
                                                              SizedBox(
                                                                  width: 8.0),
                                                              Text('Editar'),
                                                            ],
                                                          ),
                                                        ),
                                                      // Elemento del menú emergente para eliminar (se muestra si el usuario es administrador)
                                                      if (widget.is_admin ==
                                                          true)
                                                        const PopupMenuItem(
                                                          value: 'delete',
                                                          child: Row(
                                                            children: <Widget>[
                                                              Icon(Icons.delete,
                                                                  color: Colors
                                                                      .red),
                                                              SizedBox(
                                                                  width: 8.0),
                                                              Text('Eliminar'),
                                                            ],
                                                          ),
                                                        ),
                                                      // Elemento de menú emergente para informes (se muestra si el usuario no es administrador o es administrador)
                                                      if (widget.is_admin ==
                                                              false ||
                                                          widget.is_admin ==
                                                              true)
                                                        const PopupMenuItem(
                                                          value: 'report',
                                                          child: Row(
                                                            children: <Widget>[
                                                              Icon(Icons.flag,
                                                                  color: Colors
                                                                      .red),
                                                              SizedBox(
                                                                  width: 8.0),
                                                              Text('Reportar'),
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                    // Función de devolución de llamada cuando se selecciona un elemento del menú
                                                    onSelected: (value) async {
                                                      // Manejar la opción de edición
                                                      if (value == 'edit') {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => EditPro(
                                                                editProducID:
                                                                    producMios[
                                                                            index]
                                                                        ['id']),
                                                          ),
                                                        );
                                                      }
                                                      // Maneja la opción de borrar
                                                      if (value == 'delete') {
                                                        final prefs =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        final token = prefs
                                                            .getString('token');
                                                        final id =
                                                            producMios[index]
                                                                ['id'];

                                                        // Enviar la solicitud de eliminación al servidor
                                                        final response =
                                                            await http.delete(
                                                          Uri.parse(
                                                              'http://127.0.0.1:8000/produc/delete/$id/'),
                                                          headers: {
                                                            'Authorization':
                                                                'Bearer $token',
                                                          },
                                                        );

                                                        // Comprobar si la solicitud de eliminación fue exitosa
                                                        if (response
                                                                .statusCode ==
                                                            201) {
                                                          setState(() {
                                                            producMios.removeAt(
                                                                index);
                                                          });
                                                        } else {
                                                          // Mostrar un mensaje de error si la solicitud de eliminación falló
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Error al registrar el usuario'),
                                                            ),
                                                          );
                                                        }
                                                      }
                                                      // Manejar la opción de informe
                                                      if (value == 'report') {
                                                        ReportUtils
                                                            .showReportOptions(
                                                          context,
                                                          idPublic: idProducMio,
                                                          nameAutor: namAuthor,
                                                          namePublic:
                                                              namePublic,
                                                        );
                                                      }
                                                    },
                                                  )
                                                ],
                                              ),
                                              //se crea una fila
                                              Row(
                                                children: <Widget>[
                                                  // se utiliza en el diseño de interfaces gráficas para establecer un espacio de relleno alrededor de un widget
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 5.0,
                                                      ),
                                                      //se pone un texto 
                                                      child: Text(
                                                        '#' +
                                                            producMios[index]
                                                                ['clasific'],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14.0,
                                                        ),
                                                      )),
                                                  // se utiliza en el diseño de interfaces gráficas para establecer un espacio de relleno alrededor de un widget    
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 5.0,
                                                      ),
                                                      //se pone un texto 
                                                      child: Text(
                                                        producMios[index]
                                                            ['name'],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12.0,
                                                        ),
                                                      )),
                                                ],
                                              ),
                                              //se crea una fila
                                              Row(
                                                children: <Widget>[
                                                  // se utiliza en el diseño de interfaces gráficas para establecer un espacio de relleno alrededor de un widget
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5.0,
                                                    ),
                                                    //se pone un texto 
                                                    child: Text(
                                                      'Precio:',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  // se utiliza en el diseño de interfaces gráficas para establecer un espacio de relleno alrededor de un widget
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5.0,
                                                    ),
                                                    child: Text(
                                                      producMios[index]['price']
                                                              .toString() +
                                                          "x" +
                                                          snapshot.data?[index]
                                                              ['unidad_peso'],
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14.0,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              //se crea una fila
                                              Row(
                                                children: <Widget>[
                                                  // se utiliza en el diseño de interfaces gráficas para establecer un espacio de relleno alrededor de un widget
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5.0,
                                                    ),
                                                    //se pone un texto 
                                                    child: Text(
                                                      'Dirección:',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  // se utiliza en el diseño de interfaces gráficas para establecer un espacio de relleno alrededor de un widget
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 5.0,
                                                      ),
                                                      //se pone un texto 
                                                      child: Text(
                                                        producMios[index]
                                                            ['direccion'],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12.0,
                                                        ),
                                                      )),
                                                ],
                                              ),
                                              //se crea una fila
                                              Row(
                                                children: <Widget>[
                                                  Flexible(
                                                    //se crea una columna 
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // se utiliza en el diseño de interfaces gráficas para establecer un espacio de relleno alrededor de un widget
                                                        const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            horizontal: 10.0,
                                                            vertical: 5.0,
                                                          ),
                                                          child: Text(
                                                            'Descripción:',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        // se utiliza en el diseño de interfaces gráficas para establecer un espacio de relleno alrededor de un widget
                                                        Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 10.0,
                                                              vertical: 5.0,
                                                            ),
                                                            child: Text(
                                                              producMios[index]
                                                                  ['descrip'],
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12.0,
                                                              ),
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              //se crea una fila
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      height: 200,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                0), // opcional
                                                        color: Colors.grey[
                                                            300], // opcional
                                                        shape:
                                                            BoxShape.rectangle,
                                                      ),
                                                      // Proporciona una forma conveniente de mostrar imágenes en red desde una URL mientras las almacena en caché 
                                                      child: CachedNetworkImage(
                                                        width: 300,
                                                        height: 300,
                                                        imageUrl:
                                                            producMios[index]
                                                                ['image'],
                                                        fit: BoxFit.cover,
                                                        placeholder: (context,
                                                                url) =>
                                                            const CircularProgressIndicator(),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              //se crea una fila
                                              Row(
                                                children: <Widget>[
                                                  const Spacer(flex: 1),
                                                  // se utiliza en el diseño de interfaces gráficas para establecer un espacio de relleno alrededor de un widget
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 0.0,
                                                      vertical: 5.0,
                                                    ),
                                                    //se pone un texto
                                                    child: Text(
                                                      'El siguiente producto expira el',
                                                    ),
                                                  ),
                                                  // se utiliza en el diseño de interfaces gráficas para establecer un espacio de relleno alrededor de un widget
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 5.0,
                                                      ),
                                                      //se pone un texto 
                                                      child: Text(
                                                        producMios[index]
                                                            ['fecha'],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12.0,
                                                        ),
                                                      )),
                                                ],
                                              ),
                                              //se crea una fila
                                              Row(
                                                children: <Widget>[
                                                  // se utiliza en el diseño de interfaces gráficas para establecer un espacio de relleno alrededor de un widget
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    //se pone un texto         
                                                    child: Text(
                                                      '${numLikes[idProducMio]} Likes',
                                                      // 'likes',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const Spacer(flex: 1),
                                                  // se utiliza en el diseño de interfaces gráficas para establecer un espacio de relleno alrededor de un widget
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 0.0,
                                                      vertical: 5.0,
                                                    ),
                                                    //se pone un texto 
                                                    child: Text(
                                                      'La cantidad en existencias es de ',
                                                    ),
                                                  ),
                                                  // se utiliza en el diseño de interfaces gráficas para establecer un espacio de relleno alrededor de un widget
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5.0,
                                                    ),
                                                    //se pone un texto 
                                                    child: Text(
                                                      producMios[index]['peso']
                                                              .toString() +
                                                          producMios[index]
                                                              ['unidad_peso'],
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14.0,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              // se utiliza en el diseño de interfaces gráficas para establecer un espacio de relleno alrededor de un widget
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 0),
                                                 //se crea una fila   
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        color: const Color(
                                                            0xFFF3ECB0),
                                                        //se crea una fila    
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            //IconButton representa un botón que muestra un icono
                                                            IconButton(
                                                              icon: Icon(
                                                                _isLiked[idProducMio] ??
                                                                        false
                                                                    ? Icons
                                                                        .thumb_up_alt
                                                                    : Icons
                                                                        .thumb_up_alt_outlined,
                                                                color: _isLiked[
                                                                            idProducMio] ??
                                                                        false
                                                                    ? Colors
                                                                        .blue
                                                                    : null,
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                final prefs =
                                                                    await SharedPreferences
                                                                        .getInstance();
                                                                final token = prefs
                                                                    .getString(
                                                                        'token');
                                                                final idProducMio =
                                                                    producMios[
                                                                            index]
                                                                        ['id'];
                                                                // enviar la información del registro al servidor
                                                                final response = _isLiked[
                                                                            idProducMio] ??
                                                                        false
                                                                    ? await http
                                                                        .delete(
                                                                        Uri.parse(
                                                                            'http://127.0.0.1:8000/sitem/likes/$idProducMio/'),
                                                                        headers: {
                                                                          'Authorization':
                                                                              '$token',
                                                                        },
                                                                      )
                                                                    : await http
                                                                        .post(
                                                                        Uri.parse(
                                                                            'http://127.0.0.1:8000/sitem/likes/$idProducMio/'),
                                                                        headers: {
                                                                          'Authorization':
                                                                              '$token',
                                                                        },
                                                                      );
                                                                if (response.statusCode ==
                                                                        200 ||
                                                                    response.statusCode ==
                                                                        201) {
                                                                  // Registro exitoso, actualizar _isLiked
                                                                  setState(() {
                                                                    _isLiked[
                                                                        idProducMio] = _isLiked[
                                                                            idProducMio] ??
                                                                        false;
                                                                    _isLiked[
                                                                            idProducMio] =
                                                                        !_isLiked[
                                                                            idProducMio]!;
                                                                    if (_isLiked[
                                                                        idProducMio]!) {
                                                                      numLikes[
                                                                              idProducMio] =
                                                                          (numLikes[idProducMio] ?? 0) +
                                                                              1;
                                                                    } else {
                                                                      numLikes[
                                                                              idProducMio] =
                                                                          (numLikes[idProducMio] ?? 0) -
                                                                              1;
                                                                    }
                                                                  });
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text(
                                                                          'Error al registrar el like'),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                            //IconButton representa un botón que muestra un icono
                                                            IconButton(
                                                              icon: const Icon(
                                                                  Icons.send),
                                                              onPressed: () {
                                                                setState(() {});
                                                              },
                                                            ),
                                                            //IconButton representa un botón que muestra un icono
                                                            IconButton(
                                                              icon: Icon(
                                                                _isSaved[idProducMio] ??
                                                                        false
                                                                    ? Icons
                                                                        .bookmark
                                                                    : Icons
                                                                        .bookmark_border,
                                                                color: _isSaved[
                                                                            idProducMio] ??
                                                                        false
                                                                    ? const Color
                                                                            .fromARGB(
                                                                        255,
                                                                        0,
                                                                        204,
                                                                        255)
                                                                    : null,
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                final prefs =
                                                                    await SharedPreferences
                                                                        .getInstance();
                                                                final token = prefs
                                                                    .getString(
                                                                        'token');
                                                                final response = _isSaved[
                                                                            idProducMio] ??
                                                                        false

                                                                    // enviar la información del registro al servidor
                                                                    ? await http
                                                                        .delete(
                                                                        Uri.parse(
                                                                            'http://127.0.0.1:8000/sitem/favoritos/$idProducMio/'),
                                                                        headers: {
                                                                          'Authorization':
                                                                              '$token'
                                                                        },
                                                                      )
                                                                    : await http
                                                                        .post(
                                                                        Uri.parse(
                                                                            'http://127.0.0.1:8000/sitem/favoritos/'),
                                                                        headers: {
                                                                          'Authorization':
                                                                              '$token',
                                                                        },
                                                                        body:
                                                                            jsonEncode({
                                                                          'image_user':
                                                                              producMios[index]['image_user'],
                                                                          'name':
                                                                              producMios[index]['name'],
                                                                          'author':
                                                                              producMios[index]['author'],
                                                                          'pk': producMios[index]
                                                                              [
                                                                              'id']
                                                                        }),
                                                                      );
                                                                if (response.statusCode ==
                                                                        200 ||
                                                                    response.statusCode ==
                                                                        201) {
                                                                  // registro exitoso, navegar a la pantalla de inicio
                                                                  setState(() {
                                                                    _isSaved[
                                                                        idProducMio] = _isSaved[
                                                                            idProducMio] ??
                                                                        false;
                                                                    _isSaved[
                                                                            idProducMio] =
                                                                        !_isSaved[
                                                                            idProducMio]!;
                                                                  });
                                                                } else {
                                                                  // ignore: use_build_context_synchronously
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text(
                                                                          'Esta publicacion ya se encuentra en favoritos'),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ])),
                                  );
                                }
                              });
                        } else if (snapshot.hasError) {
                          return const Text('Error al cargar los favoritos');
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      })),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
