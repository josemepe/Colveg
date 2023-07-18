//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 14/06/2023
//SENA-CBA 2023

//nos muestra las notificaciones de los pedidos que has vendido

//importaciones de codigo
import 'package:colveg/screens/sistema/notificaciones/notificaciones_Entrega.dart';
import 'package:flutter/material.dart';
import '../../menu_navegacion/drawer.dart';
import 'notificaciones_general.dart';

class NotVendido extends StatefulWidget {
  @override
  _CardPageState createState() => _CardPageState();
}

class _CardPageState extends State<NotVendido> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 250, 250),

      appBar: AppBar(
  // Establece el color de fondo de la barra de aplicaciones como un tono amarillo claro
  backgroundColor: Color(0xFFF3ECB0),
  leading: Builder(
    builder: (BuildContext context) {
      return IconButton(
        // Muestra el icono de menú con color negro
        icon: const Icon(
          Icons.menu,
          color: Colors.black,
        ),
        onPressed: () {
          // Abre el panel lateral cuando se presiona el icono de menú
          Scaffold.of(context).openDrawer();
        },
      );
    },
  ),
  actions: <Widget>[
    IconButton(
      // Muestra el icono de marcador con color negro
      icon: const Icon(
        Icons.bookmark,
        color: Colors.black,
      ),
      onPressed: () {
        // Realiza una acción no especificada cuando se presiona el icono de marcador
      },
    ),
  ],
),


      //MENU
      drawer: const MyDrawer(),

      //CUERPO APP
      body: Column(
        children: [
          Container(
            color: const Color(0xFF344D67),
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
  padding: const EdgeInsets.symmetric(horizontal: 15),
  child: TextButton(
    onPressed: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Notificacion()));
    },
    style: ButtonStyle(
      foregroundColor:
          MaterialStateProperty.all<Color>(Colors.yellow),
    ),
    child: const Text(
      'General',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w200,
        color: Colors.white,
      ),
    ),
  ),
),

                Padding(
  padding: const EdgeInsets.symmetric(horizontal: 15),
  child: TextButton(
    onPressed: () {
      // Navega a la página 'NotVendido' cuando se presiona el botón
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NotVendido()),
      );
    },
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
    ),
    child: const Text(
      'vendidos',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w200,
        color: Colors.white,
      ),
    ),
  ),
),

                Padding(
  padding: const EdgeInsets.symmetric(horizontal: 15),
  child: TextButton(
    onPressed: () {
      // Navega a la página 'NotEntrega' cuando se presiona el botón
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NotEntrega()),
      );
    },
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
    ),
    child: const Text(
      'Entrega',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w200,
        color: Colors.white,
      ),
    ),
  ),
),

              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
  color: const Color(0xFF344D67),

  child: Row(
    children: [
      Container(
        margin: const EdgeInsets.all(10),
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: const Icon(Icons.person, color: Color(0xFF344D67)),
      ),

      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jhon Chica',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'has vendido un mango',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ],
  ),
),

        ],
      ),
    );
  }
}
