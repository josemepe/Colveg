//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 29/05/2023
//SENA-CBA 2023

//se traen los productos publicados y se pueden editar alguna informacion

//importaciones de codigo
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
// import 'package:image_picker_web/image_picker_web.dart' if (kIsWeb) 'package:image_picker_web/image_picker_web.dart';
import 'package:mime_type/mime_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../Usuario/editperfil.dart';
import '../home_screen.dart';
import '../mapa/map_editProduc.dart';
import '../menu_navegacion/drawer.dart';
import '../sistema/guardados/guardados.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;

Future<String> _uploadImage(XFile imageFile) async {
  final imageName = path.basename(imageFile.path);
  final ref =
      firebase_storage.FirebaseStorage.instance.ref('images/$imageName');

  final metadata = firebase_storage.SettableMetadata(
    contentType:
        'image/jpeg', // Ajusta el tipo de contenido según tus necesidades
  );

  final uploadTask = ref.putFile(File(imageFile.path), metadata);

  try {
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    // Maneja el error de carga de imagen
    print('Error al cargar la imagen: $e');
    return ''; // Devuelve una cadena vacía en caso de error
  }
}

//crear una clase de tipo stateles para que el usuario solo pueda   visualizar y llenar campos que se le permitan  todo lo de la pantalla
class EditPro extends StatefulWidget {
  //se crean variables de tipo final  para declararla
  final String editProducID;
  //se crea una constante que no cambiara
  const EditPro({Key? key, required this.editProducID}) : super(key: key);

  @override
  State<EditPro> createState() => _editproState();
}

// ignore: camel_case_types
class _editproState extends State<EditPro> {
  //se crea valores que pueden recibir valores nulos
  String? userName = ' ';
  String? imageUser = ' ';
  String idUser = ' ';
  String cordenadas = ' ';

  //se crea un metodo get que me devuelve un mapeo  de forma asincrona
  Future<Map<String, dynamic>> getUser() async {
    //estos finals se utiliza para recuperar unos tokens de autenticacion almacenados en una url de una api de django
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    //se crea una uri apartir de una url  la cual se hace una solicitud con el token para proporcionar la informacion
    final response = await http.get(
      Uri.parse('$url/sitem/usuario/'),
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

  //una función asincrónica llamada getProductData que devuelve un objeto
  Future<Map<String, dynamic>> getProductData(editProducID) async {
    final response =
        await http.get(Uri.parse('$url/produc/edit/$editProducID/'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData);
      return responseData;
    } else {
      throw Exception('Failed to load product data');
    }
  }

  //se crean variables de tipo final  para declararla
  final nombreProducto = TextEditingController();
  final direccion = TextEditingController();
  final precio = TextEditingController();
  final caducidad = TextEditingController();
  final cantidad = TextEditingController();
  final categoria = TextEditingController();
  final descripcion = TextEditingController();
  String ubicacion = '';  

  //se crea variables de tipo string para traer una variable con algo predefinido
  String imageUrl = '';
  String unidad = '';

  //se crea variables de tipo string para traer una variable con algo predefinido
  String _dropdownValue = '5%';

  @override
  //el método initState llama a dos funciones asincrónicas: getProductData y getUser, ambas devolviendo un objeto
  void initState() {
    super.initState();
    // La función getProductData se llama con un argumento widget.editProducID, que es el ID del producto que se está editando.
    getProductData(widget.editProducID).then((data) {
      setState(() {
        nombreProducto.text = data['name'];
        direccion.text = data['direccion'];
        precio.text = data['price'].toString();
        caducidad.text = data['fecha'];
        cantidad.text = data['peso'].toString();
        categoria.text = data['clasific'];
        descripcion.text = data['descrip'];
        imageUrl = data['image'];
        unidad = data['unidad_peso'];
        ubicacion = data['cordenadas'];
      });
    });
    //la función asincrónica getUser también devuelve un objeto Future. Cuando se resuelve el Future, se actualiza el estado
    getUser().then((value) {
      setState(() {
        userName = value['usuario'][0]['user_name'];
        imageUser = value['usuario'][0]['image_user'];
        idUser = value['usuario'][0]['id'];
        print(userName);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //se le pone color al fondo de la pantalla
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        //AppBar se utiliza para representar la barra de la aplicación
        appBar: AppBar(
          backgroundColor: const Color(0xFFF3ECB0),
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
                //registro exitoso, navegar a la pantalla de inicio
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Guardados()));
              },
            ),
          ],
        ),

        //MENU
        drawer: const MyDrawer(),

        //CUERPO APP
        body: FutureBuilder(
            future: (getProductData(widget.editProducID)),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Future<void> _selectDate(BuildContext context) async {
                  final DateTime? picked = await showDatePicker(
                      context: context,
                      //initialDate: la fecha inicial que se muestra cuando se abre el diálogo
                      initialDate: DateTime.now(),
                      //firstDate: la fecha más temprana que se puede seleccionar en el diálogo
                      firstDate: DateTime.now(),
                      //lastDate: la fecha más tardía que se puede seleccionar en el diálogo
                      lastDate: DateTime(2050, 12, 31));
                  //una función que crea y devuelve un widget personalizado para el diálogo de selección de fecha
                  if (picked != null) {
                    setState(() {
                      caducidad.text =
                          '${picked.year}-${picked.month}-${picked.day}';
                    });
                  }
                }

                //aca podemos cargar la imagen a la base de datos
                //image_picker_web. La función _pickImage() devuelve una Future<String> que representa la URL de descarga de la imagen cargada en Firebase Storage
                Future<XFile?> _pickImage() async {
                  XFile? pickedFile;  
                    final picker = ImagePicker();
                    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedImage != null) {
                    final blob = html.Blob([await pickedImage.readAsBytes()], 'image/jpeg');
                    final imageName = DateTime.now().toString();
                    final ref = storage.ref().child('images/$imageName.jpg');
                    final contentType = mime(ref.name);
                    final metadata = firebase_storage.SettableMetadata(contentType: contentType!);
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

                Future<XFile?> _pickImageAndroid() async {
                  XFile? pickedFile;  
                  final picker = ImagePicker();
                  final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);
                  
                  if (pickedImage != null) {
                    final file = File(pickedImage.path);
                    final imageName = path.basename(file.path);
                    final ref = firebase_storage.FirebaseStorage.instance.ref('images/$imageName');
                    final uploadTask = ref.putFile(file);
                    final snapshot = await uploadTask.whenComplete(() => true);
                    final url = await snapshot.ref.getDownloadURL();
                    
                    setState(() {
                      imageUrl = url;
                    });

                    print(url);
                  }

                  return pickedFile;
                }

                //se utiliza para centrar un widget
                return Center(
                    child: Container(
                  alignment: Alignment.center,
                  //se le define un ancho y largo
                  height: 900.0,
                  width: 900.0,
                  //se utiliza para centrar un widget
                  child: Center(
                    //se crea una carta
                    child: Card(
                        color: const Color.fromARGB(255, 250, 250, 250),
                        margin: const EdgeInsets.all(20.0),
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          //se mete en un SingleChildScrollView para que se pueda deslizar la pantalla de arriba abajo
                          child: SingleChildScrollView(
                            //se crea una columna
                            child: Column(
                              //MainAxisAlignment se utiliza para alinear los widgets secundarios en el eje principal del contenedor
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                //se crea un boton
                                ElevatedButton(
                                  onPressed: () async {
                                     if(kIsWeb){
                                        _pickImage();
                                      } else {
                                        _pickImageAndroid();
                                      }
                                      
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
                                const SizedBox(height: 5),

                                //se pone un texto
                                const Text(
                                  'Edita tu producto',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                //se crea una caja con el sixebox que nos haga un espacio
                                const SizedBox(height: 5),
                                // label product name

                                //es un widget de Flutter que proporciona una entrada de texto con funciones avanzadas como validación
                                TextFormField(
                                  //La propiedad controller establece el controlador que se utilizará para controlar el valor del campo de entrada
                                  controller: nombreProducto,
                                  decoration: InputDecoration(
                                    labelText: 'Nombre del producto',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color.fromRGBO(
                                              158, 217, 217, 1.0),
                                          width: 2.0),
                                    ),
                                    prefixIcon: const Icon(Icons.shopping_bag),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                TextFormField(
                                  controller: descripcion,
                                  decoration: InputDecoration(
                                    labelText: 'Descripción del Producto',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color.fromRGBO(
                                              158, 217, 217, 1.0),
                                          width: 2.0),
                                    ),
                                    prefixIcon: const Icon(Icons.description),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                //se crea una caja con el sixebox que nos haga un espacio
                                const SizedBox(height: 5),

                                //se crea una fila
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: precio,
                                        decoration: InputDecoration(
                                          labelText: 'Precio',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Color.fromRGBO(
                                                    158, 217, 217, 1.0),
                                                width: 2.0),
                                          ),
                                          prefixIcon:
                                              const Icon(Icons.monetization_on),
                                          filled: true,
                                          fillColor: Colors.grey[200],
                                        ),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    DropdownButton<String>(
                                      value: _dropdownValue,
                                      onChanged: (String? value) {
                                        setState(() {
                                          _dropdownValue = value!;
                                        });
                                      },
                                      items: <String>[
                                        '5%',
                                        '10%',
                                        '15%',
                                        '20%',
                                        '25%',
                                        '50%',
                                        '75%'
                                      ].map((String value) {
                                        return DropdownMenuItem(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),

                                //se crea una caja con el sixebox que nos haga un espacio
                                const SizedBox(height: 5),

                                //se crea una fila
                                Row(
                                  children: [
                                    Expanded(
                                      //es un widget de Flutter que proporciona una entrada de texto con funciones avanzadas como validación
                                      child: TextFormField(
                                        //La propiedad controller establece el controlador que se utilizará para controlar el valor del campo de entrada
                                        controller: cantidad,
                                        decoration: InputDecoration(
                                          labelText: 'Cantidad',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Color.fromRGBO(
                                                    158, 217, 217, 1.0),
                                                width: 2.0),
                                          ),
                                          prefixIcon: const Icon(Icons.scale),
                                          filled: true,
                                          fillColor: Colors.grey[200],
                                        ),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    DropdownButton<String>(
                                      value: unidad,
                                      onChanged: (String? value) {
                                        setState(() {
                                          unidad = value!;
                                        });
                                      },
                                      items: <String>[
                                        'kilos',
                                        'libras',
                                        'unidad',
                                        'gramos',
                                        'onzas',
                                        'Litros',
                                        'mililitros'
                                      ].map((String value) {
                                        return DropdownMenuItem(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),

                                //se crea una caja con el sixebox que nos haga un espacio
                                const SizedBox(height: 5),
                                //es un widget de Flutter que proporciona una entrada de texto con funciones avanzadas como validación
                                                        TextFormField(
                          //La propiedad controller establece el controlador que se utilizará para controlar el valor del campo de entrada
                          controller: direccion,
                          decoration: InputDecoration(
                            labelText: ' Dirección',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color.fromRGBO(158, 217, 217, 1.0),
                                  width: 2.0),
                            ),
                            prefixIcon: const Icon(Icons.location_on),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapEditProduc(initialCoordinates: ubicacion),
                              ),
                            );
                            if (result != null) {
                              List<String> resultados = result as List<String>;
                              String _direccion = resultados[0];
                              String otroValor = resultados[1];
                              direccion.text = _direccion; // Actualizar el valor del TextEditingController con la coordenada guardada
                              cordenadas = otroValor;
                            }
                          }
                        ),

                                //se crea una caja con el sixebox que nos haga un espacio
                                const SizedBox(height: 5),

                                //es un widget de Flutter que proporciona una entrada de texto con funciones avanzadas como validación
                                TextFormField(
                                  //La propiedad controller establece el controlador que se utilizará para controlar el valor del campo de entrada
                                  controller: categoria,
                                  decoration: InputDecoration(
                                    labelText: 'Categoría',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color.fromRGBO(
                                              158, 217, 217, 1.0),
                                          width: 2.0),
                                    ),
                                    prefixIcon: const Icon(Icons.category),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),

                                //se crea una caja con el sixebox que nos haga un espacio
                                const SizedBox(height: 5),

                                //es un widget de Flutter que proporciona una entrada de texto con funciones avanzadas como validación
                                TextFormField(
                                  //La propiedad controller establece el controlador que se utilizará para controlar el valor del campo de entrada
                                  controller: caducidad,
                                  onTap: () => _selectDate(context),
                                  decoration: InputDecoration(
                                    labelText: 'Caducidad',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color.fromRGBO(
                                              158, 217, 217, 1.0),
                                          width: 2.0),
                                    ),
                                    prefixIcon:
                                        const Icon(Icons.calendar_today),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                  ),
                                ),

                                //se crea una caja con el sixebox que nos haga un espacio
                                const SizedBox(height: 5),

                                //se crea una caja con el sixebox
                                SizedBox(
                                  width: double.infinity,
                                  //se crea un boton
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              const Color.fromARGB(
                                                  255, 55, 129, 57)),
                                    ),
                                    onPressed: () async {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final token = prefs.getString('token');
                                      final id = widget.editProducID;

                                      final peso = int.parse(cantidad.text);

                                      final price = double.parse(precio.text);
                                      // enviar la información del registro al servidor
                                      final response = await http.put(
                                        Uri.parse('$url/produc/edit/$id/'),
                                        headers: {
                                          'Authorization': 'Bearer $token',
                                          'Content-Type': 'application/json',
                                        },
                                        body: jsonEncode({
                                          'clasific': categoria.text,
                                          'name': nombreProducto.text,
                                          'image': imageUrl,
                                          'descrip': descripcion.text,
                                          'peso': peso,
                                          'price': price,
                                          'direccion': direccion.text,
                                          'fecha': caducidad.text,
                                          'unidad_peso': unidad
                                        }),
                                      );
                                      if (response.statusCode == 201) {
                                        // registro exitoso, navegar a la pantalla de inicio

                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const Inicio()));
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
                                    },
                                    child: const Text('Publicar'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ),
                ));
              } else if (snapshot.hasError) {
                return const Text('Error al cargar los favoritos');
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}
