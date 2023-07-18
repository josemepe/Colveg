//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 29/05/2005
//SENA-CBA 2023
//esta pantalla hace que se muestre mi perfil con mis seguidores,seguidos y mis publicaciones

//importaciones de codigo

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colveg/screens/Usuario/user_profile_otros.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/reporte.dart';
import '../Producto/editarprodu.dart';
import '../chat/bandeja_entrada.dart';
import '../menu_navegacion/drawer.dart';
import '../sistema/guardados/guardados.dart';
import '../sistema/notificaciones/notificaciones_general.dart';
import '../sistema/seguidos_seguidores/seguidores.dart';
import '../sistema/seguidos_seguidores/seguidos.dart';
import 'editperfil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';

// FirebaseFirestore db = FirebaseFirestore.instance;

// Future<String?> getUserNameperfilMio() async {
//   final prefs = await SharedPreferences.getInstance();
//   final token = prefs.getString('token');
//   CollectionReference collectionReferencePublic = db.collection('users');

//   QuerySnapshot queryUsers =
//       await collectionReferencePublic.where('token', isEqualTo: token).get();

//   if (queryUsers.docs.isNotEmpty) {
//     final user = queryUsers.docs.first;
//     return user.get('user_name');
//   } else {
//     return null;
//   }
// }
Future<Map<String, dynamic>> getUser() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  const url = 'http://127.0.0.1:8000/sitem/usuario/';

  final response = await http.get(
    Uri.parse(url),
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

class MyPerfilPage extends StatefulWidget {
  const MyPerfilPage({super.key});

  @override
  State<MyPerfilPage> createState() => _MyPerfilPageState();
}

class _MyPerfilPageState extends State<MyPerfilPage> {
  bool is_admin= false;
  String userName = ' ';
  String imageUser = ' ';
  String idUser = ' ';
  List producMios = [];

  DateTime fechaActual = DateTime.now();
  
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

  Future<List<dynamic>> getMiProduc() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    List<dynamic> produc = [];
    List<dynamic> miProduc = [];
    var url = 'http://127.0.0.1:8000/produc/producto/';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': '$token'},
      );

      if (response.statusCode == 201) {
        produc = jsonDecode(response.body)['produc'];
        miProduc =
            produc.where((product) => product['author'] == userName).toList();
        print(miProduc);
        // print(produc);
      }
    } catch (e) {
      print('Error: $e');
    }

    return miProduc;
  }

  final Map<String, bool> _isLiked = {};
  final Map<String, bool> _isSaved = {};
  final Map<String, num> numLikes = {};
  final bool isCommentSectionVisible = false;

  //seguidos
  int _numSeguidos = 0;

  void _agregarSeguidoPerfilMio() {
    setState(() {
      _numSeguidos++;
    });
  }

  void _eliminarSeguido() {
    setState(() {
      _numSeguidos--;
    });
  }

  //seguidores
  int _numSeguidores = 0;

  void _agregarSeguidores() {
    setState(() {
      _numSeguidores++;
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


        //cuerpo de la pagina
        body: Column(children: [
          FutureBuilder(
              future: getUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('User not found'));
                }
                return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                          imageUser,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userName,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '@' + userName,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditPerfil(),
                            ),
                          );
                        },
                        child: const SizedBox(
                          width: 100,
                          height: 40,
                          child: Center(
                            child: Text(
                              'Edita Perfil',
                              style: TextStyle(fontSize: 16),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Seguidors(userName: userName)),
                              );
                            },
                            child: Column(
                              children: [
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
                              child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SeguidosScreen()),
                              );
                            },
                            child: Column(
                              children: [
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
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BandejaEntrada()),
                                );
                              },
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.message, color: Colors.black),
                                  SizedBox(
                                      width:
                                          8), // Añade un espacio entre el icono y el texto
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 10),
                        child: const Divider(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          Expanded(
            child: Stack(
              children: [
                SizedBox(
                  width: 900,
                  child: FutureBuilder<List<dynamic>>(
                      future: getMiProduc(),
                      builder: ((context, snapshot) {
                        if (snapshot.hasData) {
                          List<dynamic>? miProduc = snapshot.data;
                          producMios = miProduc!;
                          return ListView.builder(
                              itemCount: producMios.length,
                              itemBuilder: (context, index) {
                                final idProducMio = producMios[index]['id'];
                                final namAuthor = producMios[index]['author'];
                                final namePublic = producMios[index]['name'];                                                        

                                final String fechaVencimiento = producMios[index]['fecha'];
                                DateFormat format = DateFormat('yyyy-M-d');
                                DateTime fechaVencimientoObj = format.parse(fechaVencimiento);

                                // if (fechaVencimientoObj.isBefore(fechaActual)) {
                                //   setState(() {
                                //     vencido = true;
                                //   });
                                // }
                                return SizedBox(
                                  width: 900,
                                  child: Card(
                                      elevation: 2.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Stack(
                                        children: <Widget>[ 
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  if (producMios[index]
                                                          ['author'] ==
                                                      userName)
                                                    GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          MyPerfilPage()));
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10.0),
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              MyPerfilPage()));
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10.0),
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder:
                                                                              (context) =>
                                                                                  MyPerfilPage()));
                                                                },
                                                                child:
                                                                    // CachedNetworkImage(
                                                                    //       imageUrl: snapshot.data?[index]['image_user'],
                                      
                                                                    //       placeholder: (context, url) => CircularProgressIndicator(),
                                                                    //       errorWidget: (context, url, error) => Icon(Icons.error),
                                                                    // ),
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
                                                      userName)
                                                    GestureDetector(
                                                      onTap: () {
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
                                                                    is_admin:
                                                                        is_admin)));
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                10.0),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => HisPerfilPage(
                                                                        userName:
                                                                            producMios[index]
                                                                                [
                                                                                'author'],
                                                                        imageUser:
                                                                            producMios[index]
                                                                                [
                                                                                'image_user'],
                                                                        is_admin:
                                                                            is_admin)));
                                                          },
                                                          child:
                                                              // CachedNetworkImage(
                                                              //       imageUrl: snapshot.data?[index]['image_user'],
                                      
                                                              //       placeholder: (context, url) => CircularProgressIndicator(),
                                                              //       errorWidget: (context, url, error) => Icon(Icons.error),
                                                              // ),
                                                              CircleAvatar(
                                                            radius: 25.0,
                                                            backgroundImage:
                                                                NetworkImage(
                                                              producMios[index]
                                                                  ['image_user'],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 5.0,
                                                      ),
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
                                                    icon: const Icon(
                                                      Icons.more_vert,
                                                      color: Colors.black,
                                                    ),
                                                    offset: const Offset(-20, 30),
                                                    color: Colors.amber[50],
                                                    itemBuilder: (context) => [
                                                      if (producMios[index]
                                                                  ['author'] ==
                                                              userName ||
                                                          is_admin == true)
                                                        PopupMenuItem(
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
                                                      if (producMios[index]
                                                                  ['author'] ==
                                                              userName ||
                                                          is_admin == true)
                                                        PopupMenuItem(
                                                          value: 'delete',
                                                          child: Row(
                                                            children: <Widget>[
                                                              Icon(Icons.delete,
                                                                  color:
                                                                      Colors.red),
                                                              SizedBox(
                                                                  width: 8.0),
                                                              Text('Eliminar'),
                                                            ],
                                                          ),
                                                        ),
                                                      if (producMios[index]
                                                                  ['author'] !=
                                                              userName ||
                                                          is_admin == true)
                                                        PopupMenuItem(
                                                          value: 'report',
                                                          child: Row(
                                                            children: <Widget>[
                                                              Icon(Icons.flag,
                                                                  color:
                                                                      Colors.red),
                                                              SizedBox(
                                                                  width: 8.0),
                                                              Text('Reportar'),
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                    onSelected: (value) async {
                                                      if (value == 'edit') {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => EditPro(
                                                                    editProducID:
                                                                        producMios[
                                                                                index]
                                                                            [
                                                                            'id'])));
                                                      }
                                                      if (value == 'delete') {
                                                        final prefs =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        final token = prefs
                                                            .getString('token');
                                      
                                                        final id =
                                                            producMios[index]
                                                                ['id'];
                                      
                                                        // enviar la información del registro al servidor
                                                        final response =
                                                            await http.delete(
                                                          Uri.parse(
                                                              'http://127.0.0.1:8000/produc/delete/$id/'),
                                                          headers: {
                                                            'Authorization':
                                                                'Bearer $token',
                                                          },
                                                        );
                                                        if (response.statusCode ==
                                                            201) {
                                                          setState(() {
                                                            producMios
                                                                .removeAt(index);
                                                          });
                                                          // registro exitoso, navegar a la pantalla de inicio
                                      
                                                          // Navigator.push(
                                                          //     context,
                                                          //     MaterialPageRoute(
                                                          //         builder: (context) => Inicio()));
                                                        } else {
                                                          // ignore: use_build_context_synchronously
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
                                                      if (value == 'report') {
                                                        ReportUtils
                                                            .showReportOptions(
                                                                context,
                                                                idPublic:
                                                                    idProducMio,
                                                                nameAutor:
                                                                    namAuthor,
                                                                namePublic:
                                                                    namePublic);
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 5.0,
                                                      ),
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
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 5.0,
                                                      ),
                                                      child: Text(
                                                        producMios[index]['name'],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12.0,
                                                        ),
                                                      )),
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  const Padding(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5.0,
                                                    ),
                                                    child: Text(
                                                      'Precio:',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
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
                                              Row(
                                                children: <Widget>[
                                                  const Padding(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5.0,
                                                    ),
                                                    child: Text(
                                                      'Dirección:',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 5.0,
                                                      ),
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
                                              Row(
                                                children: <Widget>[
                                                  Flexible(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
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
                                                                  FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
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
                                                        shape: BoxShape.rectangle,
                                                      ),
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
                                                        //   errorWidget:
                                                        //       (context, url, error) =>
                                                        //           const Icon(Icons.error),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  const Spacer(flex: 1),
                                                  const Padding(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 0.0,
                                                      vertical: 5.0,
                                                    ),
                                                    child: Text(
                                                      'El siguiente producto expira el',
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 5.0,
                                                      ),
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
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
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
                                                  const Padding(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 0.0,
                                                      vertical: 5.0,
                                                    ),
                                                    child: Text(
                                                      'La cantidad en existencias es de ',
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5.0,
                                                    ),
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
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 0),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        color: const Color(
                                                            0xFFF3ECB0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
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
                                                                    ? Colors.blue
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
                                                                final response =
                                                                    _isLiked[idProducMio] ??
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
                                                                            idProducMio] =
                                                                        _isLiked[
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
                                                                          (numLikes[idProducMio] ??
                                                                                  0) +
                                                                              1;
                                                                    } else {
                                                                      numLikes[
                                                                              idProducMio] =
                                                                          (numLikes[idProducMio] ??
                                                                                  0) -
                                                                              1;
                                                                    }
                                                                  });
                                                                } else {
                                                                  // Error al registrar el like
                                                                  // ignore: use_build_context_synchronously
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
                                                            //         IconButton(
                                                            //           icon: const Icon(
                                                            //               Icons.comment),
                                                            //           onPressed: () {
                                                            //             final id =
                                                            // producMios[index]['id'];
                                                            //             _toggleCommentSection(id);
                                                            //           },
                                                            //         ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                  Icons.send),
                                                              onPressed: () {
                                                                setState(() {
                                                                  // TODO
                                                                });
                                                              },
                                                            ),
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
                                                                          'name': producMios[index]
                                                                              [
                                                                              'name'],
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
                                                                            idProducMio] =
                                                                        _isSaved[
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
                                            ]),
                                        if(fechaVencimientoObj.isBefore(fechaActual))
                                          Positioned(
                                            top: 10.0,
                                            right: 10.0,
                                            child: Container(
                                              padding: const EdgeInsets.all(5.0),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.circular(5.0),
                                              ),
                                              child: const Text(
                                                'Producto vencido',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          )
                                      ]
                                      )
                                    ),
                                );
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
        ]));
  }
}
