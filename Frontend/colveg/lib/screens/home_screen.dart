import 'dart:convert';
import 'package:colveg/screens/sistema/guardados/guardados.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constant/reporte.dart';
import '../main.dart';
import 'Producto/editarprodu.dart';
import 'Usuario/perfil_mio.dart';
import 'Usuario/user_profile_otros.dart';
import 'menu_navegacion/drawer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'home',
      home: InicioScreen(),
    );
  }
}

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreen();
}

class _InicioScreen extends State<InicioScreen> {
  late WebSocketChannel channel;
  late WebSocketChannel like;

  // variables para almacnear informacion del usuario
  String? userName = ' ';
  String userId = ' ';
  String? imageUser = ' ';
  bool is_admin = false;
  String? likes = ' ';
  List<dynamic> idLikes = [];
  String? idLike = ' ';
  String? idProductos = ' ';
  List<String> id_for_likes = [];
  // ---------------------------------------------------------
  
  // ignore: non_constant_identifier_names
  void ListenComment() {
    channel.stream.listen(
      (comment) {
        // Recibir el mensaje del canal
        final receivedMessage = jsonDecode(comment);
        print(receivedMessage);

        // Obtener el texto del mensaje
        final commentText = receivedMessage['comment'];
        // final senderId = receivedMessage['senderId'];
        // Actualizar la interfaz de usuario con el mensaje recibido

        setState(() {
          commentList.add(commentText);
        });
        print(commentText);
        print('mensaje recibido');
      },
      onError: (error) {
        print('Error en la conexión WebSocket: $error');
      },
    );
  }

  void ListenLike() {
    like.stream.listen((comment) {
      // Recibir el mensaje del canal
      final receivedMessage = jsonDecode(comment);
      print(receivedMessage);

      // Obtener el id y el número de likes del mensaje
      final idLike = receivedMessage['id'];
      final numLike = num.parse(receivedMessage['like']);

      // Actualizar la interfaz de usuario con el mensaje recibido
      setState(() {
        numLikes[idLike] = numLike;
      });

      print(idLike);
      print(numLike);
      print('mensaje recibido');
    }, onError: (error) {
      print('Error en la conexión WebSocket: $error');
    });
  }

// Future para traer informacion del usuario que inicio sesion
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
//  ------------------------------------------------------------------------

// Future para hacer la solicitud a la api traer el listado de productos
  Future<List<dynamic>> getProduc() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    List<dynamic> produc = [];
    try {
      final response = await http.get(
        Uri.parse('$url/produc/producto/'),
        headers: {'Authorization': '$token'},
      );

      if (response.statusCode == 201) {
        produc = jsonDecode(response.body)['produc'];
      }
    } catch (e) {
      print('Error: $e');
    }

    return produc;
  }
  // ------------------------------------------------------------------------

  // Funcion para obtener los comentarios de la publicacion
  Future<List> getComment(idCommentProduc) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    List comment = [];
    try {
      final response = await http.get(
        Uri.parse('$url/produc/comentario/$idCommentProduc/'),
        headers: {'Authorization': '$token'},
      );

      if (response.statusCode == 201) {
        comment = jsonDecode(response.body)['comment_list'];
      }
    } catch (e) {
      print('Error: $e');
    }

    return comment;
  }
  //  ------------------------------------------------------------------------

  // Funcion para traer las respuestas de los comentarios
  Future<List> getRespComment(idCommentProduc, idComment) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    List respoComment = [];

    try {
      final response = await http.get(
        Uri.parse('$url/produc/Respcomentario/$idCommentProduc/$idComment/'),
        headers: {'Authorization': '$token'},
      );

      if (response.statusCode == 201) {
        respoComment = jsonDecode(response.body)['comment_list'];
      }
    } catch (e) {
      print('Error: $e');
    }

    return respoComment;
  }
  //------------------------------------------------------------------------

  //Funcion para traer la collecion de favoritos
  Future<List<dynamic>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    List<dynamic> favorites = [];
    final response = await http.get(
      Uri.parse('$url/sitem/favoritos/'),
      headers: {'Authorization': '$token'},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['favorites'] != null) {
        favorites = responseData['favorites'];
      }

      return favorites;
    } else {
      print('Falló la solicitud con estado ${response.statusCode}');
    }
    return favorites;
  }
  //------------------------------------------------------------------------

  // se obtienen los likes de la publicaciones
  Future<List<Map<String, dynamic>>> getLikes(List<dynamic> producIds) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    List<Map<String, dynamic>> likesList = [];

    for (var idProducto in producIds) {
      final response = await http.get(
        Uri.parse('$url/sitem/likes/$idProducto/'),
        headers: {'Authorization': '$token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        likesList.add(responseData);
      } else {
        throw Exception('Error al obtener los likes');
      }
    }

    return likesList;
  }
  //--------------------------------------------------------------------------

  // Listas para almacenar los comentrios, respuesta de comentarios, listado de publicaciones
  List commentList = [];
  List respCommentList = [];
  List listProduc = [];

  final Map<String, bool> _isSaved = {};
  // List<bool> _isLiked = [];
  final Map<String, bool> _isLiked = {};
  final Map<String, num> numLikes = {};
  String? idFavorito;

  String? favoritos;

  @override
  void initState() {
    super.initState();
    // obtener la informacion del usurio y al macenarlas en variables globales para su posterior uso
    getUser().then((value) {
      setState(() {
        userName = value['usuario'][0]['user_name'];
        imageUser = value['usuario'][0]['image_user'];
        userId = value['usuario'][0]['id'];
        is_admin = value['usuario'][0]['is_admin'];
        print(userName);
      });
      //------------------------------------------------------------------------

      // obtener los comentarios y almacenarlos en la lista commentList "se requiere 1 parametro el id de la publicacion"
      getComment(idCommentProduc).then((data) {
        setState(() {
          commentList = data;
        });
      });

      //------------------------------------------------------------------------

      // obtener respuesta de comentarios para almacenarlos en la lista respCommentList "se requieren 2 parametros el id de la publicacion y el id del comentarios"
      getRespComment(idCommentProduc, idComment).then((data) {
        setState(() {
          respCommentList = data;
        });
      });
      //------------------------------------------------------------------------

      // obtener las publicaciones para almacenarlas en la lista listProduc
      getProduc().then((produc) {
        listProduc = produc;
        produc.asMap().forEach((index, product) {
          // se almacena el id de la publicacion en productId para su posterior uso
          final String productId = product['id'];
          List<String> producIds = [productId];

          // obtener los likes de las publicaciones"se requiere 1 parametro el id de la publicacion"
          getLikes(producIds).then((likesList) {
            if (likesList.isEmpty) {
            } else {
              bool isProductLiked = false;

              likesList.forEach((likesData) {
                final productLikes = likesData['Likes'];
                numLikes[productId] = productLikes.length;
                // recorremos la lista de likes en busqueda del id del usuario que dio like si esa condicion se cumple el boton de likes se marca en color azul
                isProductLiked =
                    productLikes.any((like) => like['id_user_like'] == userId);
                if (isProductLiked) {
                  setState(() {
                    _isLiked[productId] = true;
                  });
                }
              });

              if (isProductLiked) {
                print(
                    'El usuario $userId ha dado like a la publicación $productId');
              } else {}
            }
          });

          // se obtiene el listado de favoritos
          getFavorites().then((value) {
            if (value.isNotEmpty) {
              List favoritos = value.map((item) => item['pk']).toList();
              idFavorito = value[0]['id'];
              favoritos.forEach((productId) {
                setState(() {
                  _isSaved[productId] = true;
                });
              });
            } else {
              print('The array is empty');
            }
          });
        });
      });
    });
  }

  @override
  void dispose() {
    like.sink.close();
    // receptor.sink.close();
    super.dispose();
  }

  bool _isCommentSectionVisible = false;
  String? idCommentProduc;
  String? idComment;
  String? idLikstProduc;
  String searchData = ' ';

  // se obtienen los resultados de la busqueda
  Future<void> search() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$url/sitem/search/$searchData/'),
      headers: {'Authorization': '$token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['search'] != null) {
        setState(() {
          listProduc = responseData['search'];
        });
        print(responseData);
      } else {
        const Center(
            child: Text("No se an encontrado resultados para la busqueda"));
      }

      // setState(() {
      //   listProduc = responseData;
      // });
    } else {
      throw Exception('Error al obtener los datos de búsqueda');
    }
  }
  //-------------------------------------------------------------------------

  // funcion para mostrar los comentarios "re quiere como parametro el id de la ublicacion"
  void _toggleCommentSection(idProduc) {
    setState(() {
      idCommentProduc = idProduc;
      _isCommentSectionVisible = !_isCommentSectionVisible;
    });
  }

  // widget para mostarr los comentarios y las respuetas de los mismo
  Widget _buildCommentSection() {
    final comment = TextEditingController();
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final sectionHeight = screenHeight * 0.8; // 80% de la altura de la pantalla
    channel = WebSocketChannel.connect(
        Uri.parse('ws://$webSocket/ws/chat/comment/$idCommentProduc/'));

    ListenComment();

    // funcion para mostrar la respueta de comenatrios
    void showBottomSheet(idProduc, idComment) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Positioned(
              left: 0.0,
              right: 0.0,
              height: sectionHeight,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                color: const Color(0xFF344D67),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 25),
                      color: const Color.fromARGB(255, 77, 113, 151),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Respuestas:",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder(
                        future: getRespComment(idCommentProduc, idComment),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                                itemCount: snapshot.data?.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20.0,
                                          backgroundImage: NetworkImage(snapshot
                                                  .data?[index]['user_image'] ??
                                              ''),
                                        ),
                                        const SizedBox(width: 10.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                snapshot.data?[index]
                                                        ['author'] ??
                                                    '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 5.0),
                                              Text(
                                                snapshot.data?[index]
                                                        ['comentario'] ??
                                                    '',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            if (snapshot.data?[index]
                                                    ['author'] ==
                                                userName)
                                              PopupMenuButton<String>(
                                                icon: const Icon(
                                                  Icons.more_vert,
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                ),
                                                offset: const Offset(-20, 30),
                                                color: Colors.amber[50],
                                                itemBuilder: (context) => [
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(Icons.delete,
                                                            color: Colors.red),
                                                        SizedBox(width: 8.0),
                                                        Text('Eliminar'),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                                onSelected: (value) async {
                                                  if (value == 'delete') {
                                                    final prefs =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    final token = prefs
                                                        .getString('token');

                                                    // enviar la información del registro al servidor
                                                    final response =
                                                        await http.delete(
                                                            Uri.parse(
                                                                'http://127.0.0.1:8000/produc/Respcomentario/$idCommentProduc/$idComment/'),
                                                            headers: {
                                                              'Authorization':
                                                                  '$token',
                                                            },
                                                            body: jsonEncode(
                                                              {
                                                                'comentario': snapshot
                                                                            .data?[
                                                                        index][
                                                                    'comentario'],
                                                              },
                                                            ));
                                                    if (response.statusCode ==
                                                        201) {
                                                      setState(() {
                                                        snapshot.data
                                                            ?.removeAt(index);
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
                                                },
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          } else if (snapshot.hasError) {
                            return const Center(
                                child: Text('Error al cargar los favoritos'));
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 25),
                      color: const Color.fromARGB(255, 77, 113, 151),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              height: 40, // Agregar el alto de 20
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              child: TextFormField(
                                controller: comment,
                                decoration: const InputDecoration(
                                  hintText: 'Agregar comentario',
                                  hintStyle: TextStyle(
                                    color: Colors.black54,
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () async {
                              // channel.sink.add(jsonEncode({
                              //   'comment': comment.text,
                              // }));
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final token = prefs.getString('token');
                              // enviar la información del registro al servidor
                              final response = await http.post(
                                  Uri.parse(
                                      'http://127.0.0.1:8000/produc/Respcomentario/$idCommentProduc/$idComment/'),
                                  headers: {
                                    'Authorization': '$token',
                                  },
                                  body: jsonEncode(
                                    {
                                      'comentario': comment.text,
                                    },
                                  ));
                              if (response.statusCode == 201) {
                                // registro exitoso, navegar a la pantalla de inicio

                                setState(() {
                                  respCommentList.add(comment);
                                });
                              } else {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Error al registrar el usuario'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
        },
      );
    }
    // ----------------------------------------------------------------------------

    // funcio para mostarr los comentarios
    return Positioned(
      bottom: _isCommentSectionVisible ? 0.0 : -sectionHeight,
      left: 0.0,
      right: 0.0,
      height: sectionHeight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        color: const Color(0xFF344D67),
        child: Column(
          children: [
            IconButton(
              onPressed: () {
                channel.sink.close();
                setState(() {
                  _isCommentSectionVisible = false;
                });
              },
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isLiked[idCommentProduc] ?? false
                              ? Icons.thumb_up_alt
                              : Icons.thumb_up_alt_outlined,
                          color: _isLiked[idCommentProduc] ?? false
                              ? Colors.blue
                              : Colors.white,
                        ),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final token = prefs.getString('token');
                          // final idProduc = snapshot.data?[index]['id'];
                          // enviar la información del registro al servidor
                          final response = _isLiked[idCommentProduc] ?? false
                              ? await http.delete(
                                  Uri.parse(
                                      '$url/sitem/likes/$idCommentProduc/'),
                                  headers: {
                                    'Authorization': '$token',
                                  },
                                )
                              : await http.post(
                                  Uri.parse(
                                      '$url/sitem/likes/$idCommentProduc/'),
                                  headers: {
                                    'Authorization': '$token',
                                  },
                                );
                          if (response.statusCode == 200 ||
                              response.statusCode == 201) {
                            // Registro exitoso, actualizar _isLiked
                            setState(() {
                              String idlikeComment = idCommentProduc!;
                              _isLiked[idlikeComment] =
                                  _isLiked[idCommentProduc] ?? false;
                              _isLiked[idlikeComment] =
                                  !_isLiked[idCommentProduc]!;
                              if (_isLiked[idCommentProduc]!) {
                                numLikes[idlikeComment] =
                                    (numLikes[idCommentProduc] ?? 0) + 1;
                              } else {
                                numLikes[idlikeComment] =
                                    (numLikes[idCommentProduc] ?? 0) - 1;
                              }
                            });
                          } else {
                            // Error al registrar el like
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error al registrar el like'),
                              ),
                            );
                          }
                        },
                      ),
                      Text(
                        '${numLikes[idCommentProduc]} Likes',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 100.0),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.white,
                      thickness: 1.0,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'Comentarios',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.white,
                      thickness: 1.0,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
                child: FutureBuilder(
                    future: getComment(idCommentProduc),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            itemCount: snapshot.data?.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 10.0),
                                  child: Row(children: [
                                    CircleAvatar(
                                      radius: 20.0,
                                      backgroundImage: NetworkImage(
                                          snapshot.data?[index]['user_image']),
                                    ),
                                    const SizedBox(width: 10.0),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  snapshot.data?[index]
                                                      ['author'],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 5.0),
                                                Text(
                                                  snapshot.data?[index]
                                                      ['comentario'],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        final idComment =
                                                            snapshot.data?[
                                                                index]['id'];
                                                        showBottomSheet(
                                                            idCommentProduc,
                                                            idComment);
                                                      },
                                                      child: const Text(
                                                        'Respuestas',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (snapshot.data?[index]['author'] ==
                                            userName)
                                          PopupMenuButton<String>(
                                            icon: const Icon(
                                              Icons.more_vert,
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                            ),
                                            offset: const Offset(-20, 30),
                                            color: Colors.amber[50],
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: <Widget>[
                                                    Icon(Icons.delete,
                                                        color: Colors.red),
                                                    SizedBox(width: 8.0),
                                                    Text('Eliminar'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            onSelected: (value) async {
                                              if (value == 'delete') {
                                                final prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                final token =
                                                    prefs.getString('token');

                                                // enviar la información del registro al servidor
                                                final response = await http.delete(
                                                    Uri.parse(
                                                        '$url/produc/comentario/$idCommentProduc/'),
                                                    headers: {
                                                      'Authorization': '$token',
                                                    },
                                                    body: jsonEncode(
                                                      {
                                                        'comentario': snapshot
                                                                .data?[index]
                                                            ['comentario'],
                                                      },
                                                    ));
                                                if (response.statusCode ==
                                                    201) {
                                                  setState(() {
                                                    snapshot.data
                                                        ?.removeAt(index);
                                                  });
                                                  // registro exitoso, navegar a la pantalla de inicio

                                                  // Navigator.push(
                                                  //     context,
                                                  //     MaterialPageRoute(
                                                  //         builder: (context) => Inicio()));
                                                } else {
                                                  // ignore: use_build_context_synchronously
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Error al registrar el usuario'),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                      ],
                                    ),
                                  ]));
                            });
                      } else if (snapshot.hasError) {
                        return const Text('Error al cargar los favoritos');
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    })),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              color: const Color.fromARGB(255, 77, 113, 151),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      height: 40, // Agregar el alto de 20
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      child: TextFormField(
                        controller: comment,
                        decoration: const InputDecoration(
                          hintText: 'Agregar comentario',
                          hintStyle: TextStyle(
                            color: Colors.black54,
                          ),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('token');
                      channel.sink.add(jsonEncode({
                        'comment': comment.text,
                      }));
                      // enviar la información del registro al servidor
                      final response = await http.post(
                          Uri.parse('$url/produc/comentario/$idCommentProduc/'),
                          headers: {
                            'Authorization': '$token',
                          },
                          body: jsonEncode(
                            {
                              'comentario': comment.text,
                            },
                          ));
                      if (response.statusCode == 201) {
                        // registro exitoso, navegar a la pantalla de inicio

                        setState(() {
                          commentList.add(comment);
                        });
                      } else {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error al registrar el usuario'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )

// Aquí puedes colocar los elementos que quieras mostrar en tu sección de comentarios
          ],
        ),
      ),
    );
    // ----------------------------------------------------------------------------
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3ECB0),
        leading: Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  imageUser!,
                ),
                radius: 12,
              ),
            );
          },
        ),
        title: Text(
          userName!,
          style: const TextStyle(
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

      //Menu de naveacion
      drawer: MyDrawer(),
      body: Center(
        child: Column(children: [
          const SizedBox(height: 13),
          // Se usa una variable searchData para hacer la solicitud a la pai para buscar la publicacion
          Container(
            width: 1100,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) {
                setState(() {
                  searchData = value;
                });
                search();
              },
            ),
          ),
          const SizedBox(height: 13),
          Expanded(
            child: Stack(children: [
              SizedBox(
                width: 1100,
                child: FutureBuilder(
                  future: getProduc(),
                  builder: ((context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: listProduc.length,
                        itemBuilder: (context, index) {
                          DateTime fechaActual = DateTime.now();
                          final String fechaVencimiento =
                              listProduc[index]['fecha'];
                          DateFormat format = DateFormat('yyyy-M-d');
                          DateTime fechaVencimientoObj =
                              format.parse(fechaVencimiento);
                          final idProduc = listProduc[index]['id'];
                          final namAuthor = listProduc[index]['author'];
                          final namePublic = listProduc[index]['name'];
                          like = WebSocketChannel.connect(Uri.parse(
                              'ws://$webSocket/ws/chat/post/$idProduc/'));

                          ListenLike();
                          if (fechaVencimientoObj.isBefore(fechaActual)) {
                            return const Text(' ');
                          } else {
                            return Card(
                                elevation: 2.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          if (listProduc[index]['author'] ==
                                              userName)
                                            GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              MyPerfilPage()));
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  MyPerfilPage()));
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
                                                                  builder:
                                                                      (context) =>
                                                                          MyPerfilPage()));
                                                        },
                                                        child: CircleAvatar(
                                                          radius: 25.0,
                                                          backgroundImage:
                                                              NetworkImage(
                                                            listProduc[index]
                                                                ['image_user'],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )),
                                          if (listProduc[index]['author'] !=
                                              userName)
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            HisPerfilPage(
                                                                userName:
                                                                    listProduc[
                                                                            index]
                                                                        [
                                                                        'author'],
                                                                imageUser: listProduc[
                                                                        index][
                                                                    'image_user'],
                                                                is_admin:
                                                                    is_admin)));
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => HisPerfilPage(
                                                                userName:
                                                                    listProduc[
                                                                            index]
                                                                        [
                                                                        'author'],
                                                                imageUser: listProduc[
                                                                        index][
                                                                    'image_user'],
                                                                is_admin:
                                                                    is_admin)));
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 25.0,
                                                    backgroundImage:
                                                        NetworkImage(
                                                      listProduc[index]
                                                          ['image_user'],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                                vertical: 5.0,
                                              ),
                                              child: Text(
                                                listProduc[index]['author'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
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
                                              if (listProduc[index]['author'] ==
                                                      userName ||
                                                  is_admin == true)
                                                PopupMenuItem(
                                                  value: 'edit',
                                                  child: Row(
                                                    children: <Widget>[
                                                      Icon(Icons.edit,
                                                          color: Colors.amber),
                                                      SizedBox(width: 8.0),
                                                      Text('Editar'),
                                                    ],
                                                  ),
                                                ),
                                              if (listProduc[index]['author'] ==
                                                      userName ||
                                                  is_admin == true)
                                                PopupMenuItem(
                                                  value: 'delete',
                                                  child: Row(
                                                    children: <Widget>[
                                                      Icon(Icons.delete,
                                                          color: Colors.red),
                                                      SizedBox(width: 8.0),
                                                      Text('Eliminar'),
                                                    ],
                                                  ),
                                                ),
                                              if (listProduc[index]['author'] !=
                                                      userName ||
                                                  is_admin == true)
                                                PopupMenuItem(
                                                  value: 'report',
                                                  child: Row(
                                                    children: <Widget>[
                                                      Icon(Icons.flag,
                                                          color: Colors.red),
                                                      SizedBox(width: 8.0),
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
                                                        builder: (context) =>
                                                            EditPro(
                                                                editProducID:
                                                                    listProduc[
                                                                            index]
                                                                        [
                                                                        'id'])));
                                              }
                                              if (value == 'delete') {
                                                final prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                final token =
                                                    prefs.getString('token');

                                                final id =
                                                    listProduc[index]['id'];

                                                // enviar la información del registro al servidor
                                                final response =
                                                    await http.delete(
                                                  Uri.parse(
                                                      '$url/produc/delete/$id/'),
                                                  headers: {
                                                    'Authorization':
                                                        'Bearer $token',
                                                  },
                                                );
                                                if (response.statusCode ==
                                                    201) {
                                                  setState(() {
                                                    listProduc.removeAt(index);
                                                  });
                                                } else {
                                                  // ignore: use_build_context_synchronously
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Error al registrar el usuario'),
                                                    ),
                                                  );
                                                }
                                              }
                                              if (value == 'report') {
                                                ReportUtils.showReportOptions(
                                                    context,
                                                    idPublic: idProduc,
                                                    nameAutor: namAuthor,
                                                    namePublic: namePublic);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                                vertical: 5.0,
                                              ),
                                              child: Text(
                                                '#' +
                                                    listProduc[index]
                                                        ['clasific'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.0,
                                                ),
                                              )),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                                vertical: 5.0,
                                              ),
                                              child: Text(
                                                listProduc[index]['name'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
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
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0,
                                              vertical: 5.0,
                                            ),
                                            child: Text(
                                              listProduc[index]['price']
                                                      .toString() +
                                                  "x" +
                                                  snapshot.data?[index]
                                                      ['unidad_peso'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
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
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 5.0,
        ),
        child: AutoSizeText(
          listProduc[index]['direccion'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.0,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          minFontSize: 8.0,
          maxFontSize: 12.0,
        ),
      ),
    ),
  ],
),


                                      Row(
                                        children: <Widget>[
                                          Wrap(
                                            direction: Axis
                                                .vertical, // Cambiado a Axis.vertical
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 10.0,
                                                  vertical: 5.0,
                                                ),
                                                child: Text(
                                                  'Descripción:',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 10.0,
                                                  vertical: 5.0,
                                                ),
                                                child: Text(
                                                  listProduc[index]['descrip'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12.0,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              color: Colors.grey[300],
                                              child: Center(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0), // opcional
                                                    color: Colors
                                                        .grey[300], // opcional
                                                    shape: BoxShape.rectangle,
                                                  ),
                                                  child: CachedNetworkImage(
                                                    width: 400,
                                                    height: 200,
                                                    imageUrl: listProduc[index]
                                                        ['image'],
                                                    fit: BoxFit.cover,
                                                    placeholder: (context,
                                                            url) =>
                                                        const CircularProgressIndicator(),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        const Icon(Icons.error),
                                                  ),
                                                ),
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                                vertical: 5.0,
                                              ),
                                              child: Text(
                                                listProduc[index]['fecha'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12.0,
                                                ),
                                              )),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Text(
                                              '${numLikes[idProduc]} Likes',
                                              // 'likes',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
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
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0,
                                              vertical: 5.0,
                                            ),
                                            child: Text(
                                              listProduc[index]['peso']
                                                      .toString() + ' ' +
                                                  listProduc[index]
                                                      ['unidad_peso'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                color: const Color(0xFFF3ECB0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    IconButton(
                                                      icon: Icon(
                                                        _isLiked[idProduc] ??
                                                                false
                                                            ? Icons.thumb_up_alt
                                                            : Icons
                                                                .thumb_up_alt_outlined,
                                                        color: _isLiked[
                                                                    idProduc] ??
                                                                false
                                                            ? Colors.blue
                                                            : null,
                                                      ),
                                                      onPressed: () async {
                                                        final prefs =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        final token = prefs
                                                            .getString('token');
                                                        final idProduc =
                                                            listProduc[index]
                                                                ['id'];
                                                        // enviar la información del registro al servidor

                                                        final response =
                                                            _isLiked[idProduc] ??
                                                                    false
                                                                ? await http
                                                                    .delete(
                                                                    Uri.parse(
                                                                        '$url/sitem/likes/$idProduc/'),
                                                                    headers: {
                                                                      'Authorization':
                                                                          '$token',
                                                                    },
                                                                  )
                                                                : await http
                                                                    .post(
                                                                    Uri.parse(
                                                                        '$url/sitem/likes/$idProduc/'),
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
                                                            _isLiked[idProduc] =
                                                                _isLiked[
                                                                        idProduc] ??
                                                                    false;
                                                            _isLiked[idProduc] =
                                                                !_isLiked[
                                                                    idProduc]!;
                                                            if (_isLiked[
                                                                idProduc]!) {
                                                              final likeCount =
                                                                  numLikes[
                                                                          idProduc]! +
                                                                      1;

                                                              like.sink.add(
                                                                  jsonEncode({
                                                                'id':
                                                                    '$idProduc',
                                                                'like':
                                                                    '$likeCount',
                                                              }));
                                                              numLikes[
                                                                      idProduc] =
                                                                  (numLikes[idProduc] ??
                                                                          0) +
                                                                      1;
                                                            } else {
                                                              final likeCount =
                                                                  numLikes[
                                                                          idProduc]! -
                                                                      1;

                                                              like.sink.add(
                                                                  jsonEncode({
                                                                'id':
                                                                    '$idProduc',
                                                                'like':
                                                                    '$likeCount',
                                                              }));
                                                              numLikes[
                                                                      idProduc] =
                                                                  (numLikes[idProduc] ??
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
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.comment),
                                                      onPressed: () {
                                                        final id =
                                                            listProduc[index]
                                                                ['id'];
                                                        // pasamos como parametro el id de la publicacion para mostrar la secci0on de comenayrios dde cada publicacion
                                                        _toggleCommentSection(
                                                            id);
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.send),
                                                      onPressed: () async {
                                                        final prefs =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        final token = prefs
                                                            .getString('token');
                                                        // enviar la información del registro al servidor
                                                        final response =
                                                            await http.post(
                                                          Uri.parse(
                                                              '$url/chat/chat/'),
                                                          headers: {
                                                            'Authorization':
                                                                '$token',
                                                          },
                                                          body: jsonEncode({
                                                            'receptor':
                                                                listProduc[
                                                                        index]
                                                                    ['author'],
                                                            'image_receptor':
                                                                listProduc[
                                                                        index][
                                                                    'image_user'],
                                                            'tokenMensajes':
                                                                listProduc[
                                                                        index][
                                                                    'tockenMensajes'],
                                                          }),
                                                        );
                                                        if (response.statusCode ==
                                                                200 ||
                                                            response.statusCode ==
                                                                201) {
                                                          // registro exitoso, navegar a la pantalla de inicio
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'chat creado'),
                                                            ),
                                                          );
                                                        } else {
                                                          // ignore: use_build_context_synchronously
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'no es posible crear el chat'),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons
                                                          .local_grocery_store_outlined),
                                                      onPressed: () {
                                                        
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              var numPedido =
                                                                  TextEditingController();
                                                              String min = '1';
                                                              return AlertDialog(
                                                                title: Text(
                                                                    'Digite la cantidad de ${listProduc[index]['unidad_peso']} que deseas ordenar'),
                                                                content:
                                                                    Container(
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            TextField(
                                                                          controller:
                                                                              numPedido,
                                                                          keyboardType:
                                                                              TextInputType.number,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            labelText:
                                                                                'Ingrese un número',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      TextButton(
                                                                        child: const Text(
                                                                            'min'),
                                                                        onPressed:
                                                                            () {
                                                                          // Lógica para incrementar el número
                                                                          setState(
                                                                              () {
                                                                            numPedido.text =
                                                                                min;
                                                                          });
                                                                        },
                                                                      ),
                                                                      TextButton(
                                                                        child: const Text(
                                                                            'Max'),
                                                                        onPressed:
                                                                            () {
                                                                          final max =
                                                                              listProduc[index]['peso'].toString();
                                                                          // Lógica para incrementar el número
                                                                          setState(
                                                                              () {
                                                                            numPedido.text =
                                                                                max;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                actions: <Widget>[
                                                                  TextButton(
                                                                    child: const Text(
                                                                        'Aceptar'),
                                                                    onPressed:
                                                                        () async {
                                                                      final prefs =
                                                                          await SharedPreferences
                                                                              .getInstance();
                                                                      final token =
                                                                          prefs.getString(
                                                                              'token');
                                                                      print(
                                                                          token);

                                                                      final pedido =
                                                                          int.parse(
                                                                              numPedido.text);
                                                                      final double precioProducto = listProduc[index]['price'];
                                                                      final resultado = pedido * precioProducto;

                                                                      // enviar la información del registro al servidor
                                                                      //La petición se envía a través de la URL 'http://127.0.0.1:8000/produc/' y se establecen ciertos encabezados para la autorización del usuario. El cuerpo de la solicitud se define en formato JSON y contiene información sobre un producto, como su clasificación, nombre, imagen, descripción, peso, precio, dirección, fecha y unidad de peso.
                                                                      //Si la respuesta del servidor tiene un código de estado igual a 201 no se enviara nada,
                                                                      // final response = await
                                                                      final response =
                                                                          await http
                                                                              .post(
                                                                        Uri.parse(
                                                                            '$url/sitem/generate_qr_code/'),
                                                                        headers: {
                                                                          'Authorization':
                                                                              '$token',
                                                                        },
                                                                        body:
                                                                            jsonEncode({
                                                                          'clasific':
                                                                              listProduc[index]['clasific'],
                                                                          'author':
                                                                              listProduc[index]['author'],
                                                                          'cantidad':
                                                                              pedido,
                                                                          'image':
                                                                              listProduc[index]['image'],
                                                                          'id': listProduc[index]
                                                                              [
                                                                              'id'],
                                                                          'total': resultado,
                                                                          'autor': listProduc[index]['author'],
                                                                          'fecha': listProduc[index]['fecha'],
                                                                          'ubicacion': listProduc[index]['direccion'],

              //                                                             autor: '', 
              // fecha: '', 
              // ubicacion: '', 
              // valor: '',
                                                                        }),
                                                                      );
                                                                      if (response
                                                                              .statusCode ==
                                                                          201) {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      }
                                                                      // Navigator.of(context).pop();
                                                                    },
                                                                  ),
                                                                  TextButton(
                                                                    child: const Text(
                                                                        'Cancelar'),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  ),
                                                                ],
                                                              );
                                                            });
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        _isSaved[idProduc] ??
                                                                false
                                                            ? Icons.bookmark
                                                            : Icons
                                                                .bookmark_border,
                                                        color: _isSaved[
                                                                    idProduc] ??
                                                                false
                                                            ? const Color
                                                                    .fromARGB(
                                                                255,
                                                                0,
                                                                204,
                                                                255)
                                                            : null,
                                                      ),
                                                      onPressed: () async {
                                                        final prefs =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        final token = prefs
                                                            .getString('token');
                                                        final response = _isSaved[
                                                                    idProduc] ??
                                                                false

                                                            // enviar la información del registro al servidor
                                                            ? await http.delete(
                                                                Uri.parse(
                                                                    '$url/sitem/favoritos/$idFavorito/'),
                                                                headers: {
                                                                  'Authorization':
                                                                      '$token'
                                                                },
                                                              )
                                                            : await http.post(
                                                                Uri.parse(
                                                                    '$url/sitem/favoritos/'),
                                                                headers: {
                                                                  'Authorization':
                                                                      '$token',
                                                                },
                                                                body:
                                                                    jsonEncode({
                                                                  'image_user':
                                                                      listProduc[
                                                                              index]
                                                                          [
                                                                          'image_user'],
                                                                  'name': listProduc[
                                                                          index]
                                                                      ['name'],
                                                                  'author': listProduc[
                                                                          index]
                                                                      [
                                                                      'author'],
                                                                  'pk': listProduc[
                                                                          index]
                                                                      ['id']
                                                                }),
                                                              );
                                                        if (response.statusCode ==
                                                                200 ||
                                                            response.statusCode ==
                                                                201) {
                                                          // registro exitoso, navegar a la pantalla de inicio
                                                          setState(() {
                                                            _isSaved[idProduc] =
                                                                _isSaved[
                                                                        idProduc] ??
                                                                    false;
                                                            _isSaved[idProduc] =
                                                                !_isSaved[
                                                                    idProduc]!;
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
                                    ]));
                          }
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
              _buildCommentSection(),
            ]),
          ),
        ]),
      ),
    );
  }
}
