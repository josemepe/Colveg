//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 29/05/2023
//SENA-CBA 2023

// se trae la pantalla donde podras resetear la contraseña 

//importaciones de codigo
import 'package:flutter/material.dart';
import '../../main.dart';
import 'Login.dart';
import 'package:http/http.dart' as http;

//crear una clase de tipo stateles para que el usuario solo pueda   visualizar y llenar campos que se le permitan  todo lo de la pantalla
class ResetPassword extends StatelessWidget {
  const ResetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recuperar Contraseña',
      home: Scaffold(
        //se le pone color al fondo de la pantalla
        backgroundColor: Color(0xFF344D67),
        body: Center(
          //se trae la clase
          child: LoginCard(),
        ),
      ),
    );
  }
}

//se trae la clase de tipo stateful para poder modificar agragar todo lo que queramos
class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  _LoginCardState createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  //se crean variables de tipo final  para declararla
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    //se retorna un sixebox que hace la funcion de una caja
    return SizedBox(
      height: 900.0,
      width: 900.0,
      child: Card(
        color: const Color(0xFFFAF6D2),
        margin: const EdgeInsets.all(20.0),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            //se pone para superponer elementos encima de otros
            child: Stack(
              children: [
                Column(
                  //MainAxisAlignment se utiliza para alinear los widgets secundarios en el eje principal del contenedor.
                  //CrossAxisAlignment se utiliza para alinear los widgets secundarios en el eje transversal del contenedor,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      // es un widget de Flutter que se utiliza para recortar el contenido de un widget a una forma ovalada.
                      child: ClipOval(
                        child: Image.asset('assets/logo1.jpg'),
                      ),
                    ),
                    //se crea una caja con el sixebox
                    const SizedBox(
                      height: 70,
                    ),
                    //se pone un texto
                    const Text(
                      'Recuperar Contraseña',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    //se crea una caja con el sixebox que nos haga un espacio
                    const SizedBox(height: 16.0),
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
                          } else if (!RegExp(r'^[\w-.]+@([\w-]+.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Por favor ingresa un correo electrónico válido';
                          }
                          return null;
                        },
                      ),
                    ),
                    //se crea una caja con el sixebox que nos haga un espacio
                    const SizedBox(height: 16.0),
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
                          // enviar la información del registro al servidor
                          final response = await http.post(
                            Uri.parse('$url/login/recuperar/'),
                            body: {
                              'email': _emailController.text,
                            },
                          );
                          if (response.statusCode == 201) {
                            // registro exitoso, navegar a la pantalla de inicio
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>  LoginScreen()));

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Se a enviado un correo electroncio para restablecer la contraseña'),
                              ),
                            );
                          } else {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Este correo no esta registrado'),
                              ),
                            );
                          }
                        },
                        //se pone un texto
                        child: const Text('Enviar'),
                      ),
                    ),
                    //se crea una caja con el sixebox que nos haga un espacio
                    const SizedBox(height: 7.0),
                    //se crea una fila
                    Row(
                      //MainAxisAlignment se utiliza para alinear los widgets secundarios en el eje principal del contenedor.
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        //se pone un texto
                        const Text(
                          '¿Quieres volver?',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        //se crea un texbutton para que sea el texto una especie de boton
                        TextButton(
                          child: const Text('Click aquí'),
                          onPressed: () {
                            //registro exitoso, navegar a la pantalla de inicio
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
