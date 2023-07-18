//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 29/05/2023
//SENA-CBA 2023

// se trae la pantalla donde podras registrarte

//importaciones de codigo
import 'dart:convert';

import 'package:colveg/screens/login_registro/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../main.dart';
import '../confirmaciones/codigos.dart';
import 'package:shared_preferences/shared_preferences.dart';

//crear una clase de tipo stateles para que el usuario solo pueda   visualizar y llenar campos que se le permitan  todo lo de la pantal
class RegistrarseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Registrarse',
      home: Scaffold(
        //se le pone color al fondo de la pantalla
        // backgroundColor: const Color(0xFF344D67),
        body: Container(
          decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/gif1.gif'), 
          fit: BoxFit.cover, // Ajusta la imagen al tamaño del contenedor
        ),
      ),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centrar verticalmente
          children: [
            Expanded(
              child: Center(
                child: LoginCard(),
              ),
            ),
          ],
              ),
        ),
      ),
    );
  }
}

//se trae la clase de tipo stateful para poder modificar agragar todo lo que queramos
class LoginCard extends StatefulWidget {
  @override
  _LoginCardState createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  //se crean variables de tipo final  para declararla

  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confipasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
//se dedlcara de tipo boll para recibir un dato verdadero o falso
  bool _obscureText = true;
  bool isChecked = false;

  //initState que sobrescribe el método de la clase State en Flutter. El método initState se ejecuta una vez cuando se crea por primera vez el widget en la pantalla.
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  //saveData que recibe dos argumentos: key y value, ambos de tipo String. La función tiene un tipo de retorno Future<void>, lo que significa que no devuelve ningún valor y puede tomar algún tiempo en completarse
  Future<void> saveData(String key, String value) async {
    //getInstance() de la clase SharedPreferences para obtener una instancia de SharedPreferences. Este objeto se usa para almacenar datos de manera persistente en la aplicación
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  //loadData que carga un valor de tipo String de las preferencias compartidas (SharedPreferences) usando una clave (key) como parámetro de entrada. La función devuelve un objeto de tipo Future<String?>, lo que significa que la operaci
  Future<String?> loadData(String key) async {
    //getInstance() de la clase SharedPreferences para obtener una instancia de las preferencias compartidas. Luego, se llama al método getString de la instancia de las preferencias compartidas,
    final prefs = await SharedPreferences.getInstance();
    //Finalmente, se devuelve el objeto String obtenido por el método getString como el resultado de la función.
    return prefs.getString(key);
  }

  //loadData(). Esta función se utiliza para cargar datos guardados previamente en la aplicación y mostrarlos en un campo de texto.
  //Future que no devuelve nada (void). También se declara como una función asíncrona mediante el uso de la palabra clave async.
  Future<void> _loadData() async {
    //loadData() se llama con el argumento 'saved_text' para recuperar el texto guardado previamente en la aplicación. El valor de retorno de loadData() se asigna a la variable savedText
    final String? savedText = await loadData('saved_text');
    //se verifica si savedText no es nulo. Si no es nulo, entonces el valor de savedText se asigna al controlador de texto _textController. Esto significa que el texto recuperado se mostrará en el campo de texto correspondiente en la aplicación
    if (savedText != null) {
      _textController.text = savedText;
    }
  }

  //_saveData, que es asíncrona y no devuelve nada (void). Esta función llama a otra función llamada saveData que también es asíncrona, pero no se muestra en el código proporcionado
  Future<void> _saveData() async {
    //La función await se utiliza para esperar a que la función saveData se complete antes de continuar ejecutando el código en la función _saveData. Esto se hace porque la función saveData es asíncrona
    await saveData('saved_text', _textController.text);
  }

  void dispose() {
    // Limpia los controladores cuando se destruye el widget
    _emailController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _confipasswordController.dispose();
    super.dispose();
  }

  @override
    Widget build(BuildContext context) {
      //se retorna un sixebox que hace la funcion de una caja
      return SizedBox(
        //se le define un ancho y largo
        height: 600.0,
        width: 500.0,
        //se crea una carta
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
                        //se utiliza para centrar un widget
                        Center(
                          // es un widget de Flutter que se utiliza para recortar el contenido de un widget a una forma ovalada.
                          child: ClipOval(
                            child: Image.asset('assets/logo1.jpg'),
                          ),
                        ),
                        //se crea una caja con el sixebox
                        const SizedBox(
                          height: 30,
                        ),
                        //se pone un texto
                        const Text(
                          '¡¡Registrate!!',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        //se crea una caja con el sixebox que nos haga un espacio
                        const SizedBox(height: 13.0),
                        //se crea una caja con el sixebox
                        SizedBox(
                          width: double.infinity,
                          //  es un widget de Flutter que proporciona una entrada de texto con funciones avanzadas como validación
                          child: TextFormField(
                            //La propiedad controller establece el controlador que se utilizará para controlar el valor del campo de entrada
                            controller: _emailController,
                            //La propiedad keyboardType establece el tipo de teclado virtual que se mostrará al usuario al interactuar con el campo de entrada
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
                        const SizedBox(height: 13.0),
                        //se crea una caja con el sixebox
                        SizedBox(
                          width: double.infinity,
                          //  es un widget de Flutter que proporciona una entrada de texto con funciones avanzadas como validación
                          child: TextFormField(
                            //La propiedad controller establece el controlador que se utilizará para controlar el valor del campo de entrada
                            controller: _usernameController,
                            //La propiedad keyboardType establece el tipo de teclado virtual que se mostrará al usuario al interactuar con el campo de entrada
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.people),
                              labelText: 'Nombre de usuario',
                            ),
                          ),
                        ),
                        //se crea una caja con el sixebox que nos haga un espacio
                        const SizedBox(height: 13.0),
                        //se crea una caja con el sixebox
                        SizedBox(
                          width: double.infinity,
                          //  es un widget de Flutter que proporciona una entrada de texto con funciones avanzadas como validación
                          child: TextFormField(
                            //La propiedad controller establece el controlador que se utilizará para controlar el valor del campo de entrada
                            controller: _nameController,
                            //La propiedad keyboardType establece el tipo de teclado virtual que se mostrará al usuario al interactuar con el campo de entrada
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.people),
                              labelText: 'Nombre Real',
                            ),
                          ),
                        ),
                        //se crea una caja con el sixebox que nos haga un espacio
                        const SizedBox(height: 13.0),
                        //se crea una caja con el sixebox
                        SizedBox(
                          width: double.infinity,
                          //  es un widget de Flutter que proporciona una entrada de texto con funciones avanzadas como validación
                          child: TextFormField(
                            //La propiedad controller establece el controlador que se utilizará para controlar el valor del campo de entrada
                            controller: _passwordController,
                            //La propiedad keyboardType establece el tipo de teclado virtual que se mostrará al usuario al interactuar con el campo de entrada
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            obscureText: _obscureText,
                          ),
                        ),
                        const SizedBox(height: 13.0),
                        //se crea una caja con el sixebox
                        SizedBox(
                          width: double.infinity,
                          //  es un widget de Flutter que proporciona una entrada de texto con funciones avanzadas como validación
                          child: TextFormField(
                            //La propiedad controller establece el controlador que se utilizará para controlar el valor del campo de entrada
                            controller: _confipasswordController,
                            //La propiedad keyboardType establece el tipo de teclado virtual que se mostrará al usuario al interactuar con el campo de entrada
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              labelText: 'Confirmar contraseña',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            obscureText: _obscureText,
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                        ),
                        //se crea una caja con el sixebox que nos haga un espacio
                        const SizedBox(height: 5.0),
                        //se crea una fila
                        Row(children: <Widget>[
                          Flexible(
                              //se utiliza para centrar un widget
                              child: Center(
                            //se crea una columna
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    //se crea un texbutton para que sea el texto una especie de boton
                                    TextButton(
                                      child: const Text(
                                          'Acepta Términos y condiciones'),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Términos y condiciones'),
                                              content: const SizedBox(
                                                width: 400,
                                                height: 400,
                                                child: Padding(
                                                  padding: EdgeInsets.all(0.0),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Text(
                                                          'Términos y Condiciones',
                                                          style: TextStyle(
                                                            fontSize: 24.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(height: 16.0),
                                                        Text(
                                                          'Registro',
                                                          style: TextStyle(
                                                            fontSize: 18.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(height: 8.0),
                                                        Text(
                                                          'Para utilizar los servicios de nuestra red social, es necesario registrarse proporcionando información precisa y actualizada. La información personal proporcionada será protegida de acuerdo con nuestra Política de Privacidad.',
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                          ),
                                                        ),
                                                        SizedBox(height: 16.0),
                                                        Text(
                                                          'Contenido',
                                                          style: TextStyle(
                                                            fontSize: 18.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(height: 8.0),
                                                        Text(
                                                          'Usted es responsable del contenido que publique en nuestra red social. No está permitido publicar contenido que sea ilegal, obsceno, difamatorio, amenazante, violento, discriminador, o que infrinja los derechos de propiedad intelectual de terceros. Nos reservamos el derecho de eliminar cualquier contenido que considere inapropiado.',
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                          ),
                                                        ),
                                                        SizedBox(height: 16.0),
                                                        Text(
                                                          'Propiedad intelectual',
                                                          style: TextStyle(
                                                            fontSize: 18.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(height: 8.0),
                                                        Text(
                                                          'Todos los derechos de propiedad intelectual sobre el contenido publicado en nuestra red social pertenecen a sus respectivos propietarios. Usted acepta no copiar, reproducir, distribuir, transmitir, modificar, crear obras derivadas, mostrar públicamente o explotar de cualquier manera dicho contenido sin el consentimiento previo por escrito del propietario correspondiente',
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                          ),
                                                        ),
                                                        SizedBox(height: 16.0),
                                                        Text(
                                                          'Comentarios y mensajes',
                                                          style: TextStyle(
                                                            fontSize: 18.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(height: 8.0),
                                                        Text(
                                                          'La red social puede proporcionar la opción de comentar o enviar mensajes a otros usuarios. Usted acepta no utilizar esta función para enviar spam, contenido no solicitado o mensajes ofensivos. Nos reservamos el derecho de eliminar cualquier comentario o mensaje que consideremos inapropiado.',
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                          ),
                                                        ),
                                                        SizedBox(height: 16.0),
                                                        Text(
                                                          'Privacidad',
                                                          style: TextStyle(
                                                            fontSize: 18.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(height: 8.0),
                                                        Text(
                                                          ' Nos comprometemos a proteger su privacidad de acuerdo con nuestra Política de Privacidad. Usted acepta no compartir información personal de otros usuarios sin su consentimiento.',
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                          ),
                                                        ),
                                                        SizedBox(height: 16.0),
                                                        Text(
                                                          'Terminación',
                                                          style: TextStyle(
                                                            fontSize: 18.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(height: 8.0),
                                                        Text(
                                                          'Nos reservamos el derecho de suspender o cancelar su cuenta en cualquier momento si consideramos que ha violado estos términos y condiciones.',
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                          ),
                                                        ),
                                                        SizedBox(height: 16.0),
                                                        Text(
                                                          'Modificaciones',
                                                          style: TextStyle(
                                                            fontSize: 18.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(height: 8.0),
                                                        Text(
                                                          'Nos reservamos el derecho de modificar estos términos y condiciones en cualquier momento. Se le notificará por correo electrónico o mediante una publicación en nuestra red social.',
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                          ),
                                                        ),
                                                        SizedBox(height: 16.0),
                                                        Text(
                                                          'Ley aplicable',
                                                          style: TextStyle(
                                                            fontSize: 18.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(height: 8.0),
                                                        Text(
                                                          'Estos términos y condiciones se regirán e interpretarán de acuerdo con las leyes del país en el que se encuentra nuestra sede',
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                          ),
                                                        ),
                                                        SizedBox(height: 8.0),
                                                        Text(
                                                          'Al utilizar nuestra red social, usted acepta estos términos y condiciones en su totalidad. Si no está de acuerdo con alguno de estos términos, por favor no utilice nuestra red social.',
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                          ),
                                                        ),
                                                        SizedBox(height: 16.0),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: const Text('Aceptar'),
                                                  onPressed: () {
                                                    setState(() {
                                                      isChecked = true;
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('Rechazar'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    // en Flutter es una casilla de verificación que permite al usuario seleccionar una o más opciones de un conjunto de opciones disponibles
                                    Checkbox(
                                      value: isChecked,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          isChecked = value ?? false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    //se crea un texbutton para que sea el texto una especie de boton
                                    const Text(
                                      ('¿Ya tienes cuenta?'),
                                    ),
                                    //se crea un texbutton para que sea el texto una especie de boton
                                    TextButton(
                                      child: const Text('Click Aquí'),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const LoginScreen()));
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ))
                        ]),
                        //se crea una caja con el sixebox que nos haga un espacio
                        const SizedBox(height: 5.0),
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
                              if (!isChecked) {
                                //ScaffoldMessenger es un widget que se utiliza para mostrar mensajes en la pantalla de una aplicación. Es similar a SnackBar y Dialog, pero se diferencia en que puede ser utilizado en cual
                                ScaffoldMessenger.of(context).showSnackBar(
                                  //SnackBar es un widget que se utiliza para mostrar un mensaje temporal en la parte inferior de la pantalla en Flutter.
                                  const SnackBar(
                                    content: Text(
                                        'Debe aceptar los términos y condiciones.'),
                                  ),
                                );
                                return;
                              }
                              // enviar la información del registro al servidor
                              final response = await http.post(
                                Uri.parse(
                                    '$url/login/register/'),
                                body: jsonEncode({
                                  'email': _emailController.text,
                                  'name': _nameController.text,
                                  'user_name': _usernameController.text,
                                  // 'number_phone': _phoneNumberController.text,
                                  'password1': _passwordController.text,
                                  'password2': _confipasswordController.text,
                                }),
                              );
                              if (response.statusCode == 201 && isChecked) {
                                // registro exitoso, navegar a la pantalla de inicio
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CodVerScreen()));
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
                            //se pone un texto
                            child: const Text('Registrarse'),
                          ),
                        ),
                        //se crea una caja con el sixebox que nos haga un espacio
                        const SizedBox(height: 16.0),
                        //se crea una caja con el sixebox
                        const SizedBox(
                          width: double.infinity,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
