//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 29/05/2005
//SENA-CBA 2023

//la pantalla  arroja la opcion de poder editar tu pefil

//importaciones de codigo
import 'dart:io';
import 'package:colveg/screens/Usuario/perfil_mio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime_type/mime_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../menu_navegacion/drawer.dart';
import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../sistema/guardados/guardados.dart';
//se conecta con la base de datos
final FirebaseStorage storage = FirebaseStorage.instance;

// Future para traer informacion del usuario que inicio sesion
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
//  ------------------------------------------------------------------------

//crear una clase de tipo stateles para que el usuario solo pueda   visualizar y llenar campos que se le permitan  todo lo de la pantalla
class EditPerf extends StatelessWidget {
  const EditPerf({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      //se quita el debug que aparece a la derecha
      debugShowCheckedModeBanner: false,
      title: 'Editar Perfil',
      home: Scaffold(
          body: Center(
        //se trae la clase
        child: EditPerfil(),
      )),
    );
  }
}

//se trae la clase de tipo stateful para poder modificar agragar todo lo que queramos
class EditPerfil extends StatefulWidget {
  const EditPerfil({super.key});

  @override
  State<EditPerfil> createState() => _EditPerfilState();
}

class _EditPerfilState extends State<EditPerfil> {
  //se crean variables de tipo final  para declararla
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _userNameController = TextEditingController();
  String userId = ' ';
  var imageUrl;
   String userName = ' ';
  String imageUser = ' ';
  String idUser = ' ';
  



    @override
  void initState() {
    super.initState();
     getUser().then((value) {
      setState(() {
        imageUrl = value['usuario'][0]['image_user'];
        _userNameController.text = value['usuario'][0]['user_name'];
        _nameController.text = value['usuario'][0]['name'];
        _emailController.text = value['usuario'][0]['email'];
        userId = value['usuario'][0]['id'];
        // is_admin = value['usuario'][0]['is_admin'];
                //se asignan a las variables userName e imageUser, que se utilizan para mostrar el nombre y la imagen del usuario
        userName = value['usuario']?[0]['user_name'];
        imageUser = value['usuario']?[0]['image_user'];
        idUser = value['usuario']?[0]['id'];
      });
      }
     );
    }
    
  
  //se crea valores que pueden recibir valores nulos
  File? _image;
  

  //Se crea una instancia de la clase ImagePicker, que es proporcionada por la biblioteca image_picker. Esta instancia se utilizará posteriormente para obtener una imagen de la cámara.
  final picker = ImagePicker();
  //Se define una función asincrónica llamada getImageFromCamera, que será utilizada para obtener una imagen de la cámara.
  Future getImageFromCamera() async {
    //Se utiliza el método getImage del objeto picker para abrir la cámara y permitir al usuario tomar una foto. La función espera la resolución de esta llamada antes de continuar ejecutando el código siguiente. El resultado se almacena en la variable cameraFile.
    final camaraFile = await picker.getImage(source: ImageSource.camera);
    //Se llama al método setState para actualizar el estado de la aplicación. Dentro de él, se verifica si cameraFile no es nulo, lo que significa que
    //el usuario ha seleccionado una imagen de la cámara. En ese caso, se asigna la ruta de la imagen a la variable _image, que aparentemente es
    // un objeto File. Si cameraFile es nulo, se imprime un mensaje indicando que no se seleccionó ninguna imagen.
    setState(() {
      if (camaraFile != null) {
        _image = File(camaraFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  //Se define una función asincrónica llamada getImageFromGallery, que será utilizada para obtener una imagen de la galería del dispositivo.
Future<XFile?> _pickImage() async {
                  XFile? pickedFile;
                  final picker = ImagePicker();
                  final XFile? pickedImage =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    final blob = html.Blob(
                        [await pickedImage.readAsBytes()], 'image/jpeg');
                    final imageName = DateTime.now().toString();
                    final ref = storage.ref().child('images/$imageName.jpg');
                    final contentType = mime(ref.name);
                    final metadata = firebase_storage.SettableMetadata(
                        contentType: contentType!);
                    final uploadTask = ref.putBlob(blob, metadata);
                    final snapshot = await uploadTask.whenComplete(() => true);
                    final String url = await snapshot.ref.getDownloadURL();

                    setState(() {
                      imageUrl = url;
                    });

                    print(url);
                  }
                  return pickedFile;
                }

  //Se define una función asincrónica llamada _showOptionsDialog, que se utiliza para mostrar un cuadro de diálogo con opciones al usuario.
  Future<void> _showOptionsDialog() async {
    //Se devuelve un widget AlertDialog que muestra un título y contenido en el cuadro de diálogo. El título es "Selecciona una foto".
    //El contenido se coloca dentro de un SingleChildScrollView y un ListBody para permitir desplazamiento si hay muchas opciones.
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          //Se devuelve un widget AlertDialog que muestra un título y contenido en el cuadro de diálogo.
          //El título es "Selecciona una foto". El contenido se coloca dentro de un SingleChildScrollView
          return AlertDialog(
            title: const Text("Selecciona una foto"),
            ////se mete en un SingleChildScrollView para que se pueda deslizar la pantalla de arriba abajo
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  //Se utiliza un widget GestureDetector para crear un elemento de lista que muestra el texto "Tomar una foto".
                  //Cuando se toca este elemento, se llama a la función getImageFromCamera
                  GestureDetector(
                    child: const Text("Tomar una foto"),
                    onTap: () {
                      getImageFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                  ////se crea una caja con el sixebox que nos haga un espacio
                  const SizedBox(height: 20),
                  //Se utiliza otro GestureDetector para crear otro elemento de lista que muestra el texto "Seleccionar una imagen".
                  //Cuando se toca este elemento, se llama a la función getImageFromGallery
                  GestureDetector(
                    child: const Text("Seleccionar una imagen"),
                    onTap: () async {
                      _pickImage();
                      Navigator.of(context).pop();
                    },
                  ),
                  //Se utiliza otro GestureDetector para crear un elemento de lista que muestra el texto "Cancelar" en color rojo. Cuando se toca este elemento,
                  // se utiliza Navigator.of(context).pop() para cerrar el cuadro de diálogo sin realizar ninguna acción adicional.
                  GestureDetector(
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
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

      //CUERPO APP
      body: Center(
        //se retorna un sixebox que hace la funcion de una caja
        child: SizedBox(
          height: 900.0,
          width: 900.0,
          child: Card(
            color: const Color(0xFFFAF6D2),
            margin: const EdgeInsets.all(20.0),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                //se mete en un SingleChildScrollView para que se pueda deslizar la pantalla de arriba abajo
                child: SingleChildScrollView(
                  //se pone para superponer elementos encima de otros
                  child: Stack(
                    children: [
                      //se crea una columna
                      Column(
                        //MainAxisAlignment se utiliza para alinear los widgets secundarios en el eje principal del contenedor.
                        //CrossAxisAlignment se utiliza para alinear los widgets secundarios en el eje transversal del contenedor,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //se retorna un sixebox que hace la funcion de una caja
                          const SizedBox(
                            height: 70,
                          ),
                          //se pone un texto
                          const Text(
                            'Editar Perfil',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          //se crea una caja con el sixebox que nos haga un espacio
                          const SizedBox(height: 16.0),
                          //se crea un boton
                          ElevatedButton(
                                  onPressed: () async {
                                    final pickedFile = await _pickImage();
                                    // setState(() {
                                    //   imageUrl = pickedFile;
                                    // });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(20.0),
                                    primary: const Color.fromARGB(
                                        158, 217, 217, 217),
                                  ),
                                  // ignore: unnecessary_null_comparison
                                  child: imageUrl != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                          child: Image.network(
                                            imageUrl,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.camera_alt_outlined,
                                          size: 60,
                                          color: Colors.black,
                                        ),
                                ),
                          //se crea una caja con el sixebox que nos haga un espacio
                          const SizedBox(height: 16.0),
                          //se retorna un sixebox que hace la funcion de una caja
                          SizedBox(
                            width: double.infinity,
                            //es un widget de Flutter que proporciona una entrada de texto con funciones avanzadas como validación
                            child: TextFormField(
                              controller: _emailController,
                              //La propiedad controller establece el controlador que se utilizará para controlar el valor del campo de entrada
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.email),
                                labelText: 'Correo Electronico',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa un correo electrónico';
                                } else if (!RegExp(
                                        r'^[\w-.]+@([\w-]+.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Por favor ingresa un correo electrónico válido';
                                }
                                return null;
                              },
                            ),
                          ),
                          //se crea una caja con el sixebox que nos haga un espacio
                          const SizedBox(height: 16.0),
                          //se retorna un sixebox que hace la funcion de una caja
                          SizedBox(
                            width: double.infinity,
                            //es un widget de Flutter que proporciona una entrada de texto con funciones avanzadas como validación
                            child: TextFormField(
                              //La propiedad controller establece el controlador que se utilizará para controlar el valor del campo de entrada
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.people),
                                labelText: 'Nombre',
                              ),
                            ),
                          ),
                          //se crea una caja con el sixebox que nos haga un espacio
                          const SizedBox(height: 16.0),
                          //se retorna un sixebox que hace la funcion de una caja
                          SizedBox(
                            width: double.infinity,
                            //es un widget de Flutter que proporciona una entrada de texto con funciones avanzadas como validación
                            child: TextFormField(
                              //La propiedad controller establece el controlador que se utilizará para controlar el valor del campo de entrada
                              controller: _userNameController,
                              keyboardType: TextInputType.name,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.people),
                                labelText: 'Nombre de usuario',
                              ),
                            ),
                          ),
                          //se retorna un sixebox que hace la funcion de una caja
                          // SizedBox(
                          //   width: double.infinity,
                          //   //es un widget de Flutter que proporciona una entrada de texto con funciones avanzadas como validación
                          //   child: TextFormField(
                          //     //La propiedad controller establece el controlador que se utilizará para controlar el valor del campo de entrada
                          //     controller: _phoneNumberController,
                          //     keyboardType: TextInputType.phone,
                          //     decoration: InputDecoration(
                          //       prefixIcon: Icon(Icons.phone),
                          //       labelText: 'Número telefónico',
                          //     ),
                          //   ),
                          // ),
                          //se crea una caja con el sixebox que nos haga un espacio
                          const SizedBox(height: 16.0),
                          //se crea una caja con el sixebox
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        const Color.fromARGB(255, 55, 129, 57)),
                              ),
                              onPressed: () async {
                                // enviar la información del registro al servidor
                                final response = await http.post(
                                  Uri.parse(
                                      'http://127.0.0.1:8000/login/editar_profile/$userId/'),
                                  body: jsonEncode({
                                    
                                        'email': _emailController.text,
                                        'name': _nameController.text,
                                        'user_name': _userNameController.text,
                                        'image_user': imageUrl
                                  },)
                                );
                                if (response.statusCode == 201) {
                                  // registro exitoso, navegar a la pantalla de inicio
                                  // ignore: use_build_context_synchronously
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MyPerfilPage()));
                                } else if (response.statusCode == 400){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Este nombre de usuario ya esta en uso porfavor intentente con otro'),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Error al actualizar informacion'),
                                    ),
                                  );
                                 }
                              },
                              child: const Text('Confirmar'),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        const Color(0xFFD14F4F)),
                              ),
                              child: const Text('Eliminar cuenta'),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
