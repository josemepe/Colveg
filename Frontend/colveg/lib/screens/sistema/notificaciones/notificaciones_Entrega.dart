//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 14/06/2023
//SENA-CBA 2023

//nos muestra las notificaciones de los pedidos que a entregado

//importaciones de codigo
import 'package:flutter/material.dart';
import '../../menu_navegacion/drawer.dart';
import 'notificaciones_general.dart';
import 'notificaciones_vendidos.dart';

class NotEntrega extends StatefulWidget {
  @override
  _CardPageState createState() => _CardPageState();
}

class _CardPageState extends State<NotEntrega> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF3ECB0),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.bookmark,
              color: Colors.black,
            ),
            onPressed: () {},
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
                //TextButton con el texto "General". El botón tiene un margen horizontal de 15 píxeles. Cuando se presiona el botón,
                // se ejecuta la acción de navegación Navigator.push para ir a la pantalla Notificacion
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Notificacion()));
                    },
                    //ButtonStyle es una clase que define el estilo de un botón.
                    //foregroundColor es una propiedad que establece el color de primer plano del botón, es decir, el color del texto del botón.
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.yellow),
                    ),
                    //muestra un widget Text con el texto "General". 
                    //El texto tiene un tamaño de fuente de 18 puntos, un peso de fuente de 200 (que indica una fuente más ligera) y un color de texto blanco.
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

                //muestra un botón de texto (TextButton) con el texto "vendidos". 
                //El botón tiene un estilo personalizado que establece el color de texto en amarillo. Cuando se presiona el botón, se navega a la página NotVendido
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotVendido()));
                    },
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.yellow),
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

                ////muestra un botón de texto (TextButton) con el texto "Entrega". 
                //El botón tiene un estilo personalizado que establece el color de texto en amarillo. Cuando se presiona el botón, se navega a la página NotVendido
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotEntrega()));
                    },
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.yellow),
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
            //  muestra una fila (Row) con dos elementos hijos. El primer elemento hijo es un contenedor (Container) que contiene un icono (Icon) en forma de círculo.
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
                // con dos elementos hijos. Ambos elementos hijos son textos (Text). El primer texto muestra el nombre "Jhon Chica" con un estilo de fuente personalizado que incluye un tamaño de fuente de 18 puntos, 
                //un peso de fuente en negrita y un color de texto blanco
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
                    // texto muestra el mensaje "compraste un mango" con un estilo de fuente personalizado que incluye un tamaño de fuente de 18 puntos y un peso de fuente en negrita
                    Text(
                      'compraste un mango',
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
