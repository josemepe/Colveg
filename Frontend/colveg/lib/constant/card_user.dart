import 'package:flutter/material.dart';
import '../screens/Producto/editarprodu.dart';

class MyCard extends StatefulWidget {
  const MyCard({super.key});

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  bool _isLiked = false;
  bool _isSaved = false;
  int numLikes = 5;
  bool _isCommentSectionVisible = false;

  void _toggleCommentSection() {
    setState(() {
      _isCommentSectionVisible = !_isCommentSectionVisible;
    });
  }

  Widget _buildCommentSection() {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final sectionHeight = screenHeight * 0.8; // 80% de la altura de la pantalla
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
                          _isLiked
                              ? Icons.thumb_up_alt
                              : Icons.thumb_up_alt_outlined,
                          color: _isLiked
                              ? const Color.fromARGB(255, 2, 164, 204)
                              : Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isLiked = !_isLiked;
                            if (_isLiked) {
                              numLikes++;
                            } else {
                              numLikes--;
                            }
                          });
                        },
                      ),
                      Text(
                        '$numLikes Likes',
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
                      IconButton(
                        icon: Icon(
                          _isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: _isSaved
                              ? const Color.fromARGB(255, 0, 204, 255)
                              : Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSaved = !_isSaved;
                          });
                        },
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
                child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20.0,
                        backgroundImage:
                            NetworkImage(_comments[index].userImageUrl),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _comments[index].username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              _comments[index].comment,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            )),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              color: const Color(0xFF344D67),
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
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Agregar comentario',
                          hintStyle: TextStyle(
                            color: Colors.black54,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
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
                    onPressed: () {},
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
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: CircleAvatar(
                          radius: 25.0,
                          backgroundImage: NetworkImage(
                            'https://akamai.sscdn.co/uploadfile/letras/fotos/9/7/9/a/979a8f63920a279a69104640c47e43bd.jpg',
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'Juanito Pérez',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.black,
                      ),
                      offset: const Offset(-20, 30),
                      color: Colors.amber[50],
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: 'report',
                            child: Column(children: [
                              Row(
                                children: <Widget>[
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8.0),
                                  Text('Eliminar'),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(Icons.edit,
                                      color: Color.fromARGB(255, 250, 230, 46)),
                                  SizedBox(width: 8.0),
                                  Text('Editar'),
                                ],
                              ),
                            ])),
                      ],
                      onSelected: (value) {
                        if (value == 'report') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const EditPro(
                                        editProducID: '',
                                      )));
                        }
                      },
                    ),
                  ],
                ),
                const Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 5.0,
                      ),
                      child: Text(
                        '#HERBACEA',
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
                        'Papa Criolla',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: <Widget>[
                    Padding(
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 5.0,
                      ),
                      child: Text(
                        '10.000 x Libra',
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: <Widget>[
                    Padding(
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
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 5.0,
                      ),
                      child: Text(
                        'Cota-Cundinamarca',
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: <Widget>[
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              'Papas tradicionales del campo Colombiano, Somos erbalay',
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 200,
                        child: Image.network(
                          'https://thumbs.dreamstime.com/b/patata-y-aislado-en-un-fondo-blanco-205745815.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: <Widget>[
                    Spacer(flex: 1),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 0.0,
                        vertical: 5.0,
                      ),
                      child: Text(
                        'El siguiente producto expira el',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        right: 20,
                      ),
                      child: Text(
                        ' 28/08/2025',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        '$numLikes Likes',
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
                    const Padding(
                      padding: EdgeInsets.only(
                        right: 20,
                      ),
                      child: Text(
                        '20 Libras',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: const Color(0xFFF3ECB0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(
                                  _isLiked
                                      ? Icons.thumb_up_alt
                                      : Icons.thumb_up_alt_outlined,
                                  color: _isLiked
                                      ? const Color.fromARGB(255, 0, 204, 255)
                                      : null,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isLiked = !_isLiked;
                                    if (_isLiked) {
                                      numLikes++;
                                    } else {
                                      numLikes--;
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.comment),
                                onPressed: () {
                                  _toggleCommentSection();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: () {
                                  setState(() {});
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  _isSaved
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: _isSaved
                                      ? const Color.fromARGB(255, 0, 204, 255)
                                      : null,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isSaved = !_isSaved;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildCommentSection(),
      ],
    );
  }
}

class Comment {
  final String username;
  final String comment;
  final String userImageUrl;

  Comment(
      {required this.username,
      required this.comment,
      required this.userImageUrl});
}

List<Comment> _comments = [
  Comment(
    username: 'Usuario1',
    comment: 'Este es un comentario de prueba',
    userImageUrl:
        'https://akamai.sscdn.co/uploadfile/letras/fotos/0/c/d/8/0cd84692be900a25db90e462fa8b95c9.jpg',
  ),
  Comment(
    username: 'Usuario1',
    comment: 'Este es un comentario de prueba',
    userImageUrl:
        'https://akamai.sscdn.co/uploadfile/letras/fotos/0/c/d/8/0cd84692be900a25db90e462fa8b95c9.jpg',
  ),
  Comment(
    username: 'Usuario1',
    comment: 'Este es un comentario de prueba',
    userImageUrl:
        'https://akamai.sscdn.co/uploadfile/letras/fotos/0/c/d/8/0cd84692be900a25db90e462fa8b95c9.jpg',
  ),
  Comment(
    username: 'Usuario1',
    comment: 'Este es un comentario de prueba',
    userImageUrl:
        'https://akamai.sscdn.co/uploadfile/letras/fotos/0/c/d/8/0cd84692be900a25db90e462fa8b95c9.jpg',
  ),
  Comment(
    username: 'Usuario1',
    comment: 'Este es un comentario de prueba',
    userImageUrl:
        'https://akamai.sscdn.co/uploadfile/letras/fotos/9/7/9/a/979a8f63920a279a69104640c47e43bd.jpg',
  ),
  Comment(
    username: 'Usuario1',
    comment: 'Este es un comentario de prueba',
    userImageUrl:
        'https://akamai.sscdn.co/uploadfile/letras/fotos/0/c/d/8/0cd84692be900a25db90e462fa8b95c9.jpg',
  ),
  Comment(
    username: 'Usuario1',
    comment: 'Este es un comentario de prueba',
    userImageUrl:
        'https://akamai.sscdn.co/uploadfile/letras/fotos/0/c/d/8/0cd84692be900a25db90e462fa8b95c9.jpg',
  ),
  Comment(
    username: 'Usuario1',
    comment: 'Este es un comentario de prueba',
    userImageUrl:
        'https://akamai.sscdn.co/uploadfile/letras/fotos/0/c/d/8/0cd84692be900a25db90e462fa8b95c9.jpg',
  ),
  Comment(
    username: 'Usuario1',
    comment: 'Este es un comentario de prueba',
    userImageUrl:
        'https://akamai.sscdn.co/uploadfile/letras/fotos/0/c/d/8/0cd84692be900a25db90e462fa8b95c9.jpg',
  ),
  Comment(
    username: 'Usuario1',
    comment: 'Este es un comentario de prueba',
    userImageUrl:
        'https://akamai.sscdn.co/uploadfile/letras/fotos/9/7/9/a/979a8f63920a279a69104640c47e43bd.jpg',
  ),
];
