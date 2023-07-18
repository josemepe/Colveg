//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 29/05/2023
//SENA-CBA 2023

//esta pantalla es donde se muestra para publicar los productos

//importaciones de codigo
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../home_screen.dart';
import '../mapa/mapa_screen.dart';
import '../menu_navegacion/drawer.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// import 'package:image_picker_web/image_picker_web.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:universal_html/html.dart' as html;
import 'package:mime_type/mime_type.dart';
import '../sistema/guardados/guardados.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

//se inicializa una instancia de firebase
final FirebaseStorage storage = FirebaseStorage.instance;

//crear una clase de tipo stateles para que el usuario solo pueda   visualizar y llenar campos que se le permitan  todo lo de la pantalla
class PublicarScreen extends StatelessWidget {
  const PublicarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      //se quita el debug que aparece a la derecha
      debugShowCheckedModeBanner: false,
      title: 'Publicar ',
      //se trae la clase
      home: publicarScreen(),
    );
  }
}

//se trae la clase de tipo stateful para poder modificar agragar todo lo que queramos
class publicarScreen extends StatefulWidget {
  const publicarScreen({super.key});

  @override
  State<publicarScreen> createState() => _publicarScreenState();
}

class _publicarScreenState extends State<publicarScreen> {
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

//initState() para recuperar los datos del usuario y actualizar el estado de la pantalla con la información obtenida.
  @override
  void initState() {
    
    super.initState();
    //la función then(), se llama a la función setState() para actualizar el estado de la pantalla con los datos del usuario. En particular, se extraen el nombre de usuario y la imagen del usuario
    getUser().then((value) {
      setState(() {
        userName = value['usuario'][0]['user_name'];
        imageUser = value['usuario'][0]['image_user'];
        idUser = value['usuario'][0]['id'];
        print(userName);
      });
    });
  }

  //se crean variables de tipo final  para declararla
  final _nombreProducto = TextEditingController();
  final _descripcion = TextEditingController();
  final _direccion = TextEditingController();
  final _precio = TextEditingController();
  final _caducidad = TextEditingController();
  final _cantidad = TextEditingController();
  final _categoria = TextEditingController();
  //se crea variables de tipo string para traer una variable con algo predefinido
  String _dropdownValue = '5%';
  String _unidad = 'kilos';
  //se crea valores que pueden recibir valores nulos
  String? imageUrl;
  File? selectedImage;
  //se define una variable webimage que nos da un unit8list que nos contiene 8 bits
  Uint8List webImage = Uint8List(8);
  //_selectDate() que toma como argumento un objeto BuildContext y devuelve un método showDatePicker() que muestra un diálogo de selección de fecha
  Future<void> _selectDate(BuildContext context) async {
    //El método showDatePicker() devuelve un objeto Future<DateTime?> que representa la fecha seleccionada por el usuario. Si el usuario selecciona una fecha, la función actualiza el estado de la aplicación utilizando el método setState()
    final DateTime? picked = await showDatePicker(
      context: context,
      //initialDate: la fecha inicial que se muestra cuando se abre el diálogo
      initialDate: DateTime.now(),
      //firstDate: la fecha más temprana que se puede seleccionar en el diálogo
      firstDate: DateTime.now(),
      //lastDate: la fecha más tardía que se puede seleccionar en el diálogo
      lastDate: DateTime(2050, 12, 31),
      // locale: const Locale('es', 'ES'),
      //una función que crea y devuelve un widget personalizado para el diálogo de selección de fecha
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF3ECB0), // Color principal
              onPrimary:
                  Color.fromARGB(242, 0, 0, 0), // Color del texto pricipal
              surface: Color.fromARGB(
                  255, 0, 0, 0), // Color de que subraya los numeros
              onSurface: Color.fromARGB(
                  255, 0, 0, 0), // Color dellos numeros de l calendario
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null)
      setState(() {
        _caducidad.text = '${picked.year}-${picked.month}-${picked.day}';
      });
  }

  //aca podemos cargar la imagen a la base de datos
  //image_picker_web. La función _pickImage() devuelve una Future<String> que representa la URL de descarga de la imagen cargada en Firebase Storage
  
FirebaseStorage storage = FirebaseStorage.instance;

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


  //se abre la galeria para seleccionar las imagenes
  Future<XFile?> getImagen() async {
    //image_picker para obtener una imagen desde la galería del dispositivo del usuario.

    final picker = ImagePicker();
    //Primero se instancia un objeto ImagePicker y se llama al método pickImage() que devuelve un objeto XFile con la información de la imagen seleccionada
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      //se utiliza setState() para actualizar el estado de la variable selectedImage y almacenar la imagen seleccionada
      selectedImage = File(image!.path);
    });
    // await uploadImage(selectedImage!);
    return image;
  }

  @override
  //se encarga de liberar la memoria de los controladores de texto al finalizar la ejecución de la pantalla
  void dispose() {
    super.dispose();
    // TODO: implement dispose
    _nombreProducto.dispose();
    _descripcion.dispose();
    _direccion.dispose();
    _precio.dispose();
    _caducidad.dispose();
    _cantidad.dispose();
    _categoria.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
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
        //se trae un titulo que pone un texto
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
      body: Center(
        //se crea una caja con el sixebox
        child: SizedBox(
            child: Container(
          //se alinia en el centro todos los elementos
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
                      //MainAxisAlignment se utiliza para alinear los widgets secundarios en el eje principal del contenedor.
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //se crea una caja con el sixebox que nos haga un espacio
                        const SizedBox(height: 20),
                        //se crea un boton
                        ElevatedButton(
                          onPressed: () async {
                            if(kIsWeb){
                              _pickImage();
                            } else {
                              _pickImageAndroid();
                            }
                            
                            
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20.0),
                            primary: Color.fromARGB(158, 217, 217, 217),
                          ),
                          child: imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(50.0),
                                  child: Image.network(
                                    imageUrl!,
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

                        // ),

                        // label product name
                        //  es un widget de Flutter que proporciona una entrada de texto con funciones avanzadas como validación
                        TextFormField(
                          //La propiedad controller establece el controlador que se utilizará para controlar el valor del campo de entrada
                          controller: _nombreProducto,
                          decoration: InputDecoration(
                            labelText: 'Nombre del producto',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color.fromRGBO(158, 217, 217, 1.0),
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

                        //se crea una caja con el sixebox que nos haga un espacio
                        const SizedBox(height: 5),

                        //  es un widget de Flutter que proporciona una entrada de texto con funciones avanzadas como validación
                        TextFormField(
                          controller: _descripcion,
                          decoration: InputDecoration(
                            labelText: 'Descripción del Producto',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color.fromRGBO(158, 217, 217, 1.0),
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

                        //se crea una fila que contendra la oferta del producto
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _precio,
                                decoration: InputDecoration(
                                  labelText: 'Precio',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color:
                                            Color.fromRGBO(158, 217, 217, 1.0),
                                        width: 2.0),
                                  ),
                                  prefixIcon: const Icon(Icons.monetization_on),
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
                                '0%',
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

                        //se crea una fila que contendra las cantidades
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cantidad,
                                decoration: InputDecoration(
                                  labelText: 'Cantidad',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color:
                                            Color.fromRGBO(158, 217, 217, 1.0),
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
                              value: _unidad,
                              onChanged: (String? value) {
                                setState(() {
                                  _unidad = value!;
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

                        //  es un widget de Flutter que proporciona una entrada de texto con funciones avanzadas como validación
                        TextFormField(
                          //La propiedad controller establece el controlador que se utilizará para controlar el valor del campo de entrada
                          controller: _direccion,
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
                                builder: (context) => MapsScreen(),
                              ),
                            );
                            if (result != null) {
                              List<String> resultados = result as List<String>;
                              String direccion = resultados[0];
                              String otroValor = resultados[1];
                              _direccion.text = direccion; // Actualizar el valor del TextEditingController con la coordenada guardada
                              cordenadas = otroValor;
                            }
                          }
                        ),

                        //se crea una caja con el sixebox que nos haga un espacio
                        const SizedBox(height: 5),
                        //  es un widget de Flutter que proporciona una entrada de texto con funciones avanzadas como validación
                        TextFormField(
                          //La propiedad controller establece el controlador que se utilizará para controlar el valor del campo de entrada
                          controller: _categoria,
                          decoration: InputDecoration(
                            labelText: 'Categoría',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color.fromRGBO(158, 217, 217, 1.0),
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
                          controller: _caducidad,
                          onTap: () => _selectDate(context),
                          decoration: InputDecoration(
                            labelText: 'Caducidad',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color.fromRGBO(158, 217, 217, 1.0),
                                  width: 2.0),
                            ),
                            prefixIcon: const Icon(Icons.calendar_today),
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
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color.fromARGB(255, 55, 129, 57)),
                            ),
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final token = prefs.getString('token');
                              print(token);

                              final peso = int.parse(_cantidad.text);

                              final precio = double.parse(_precio.text);

                              // enviar la información del registro al servidor
                              //La petición se envía a través de la URL 'http://127.0.0.1:8000/produc/' y se establecen ciertos encabezados para la autorización del usuario. El cuerpo de la solicitud se define en formato JSON y contiene información sobre un producto, como su clasificación, nombre, imagen, descripción, peso, precio, dirección, fecha y unidad de peso.
                              //Si la respuesta del servidor tiene un código de estado igual a 201 no se enviara nada,
                              final response = await http.post(
                                Uri.parse('$url/produc/'),
                                headers: {
                                  'Authorization': '$token',
                                },
                                body: jsonEncode({
                                  'clasific': _categoria.text,
                                  'name': _nombreProducto.text,
                                  'image': imageUrl,
                                  'descrip': _descripcion.text,
                                  'peso': peso,
                                  'price': precio,
                                  'direccion': _direccion.text,
                                  'fecha': _caducidad.text,
                                  'unidad_peso': _unidad,
                                  'cordenadas': cordenadas
                                }),
                              );
                              if (response.statusCode == 201) {
                                // registro exitoso, navegar a la pantalla de inicio

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Inicio()));
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
                            child: const Text('Publicar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        )),
      ),
    );
  }
}
