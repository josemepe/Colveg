//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 18/06/2023
//SENA-CBA 2023

// se trae una pantalla LA CAMARA PARA ESCANEAR EL QR

//importaciones de codigo

import 'dart:convert';
import 'dart:io';


import 'package:colveg/screens/sistema/qr/qrInfoScaner.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:async';

import '../../../main.dart';
import '../guardados/guardados.dart';

class scanerQr extends StatefulWidget {
  @override
   State<scanerQr> createState() => _scanerQrState();
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



class _scanerQrState extends State<scanerQr> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // - 'userName' de tipo 'String' para almacenar el nombre del usuario (inicialmente vacío)
  String userName = ' ';
  // - 'userId' de tipo 'String' para almacenar la ID del usuario (inicialmente vacío)
  String userId = ' ';
  // - 'imageUser' de tipo 'String' para almacenar la imagen del usuario (inicialmente vacía)
  String imageUser = ' ';
  // - 'is_admin' of type 'bool' to indicate if the user is an admin (initially false)
  bool is_admin = false;

  @override
  void initState() {
    super.initState();
    // Obtener la información del usuario y almacenarlas en variables globales para su posterior uso
    getUser().then((value) {
      setState(() {
        userName = value['usuario'][0]['user_name'];
        imageUser = value['usuario'][0]['image_user'];
        userId = value['usuario'][0]['id'];
        is_admin = value['usuario'][0]['is_admin'];
        print(userName);
      });
    });
  }

  @override
 void reassemble() {
  super.reassemble();  // Llama al método "reassemble()" de la superclase

  if (Platform.isAndroid || Platform.isIOS) {
    controller!.resumeCamera();  // Resumen la cámara si la plataforma es Android o iOS
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    imageUser,
                  ),
                  radius: 12,
                ),
              );
            },
          ),
          //se pone un texto
          title: Text(
            userName,
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
      body: Column(
  children: <Widget>[
    // Si la plataforma es Android, muestra esta sección
    if (Platform.isAndroid)
      Expanded(
        flex: 5,
        child: Stack(
          children: [
            // Vista del escáner QR
            QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red, // Color del borde del escáner
                borderRadius: 12, // Radio de borde del escáner
                borderLength: 24, // Longitud de borde del escáner
                borderWidth: 4, // Ancho del borde del escáner
                cutOutSize: 200, // Tamaño del área recortada del escáner
              ),
            ),
            
            // Cuadro central en el escáner
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.red, // Color del borde del cuadro central
                    width: 2.0, // Ancho del borde del cuadro central
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
  ],
),

    );
  }

void _onQRViewCreated(QRViewController controller) {
  this.controller = controller;
  
  // Listen to the scanned data stream
  controller.scannedDataStream.listen((scanData) {
    result = scanData;
    
    if (result != null) {
      print('${result!.code}');  // Print the scanned code
      print('scaneado');  // Print 'scaneado' (scanned in Spanish)
      
      // Retrieve the JSON string from the scanned code
      String jsonString = result!.code!;
      
      try {
        // Decode the JSON string into a map of key-value pairs
        Map<String, dynamic> decodedData = jsonDecode(jsonString);
        
        // Extract specific values from the decoded data
        String clasific = decodedData['clasific'];
        String image = decodedData['image'];
        int orden = decodedData['cantidad'];
        String id = decodedData['id'];
        String autor = decodedData['autor'];
        String fecha = decodedData['fecha'];
        String ubicacion = decodedData['ubicacion'];
        int valor = decodedData['valor'];
        
        // Navigate to the QRInfoScreen with the extracted data
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QRInfoScreen(
              clasific: clasific,
              image: image,
              orden: orden,
              id: id, 
              autor: autor, 
              fecha: fecha, 
              ubicacion: ubicacion, 
              valor: valor,
            ),
          ),
        );
      } catch (e) {
        print('Error al decodificar el JSON: $e');  // Print an error message if JSON decoding fails
      }
    }
  });
}

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}