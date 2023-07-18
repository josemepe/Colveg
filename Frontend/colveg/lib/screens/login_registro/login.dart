//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 29/05/2023
//SENA-CBA 2023

// se trae la pantalla inicial donde puede ingresar al home 

//importaciones de codigo

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../main.dart';
import '../home_screen.dart';
import 'Registrarse.dart';
import 'Reset_Password.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
//crear una clase de tipo stateles para que el usuario solo pueda   visualizar y llenar campos que se le permitan  todo lo de la pantalla

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
<<<<<<< HEAD
  Widget build(BuildContext context) {
    return const MaterialApp(
=======
Widget build(BuildContext context) {
    return MaterialApp(
>>>>>>> origin/Chica
      debugShowCheckedModeBanner: false,
      title: 'Login',
      home: Scaffold(
        //se le pone color al fondo de la pantalla
<<<<<<< HEAD
        backgroundColor: Color(0xFF344D67),
        body: SingleChildScrollView(
          child: Column(children: [
            Center(
              //se trae la clase
              child: LoginCard(),
=======
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
>>>>>>> origin/Chica
            ),
          ],
              ),
        ),
      ),
    );

}

}

//
//se trae la clase de tipo stateful para poder modificar agragar todo lo que queramos
class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  _LoginCardState createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  //se crean variables de tipo final  para declararla
  //se dedlcara de tipo boll para recibir un dato verdadero o falso
  final _LoginEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  bool _unauthorizedError = false;
  bool _passwordError = false;

  late ConfettiController
      _confettiController; // Controlador de la animación de confeti

  @override
  void dispose() {
    _confettiController
        .dispose(); // Liberar recursos del controlador de la animación
    super.dispose();
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Creamos un controlador para el confeti
        final confettiController = ConfettiController();

        // Función para cerrar el AlertDialog
        void _closeDialog() {
          Navigator.of(context).pop();
          // Detenemos la emisión del confetti
          // confettiController.stop();
        }

        // Contador de 5 segundos
        Timer(const Duration(seconds: 3), _closeDialog);

        return AlertDialog(
          backgroundColor: const Color(0xFF344D67),
          title: const Text(
            'Bienvenido a ColVeg',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConfettiWidget(
                  confettiController: confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.1,
                  colors: const [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.yellow,
                  ],
                ),
                Center(
                  child: ClipOval(
                    child: Image.asset('assets/logo1.jpg'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
          ],
        );
      },
    );
  }

  // final prefs = SharedPreferences.getInstance();
  // final token = prefs.getString('token');

  @override
  Widget build(BuildContext context) {
    //se retorna un sixebox que hace la funcion de una caja
    return SizedBox(
        //se le define un ancho y largo
        height: 600.0,
        width: 500.0,
        //se crea una carta que contendra campos de login que sera el usuario y contraseña
        child: Card(
            color: const Color(0xFFFAF6D2),
        margin: const EdgeInsets.all(20.0),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            
            //se mete en un SingleChildScrollView para que se pueda deslizar la pantalla de arriba abajo
            child: SingleChildScrollView(
              child: Stack(
                children:  [ 
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                            // const SizedBox(
                            //   height: 30,
                            // ),
                                  
                            //se pone un texto
                            const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            //se crea una caja con el sixebox que nos haga un espacio
                            // const SizedBox(height: 16.0),
                                  
                            //se crea una caja con el sixebox
                            SizedBox(
                              width: double.infinity,
                              //  es un widget de Flutter que proporciona una entrada de texto con funciones avanzadas como validación
                              child: TextFormField(
                                controller: _LoginEmailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.email),
                                  labelText: 'Correo Electronico',
                                  errorText: _unauthorizedError
                                      ? 'Correo incorrecto'
                                      : null,
                                  errorBorder: _unauthorizedError
                                      ? const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.red),
                                        )
                                      : null,
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
                            // const SizedBox(height: 16.0),
                                  
                            //se crea una caja con el sixebox
                            SizedBox(
                              width: double.infinity,
                              child: TextFormField(
                                controller: _passwordController,
                                keyboardType: TextInputType.visiblePassword,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock),
                                  labelText: 'Password',
                                  errorText: _passwordError
                                      ? 'contraseña incorrecta'
                                      : null,
                                  errorBorder: _unauthorizedError
                                      ? const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.red),
                                        )
                                      : null,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                    //es un widget que se utiliza para mostrar iconos
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
                            //se crea un texbutton para que sea el texto una especie de boton
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  //se crea un texbutton para que sea el texto una especie de boton
                                  const Text(
                                    ('¿Olvidaste tú contraseña?'),
                                  ),
                                  //se crea un texbutton para que sea el texto una especie de boton
                                  TextButton(
                                    child: const Text('Click Aquí'),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ResetPassword()));
                                    },
                                  ),
                                ],
                              ),
                            ),
                                  
                            //se crea una caja con el sixebox que nos haga un espacio
                            const SizedBox(height: 25.0),
                                  
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          const Color.fromARGB(
                                              255, 55, 129, 57)),
                                ),
                                onPressed: () async {
                                  print(registrationToken);
                                  // enviar la información del registro al servidor
                                  final response = await http.post(
                                    Uri.parse(
                                        '$url/login/login/'),
                                    body: jsonEncode({
                                      'email': _LoginEmailController.text,
                                      'password_login':
                                          _passwordController.text,
                                      'mensajes': registrationToken 
                                    }),
                                  );
                                  if (response.statusCode == 401) {
                                    setState(() {
                                      _unauthorizedError = true;
                                    });
                                  } else {
                                    if (response.statusCode == 500) {
                                      setState(() {
                                        _passwordError = true;
                                      });
                                    } else {
                                      if (response.statusCode == 201) {
                                        final token = json
                                            .decode(response.body)['token'];
                                        // guardar el token en SharedPreferences
                                        final prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        await prefs.setString(
                                            'token', token);
                                        print(token);
                                        // obtener el token del cuerpo de la respuesta
                                  
                                        // registro exitoso, navegar a la pantalla de inicio
                                        _confettiController =
                                            ConfettiController(
                                                duration: const Duration(
                                                    seconds:
                                                        1)); // Inicializar el controlador de la animación
                                        _confettiController
                                            .play(); // Reproducir la animación de confeti al abrir la pantalla
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          _showAlertDialog(
                                              context); // Mostrar el AlertDialog después de que se construya la pantalla
                                        });
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Inicio(),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          //se utiliza para mostrar mensajes cortos y temporales en la parte inferior de la pantalla
                                          const SnackBar(
                                            content: Text(
                                                'El correo electronico o la contraseña no son validos intente de nuevo'),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                //se crea un texto
                                child: const Text('Iniciar sesion'),
                              ),
                            ),
                            //se crea una fila
                            Row(
                              //MainAxisAlignment se utiliza para alinear los widgets secundarios en el eje principal del contenedor.
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                //se pone un texto
                                const Text(
                                  '¿No tienes cuenta?',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                //se crea un texbutton para que sea el texto una especie de boton
                                TextButton(
                                  child: const Text('Registrarse'),
                                  onPressed: () {
                                    //registro exitoso, navegar a la pantalla de RegistrarseScreen
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RegistrarseScreen()));
                                  },
                                ),
                              ],
                            ),
                          ])
                    ]),
                ]
              ),
            )))));
  }
}
