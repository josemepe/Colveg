//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 29/05/2023
//SENA-CBA 2023

// se trae una pantalla donde tendras que poner el codigo que le llego al correo

//importaciones de codigo
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../main.dart';
import '../login_registro/Login.dart';

//crear una clase de tipo stateles para que el usuario solo pueda   visualizar y llenar campos que se le permitan  todo lo de la pantalla
class CodVerScreen extends StatelessWidget {
  const CodVerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '',
      home: Scaffold(
        //se le pone color al fondo de la pantalla
        backgroundColor: Color(0xFF344D67),
        body: Center(
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
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _validateEmail(String? value) {
    if (value != null &&
        value.isNotEmpty &&
        value.length == 6 &&
        int.tryParse(value) != null) {
      return null;
    } else {
      return 'Solo 6 números enteros';
    }
  }

  @override
  Widget build(BuildContext context) {
    //se retorna un sixebox que hace la funcion de una caja
    return SizedBox(
      //se le define un ancho y largo
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
                      //se utiliza para centrar un widget
                      Center(
                        child: Image.asset('assets/logo1.jpg'),
                      ),
                      //se crea una caja con el sixebox
                      const SizedBox(
                        height: 30,
                      ),
                      //se pone un texto
                      const Text(
                        'Enviamos un código a tú',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      //se pone un texto
                      const Text(
                        'correo y telfono',
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
                          controller: _emailController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            labelText: 'Código Correo Electronico',
                          ),
                          validator: _validateEmail,
                        ),
                      ),
                      //se crea una caja con el sixebox que nos haga un espacio
                      const SizedBox(height: 16.0),
                      //se crea una caja con el sixebox
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: TextFormField(
                      //     controller: _phoneController,
                      //     keyboardType: TextInputType.number,
                      //     decoration: InputDecoration(
                      //       prefixIcon: Icon(Icons.phone),
                      //       labelText: 'Código de Teléfono',
                      //     ),
                      //     validator: _validateEmail,
                      //   ),
                      // ),
                      // //se crea una caja con el sixebox que nos haga un espacio
                      // SizedBox(height: 16.0),
                      //se crea una caja con el sixebox
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color.fromARGB(255, 55, 129, 57)),
                          ),
                          onPressed: () async {
                            // enviar la información del registro al servidor
                            final response = await http.post(
                              Uri.parse(
                                  '$url/login/verificar/'),
                              body: {
                                'code_email': _emailController.text,
                                // 'code_phone': _phoneController.text,
                              },
                            );
                            if (response.statusCode == 201) {
                              // registro exitoso, navegar a la pantalla de inicio
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                           LoginScreen()));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'El codigo de email o phone estan mal porfavor intente de nuevo'),
                                ),
                              );
                            }
                          },
                          child: const Text('Enviar'),
                        ),
                      ),
                      //se crea una caja con el sixebox que nos haga un espacio
                      const SizedBox(height: 16.0),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //se pone un texto
                          const Text(
                            '¿Quieres volver?',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          TextButton(
                            child: const Text('Click aquí'),
                            onPressed: () {
                              // TODO
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
      ),
    );
  }
}
