//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 29/05/2005
//SENA-CBA 2023
//esta pantalla  sirve para ver las cards creadas

//importaciones de codigo

import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colveg/constant/reporte.dart';
import 'package:colveg/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../screens/Producto/editarprodu.dart';
import '../screens/Usuario/perfil_mio.dart';
import '../screens/Usuario/user_profile_otros.dart';

class MyCard extends StatefulWidget {
  final String idProduc;
  final String title;
  const MyCard({Key? key, required this.idProduc, required this.title}) : super(key: key);

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
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
    var urlProduc = '$url/produc/producto/';

    try {
      final response = await http.get(
        Uri.parse(urlProduc),
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
    var urlComment = '$url/produc/comentario/$idCommentProduc/';

    try {
      final response = await http.get(
        Uri.parse(urlComment),
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
    var urlRespComent =
        '$url/produc/Respcomentario/$idCommentProduc/$idComment/';

    try {
      final response = await http.get(
        Uri.parse(urlRespComent),
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
      // var url = 'http://127.0.0.1:8000/sitem/likes/$idProducto/';

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

  bool _isCommentSectionVisible = false;
  String? idCommentProduc;
  String? idComment;
  String? idLikstProduc;
  String searchData = ' ';

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

    // funcion para mostrar la respueta d ecomenatrios
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
                                                  const PopupMenuItem(
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
      bottom: _isCommentSectionVisible ? keyboardHeight : -sectionHeight,
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
                                      'http://127.0.0.1:8000/sitem/likes/$idCommentProduc/'),
                                  headers: {
                                    'Authorization': '$token',
                                  },
                                )
                              : await http.post(
                                  Uri.parse(
                                      'http://127.0.0.1:8000/sitem/likes/$idCommentProduc/'),
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
            const Padding(
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
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                snapshot.data?[index]['author'],
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
                                                      final idComment = snapshot
                                                          .data?[index]['id'];
                                                      showBottomSheet(
                                                          idCommentProduc,
                                                          idComment);
                                                    },
                                                    child: const Text(
                                                      'Responder',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      final idComment = snapshot
                                                          .data?[index]['id'];
                                                      showBottomSheet(
                                                          idCommentProduc,
                                                          idComment);
                                                    },
                                                    child: const Text(
                                                      'Ver respuestas',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
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
                                              const PopupMenuItem(
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
                                                        'http://127.0.0.1:8000/produc/comentario/$idCommentProduc/'),
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
                      // enviar la información del registro al servidor
                      final response = await http.post(
                          Uri.parse(
                              'http://127.0.0.1:8000/produc/comentario/$idCommentProduc/'),
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
        title: Text(widget.title),
        backgroundColor: const Color(0xFF344D67)
      ),
      body: Center(
        child: Expanded(
          child: SizedBox(
              width: 900,
              child: Card(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
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
                                        if (listProduc[index]['id'] ==
                                            widget.idProduc) {
                                          final idProduc =
                                              listProduc[index]['id'];
                                          final namAuthor =
                                              listProduc[index]['author'];
                                          final namePublic =
                                              listProduc[index]['name'];
                                          return Card(
                                              elevation: 2.0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Row(
                                                      children: <Widget>[
                                                        if (listProduc[index]
                                                                ['author'] ==
                                                            userName)
                                                          GestureDetector(
                                                              onTap: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                const MyPerfilPage()));
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        10.0),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                const MyPerfilPage()));
                                                                  },
                                                                  child: Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                                .all(
                                                                            10.0),
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap: () {
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                                builder: (context) => const MyPerfilPage()));
                                                                      },
                                                                      child:
                                                                          // CachedNetworkImage(
                                                                          //       imageUrl: snapshot.data?[index]['image_user'],
        
                                                                          //       placeholder: (context, url) => CircularProgressIndicator(),
                                                                          //       errorWidget: (context, url, error) => Icon(Icons.error),
                                                                          // ),
                                                                          CircleAvatar(
                                                                        radius:
                                                                            25.0,
                                                                        backgroundImage:
                                                                            NetworkImage(
                                                                          listProduc[index]
                                                                              [
                                                                              'image_user'],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )),
                                                        if (listProduc[index]
                                                                ['author'] !=
                                                            userName)
                                                          GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => HisPerfilPage(
                                                                          userName: listProduc[index]
                                                                              [
                                                                              'author'],
                                                                          imageUser:
                                                                              listProduc[index][
                                                                                  'image_user'],
                                                                          is_admin:
                                                                              is_admin)));
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
                                                                          builder: (context) => HisPerfilPage(
                                                                              userName:
                                                                                  listProduc[index]['author'],
                                                                              imageUser: listProduc[index]['image_user'],
                                                                              is_admin: is_admin)));
                                                                },
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 25.0,
                                                                  backgroundImage:
                                                                      NetworkImage(
                                                                    listProduc[
                                                                            index]
                                                                        [
                                                                        'image_user'],
                                                                  ),
                                                                ),
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
                                                              listProduc[index]
                                                                  ['author'],
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20.0,
                                                              ),
                                                            )),
                                                        const Spacer(),
                                                        PopupMenuButton<String>(
                                                          icon: const Icon(
                                                            Icons.more_vert,
                                                            color: Colors.black,
                                                          ),
                                                          offset: const Offset(
                                                              -20, 30),
                                                          color: Colors.amber[50],
                                                          itemBuilder:
                                                              (context) => [
                                                            if (listProduc[index][
                                                                        'author'] ==
                                                                    userName ||
                                                                is_admin == true)
                                                              const PopupMenuItem(
                                                                value: 'edit',
                                                                child: Row(
                                                                  children: <Widget>[
                                                                    Icon(
                                                                        Icons
                                                                            .edit,
                                                                        color: Colors
                                                                            .amber),
                                                                    SizedBox(
                                                                        width:
                                                                            8.0),
                                                                    Text(
                                                                        'Editar'),
                                                                  ],
                                                                ),
                                                              ),
                                                            if (listProduc[index][
                                                                        'author'] ==
                                                                    userName ||
                                                                is_admin == true)
                                                              const PopupMenuItem(
                                                                value: 'delete',
                                                                child: Row(
                                                                  children: <Widget>[
                                                                    Icon(
                                                                        Icons
                                                                            .delete,
                                                                        color: Colors
                                                                            .red),
                                                                    SizedBox(
                                                                        width:
                                                                            8.0),
                                                                    Text(
                                                                        'Eliminar'),
                                                                  ],
                                                                ),
                                                              ),
                                                            if (listProduc[index][
                                                                        'author'] !=
                                                                    userName ||
                                                                is_admin == true)
                                                              const PopupMenuItem(
                                                                value: 'report',
                                                                child: Row(
                                                                  children: <Widget>[
                                                                    Icon(
                                                                        Icons
                                                                            .flag,
                                                                        color: Colors
                                                                            .red),
                                                                    SizedBox(
                                                                        width:
                                                                            8.0),
                                                                    Text(
                                                                        'Reportar'),
                                                                  ],
                                                                ),
                                                              ),
                                                          ],
                                                          onSelected:
                                                              (value) async {
                                                            if (value == 'edit') {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          EditPro(
                                                                              editProducID:
                                                                                  listProduc[index]['id'])));
                                                            }
                                                            if (value ==
                                                                'delete') {
                                                              final prefs =
                                                                  await SharedPreferences
                                                                      .getInstance();
                                                              final token =
                                                                  prefs.getString(
                                                                      'token');
        
                                                              final id =
                                                                  listProduc[
                                                                          index]
                                                                      ['id'];
        
                                                              // enviar la información del registro al servidor
                                                              final response =
                                                                  await http
                                                                      .delete(
                                                                Uri.parse(
                                                                    'http://127.0.0.1:8000/produc/delete/$id/'),
                                                                headers: {
                                                                  'Authorization':
                                                                      'Bearer $token',
                                                                },
                                                              );
                                                              if (response
                                                                      .statusCode ==
                                                                  201) {
                                                                setState(() {
                                                                  listProduc
                                                                      .removeAt(
                                                                          index);
                                                                });
                                                              } else {
                                                                // ignore: use_build_context_synchronously
                                                                ScaffoldMessenger
                                                                        .of(context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                        'Error al registrar el usuario'),
                                                                  ),
                                                                );
                                                              }
                                                            }
                                                            if (value ==
                                                                'report') {
                                                              ReportUtils.showReportOptions(
                                                                  context,
                                                                  idPublic:
                                                                      idProduc,
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
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 10.0,
                                                              vertical: 5.0,
                                                            ),
                                                            child: Text(
                                                              '#' +
                                                                  listProduc[
                                                                          index][
                                                                      'clasific'],
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14.0,
                                                              ),
                                                            )),
                                                        Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 10.0,
                                                              vertical: 5.0,
                                                            ),
                                                            child: Text(
                                                              listProduc[index]
                                                                  ['name'],
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
                                                    Row(
                                                      children: <Widget>[
                                                        const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
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
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 10.0,
                                                            vertical: 5.0,
                                                          ),
                                                          child: Text(
                                                            listProduc[index]
                                                                        ['price']
                                                                    .toString() +
                                                                "x" +
                                                                snapshot.data?[
                                                                        index][
                                                                    'unidad_peso'],
                                                            style:
                                                                const TextStyle(
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
                                                          padding: EdgeInsets
                                                              .symmetric(
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
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 10.0,
                                                              vertical: 5.0,
                                                            ),
                                                            child: AutoSizeText(
                                                              listProduc[index]
                                                                  ['direccion'],
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12.0,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              minFontSize: 8.0,
                                                              maxFontSize: 12.0,
                                                            ),
                                                          ),
                                                        ),
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
                                                                  horizontal:
                                                                      10.0,
                                                                  vertical: 5.0,
                                                                ),
                                                                child: Text(
                                                                  'Descripción:',
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                    horizontal:
                                                                        10.0,
                                                                    vertical: 5.0,
                                                                  ),
                                                                  child: Text(
                                                                    listProduc[
                                                                            index]
                                                                        [
                                                                        'descrip'],
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          12.0,
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
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0), // opcional
                                                              color: Colors.grey[
                                                                  300], // opcional
                                                              shape: BoxShape
                                                                  .rectangle,
                                                            ),
                                                            child:
                                                                CachedNetworkImage(
                                                              width: 300,
                                                              height: 300,
                                                              imageUrl:
                                                                  listProduc[
                                                                          index]
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
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            horizontal: 0.0,
                                                            vertical: 5.0,
                                                          ),
                                                          child: Text(
                                                            'El siguiente producto expira el',
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
                                                              listProduc[index]
                                                                  ['fecha'],
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
                                                    Row(
                                                      children: <Widget>[
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(left: 10),
                                                          child: Text(
                                                            '${numLikes[idProduc]} Likes',
                                                            // 'likes',
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                        const Spacer(flex: 1),
                                                        const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            horizontal: 0.0,
                                                            vertical: 5.0,
                                                          ),
                                                          child: Text(
                                                            'La cantidad en existencias es de ',
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
                                                            listProduc[index]
                                                                        ['peso']
                                                                    .toString() +
                                                                listProduc[index][
                                                                    'unidad_peso'],
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 14.0,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
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
                                                                      _isLiked[idProduc] ??
                                                                              false
                                                                          ? Icons
                                                                              .thumb_up_alt
                                                                          : Icons
                                                                              .thumb_up_alt_outlined,
                                                                      color: _isLiked[idProduc] ??
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
                                                                      final token =
                                                                          prefs.getString(
                                                                              'token');
                                                                      final idProduc =
                                                                          listProduc[index]
                                                                              [
                                                                              'id'];
                                                                      // enviar la información del registro al servidor
                                                                      final response = _isLiked[idProduc] ??
                                                                              false
                                                                          ? await http
                                                                              .delete(
                                                                              Uri.parse('http://127.0.0.1:8000/sitem/likes/$idProduc/'),
                                                                              headers: {
                                                                                'Authorization': '$token',
                                                                              },
                                                                            )
                                                                          : await http
                                                                              .post(
                                                                              Uri.parse('http://127.0.0.1:8000/sitem/likes/$idProduc/'),
                                                                              headers: {
                                                                                'Authorization': '$token',
                                                                              },
                                                                            );
                                                                      if (response.statusCode ==
                                                                              200 ||
                                                                          response.statusCode ==
                                                                              201) {
                                                                        // Registro exitoso, actualizar _isLiked
                                                                        setState(
                                                                            () {
                                                                          _isLiked[
                                                                              idProduc] = _isLiked[
                                                                                  idProduc] ??
                                                                              false;
                                                                          _isLiked[idProduc] =
                                                                              !_isLiked[idProduc]!;
                                                                          if (_isLiked[
                                                                              idProduc]!) {
                                                                            numLikes[
                                                                                idProduc] = (numLikes[idProduc] ??
                                                                                    0) +
                                                                                1;
                                                                          } else {
                                                                            numLikes[
                                                                                idProduc] = (numLikes[idProduc] ??
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
                                                                            content:
                                                                                Text('Error al registrar el like'),
                                                                          ),
                                                                        );
                                                                      }
                                                                    },
                                                                  ),
                                                                  IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .comment),
                                                                    onPressed:
                                                                        () {
                                                                      final id =
                                                                          listProduc[index]
                                                                              [
                                                                              'id'];
                                                                      // pasamos como parametro el id de la publicacion para mostrar la secci0on de comenayrios dde cada publicacion
                                                                      _toggleCommentSection(
                                                                          id);
                                                                    },
                                                                  ),
                                                                  IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .send),
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                  ),
                                                                  IconButton(
                                                                    icon: Icon(
                                                                      _isSaved[idProduc] ??
                                                                              false
                                                                          ? Icons
                                                                              .bookmark
                                                                          : Icons
                                                                              .bookmark_border,
                                                                      color: _isSaved[idProduc] ??
                                                                              false
                                                                          ? const Color.fromARGB(
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
                                                                      final token =
                                                                          prefs.getString(
                                                                              'token');
                                                                      final response = _isSaved[idProduc] ??
                                                                              false
        
                                                                          // enviar la información del registro al servidor
                                                                          ? await http
                                                                              .delete(
                                                                              Uri.parse('http://127.0.0.1:8000/sitem/favoritos/$idFavorito/'),
                                                                              headers: {
                                                                                'Authorization': '$token'
                                                                              },
                                                                            )
                                                                          : await http
                                                                              .post(
                                                                              Uri.parse('http://127.0.0.1:8000/sitem/favoritos/'),
                                                                              headers: {
                                                                                'Authorization': '$token',
                                                                              },
                                                                              body:
                                                                                  jsonEncode({
                                                                                'image_user': listProduc[index]['image_user'],
                                                                                'name': listProduc[index]['name'],
                                                                                'author': listProduc[index]['author'],
                                                                                'pk': listProduc[index]['id']
                                                                              }),
                                                                            );
                                                                      if (response.statusCode ==
                                                                              200 ||
                                                                          response.statusCode ==
                                                                              201) {
                                                                        // registro exitoso, navegar a la pantalla de inicio
                                                                        setState(
                                                                            () {
                                                                          _isSaved[
                                                                              idProduc] = _isSaved[
                                                                                  idProduc] ??
                                                                              false;
                                                                          _isSaved[idProduc] =
                                                                              !_isSaved[idProduc]!;
                                                                        });
                                                                      } else {
                                                                        // ignore: use_build_context_synchronously
                                                                        ScaffoldMessenger.of(
                                                                                context)
                                                                            .showSnackBar(
                                                                          const SnackBar(
                                                                            content:
                                                                                Text('Esta publicacion ya se encuentra en favoritos'),
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
                                        } else {
                                          return const Text(' ');
                                        }
                                      });
                                } else if (snapshot.hasError) {
                                  return const Text(
                                      'Error al cargar los favoritos');
                                } else {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                              }),
                            ),
                          ),
                          _buildCommentSection(),
                        ]),
                      ),
                    ],
                  ))),
        ),
      ),
    );
  }
}
