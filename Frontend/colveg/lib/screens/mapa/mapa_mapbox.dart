import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/card.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';

const MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1Ijoiam9zZW1lcGUiLCJhIjoiY2xpbHo0b3I5MGQweDNlbzJ0Z2J6b2diNCJ9.g1qXwYRuDImpNgNjkYnJlw';

final myPosition = LatLng(0, 0);

class MapMabox extends StatefulWidget {
  const MapMabox({Key? key}) : super(key: key);

  @override
  State<MapMabox> createState() => _MapMaboxState();
}

class _MapMaboxState extends State<MapMabox> {
  String searchData = ' ';
  var point;
  double latitude = 0.0;
  double longitude = 0.0;

  // se obtienen los resultados de la busqueda
  Future<void> search() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$url/sitem/searchUbicacion/$searchData/'),
      headers: {'Authorization': '$token'},
    );

if (response.statusCode == 200) {
  final Map<String, dynamic> responseData = json.decode(response.body);
  if (responseData['search'] != null && responseData['search'].isNotEmpty) {
    setState(() {
      point = responseData['search'];

      if (point != null) {
        setState(() {
          points.addAll(point.map((item) => item['coordinates']));
          
          
        });

        final coordinates = point[0]['coordinates'].split(',');
        latitude = double.parse(coordinates[0].trim());
        longitude = double.parse(coordinates[1].trim());
      }
    });
    print(responseData);
  } else {
    // Mostrar un mensaje si no se encuentran resultados
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No se encontraron resultados'),
          content: Text('No se encontraron resultados para la búsqueda.'),
          actions: [
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
} else {
  throw Exception('Error al obtener los datos de búsqueda');
}



  }
  //-------------------------------------------------------------------------

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

  Future<LatLng> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Error');
      }
    }
    Position position = await Geolocator.getCurrentPosition();
    myPosition.latitude = position.latitude;
    myPosition.longitude = position.longitude;
    return myPosition;
  }

  Future<void> getCurrentPosition() async {
    Position position = (await determinePosition()) as Position;
    print(position.latitude);
    print(position.longitude);
  }

  MapController mapController = MapController();
  List<dynamic> points = [];
  
  @override
  Widget build(BuildContext context) {


    return FutureBuilder<LatLng>(
      future: determinePosition(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error obteniendo la posición'));
        } else {
          LatLng currentPosition = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('Busca tu producto'),
              centerTitle: true,
              backgroundColor: const Color(0xFFF3ECB0),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                  'imageUser'),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Container(
                                width: 1100,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Buscar',
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                  onSubmitted: (value) {
                                    setState(() {
                                      searchData = value;
                                    });
                                    search();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        // SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 70),
                          child: Divider(
                            thickness: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 400,
                    child: FlutterMap(
                      options: MapOptions(
                        center: currentPosition,
                        minZoom: 1,
                        maxZoom: 20,
                        zoom: 18,
                      ),
                      nonRotatedChildren: [
                        TileLayer(
                          urlTemplate:
                              'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                          additionalOptions: {
                            'accessToken': MAPBOX_ACCESS_TOKEN,
                            'id': 'mapbox/streets-v9',
                          },
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: currentPosition,
                              builder: (context) {
                                return Container(
                                  child: const Icon(
                                    Icons.broadcast_on_personal_rounded,
                                    color: Color.fromARGB(255, 68, 71, 255),
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
MarkerLayer(
  markers: List<Marker>.generate(points.length, (index) {
    final coordinates = points[index].split(',');
    final latitude = double.parse(coordinates[0].trim());
    final longitude = double.parse(coordinates[1].trim());
    final id = point[index]['id']; // Agregar el campo 'id' correspondiente
    final name = point[index]['clasific']; // Agregar el campo 'id' correspondiente

    return Marker(
      point: LatLng(latitude, longitude),
      width: 40,
      height: 40,
      anchorPos: AnchorPos.align(AnchorAlign.top),
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
             Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyCard(idProduc: id!, title: name,), // Pasar el 'id' a MyCard
                                ),
                              );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.location_pin,
                color: Color.fromARGB(255, 255, 68, 68),
                size: 40,
              ),
              Positioned(
                top: -20,
                child: Text(
                  'Título del marcador',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }),
),






                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  // List<Marker> _getMarkersWithin20Meters() {
  //   final List<Marker> markers = [];
  //   // Obtener las coordenadas que estén a una distancia de 20 metros o menos de myPosition
  //   for (var i = 0; i < 100; i++) {
  //     // Agregar otra coordenada que esté dentro de los 20 metros
  //     final lat = 4.8083 + (0.0001 * i);
  //     final lng = -74.105 + (0.0001 * i);
  //     final position = LatLng(lat, lng);
  //     final distance = Geolocator.distanceBetween(
  //         myPosition.latitude, myPosition.longitude, lat, lng);
  //     if (distance <= 1000) {
  //       final marker = Marker(
  //         point: position,
  //         builder: (context) {
  //           return GestureDetector(
  //             onTap: () {
  //               showDialog(
  //                 context: context,
  //                 builder: (BuildContext context) {
  //                   return AlertDialog(
  //                     title: const Text('Más información'),
  //                     content: MyCard(),

  //                     actions: <Widget>[
  //                       Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.end,
  //                           crossAxisAlignment: CrossAxisAlignment.end,
  //                           children: [

  //                             TextButton(
  //                               child: const Text('Ir a la publicación'),
  //                               onPressed: () {
  //                                 Navigator.of(context).pop();
  //                               },
  //                             ),
  //                             TextButton(
  //                               child: const Text('Cerrar'),
  //                               onPressed: () {
  //                                 Navigator.of(context).pop();
  //                               },
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   );
  //                 },
  //               );
  //             },
  //             child: Container(
  //               child: CircleAvatar(
  //                 radius: 30,
  //                 backgroundImage: NetworkImage(
  //                     'https://akamai.sscdn.co/uploadfile/letras/fotos/0/c/d/8/0cd84692be900a25db90e462fa8b95c9.jpg'),
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //       markers.add(marker);
  //     }
  //     // Agregar otra coordenada que esté dentro de los 20 metros
  //     final lat2 = 4.8085 + (0.0001 * i);
  //     final lng2 = -74.105 + (0.0001 * i);
  //     final position2 = LatLng(lat2, lng2);
  //     final distance2 = Geolocator.distanceBetween(
  //         myPosition.latitude, myPosition.longitude, lat2, lng2);
  //     if (distance2 <= 10000) {
  //       final marker2 = Marker(
  //         point: position2,
  //         builder: (context) {
  //           return GestureDetector(
  //             onTap: () {
  //               showDialog(
  //                 context: context,
  //                 builder: (BuildContext context) {
  //                   return AlertDialog(
  //                     title: const Text('Más información'),
  //                     content: MyCard(),

  //                     actions: <Widget>[
  //                       Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.end,
  //                           crossAxisAlignment: CrossAxisAlignment.end,
  //                           children: [

  //                             TextButton(
  //                               child: const Text('Ir a la publicación'),
  //                               onPressed: () {
  //                                 Navigator.of(context).pop();
  //                               },
  //                             ),
  //                             TextButton(
  //                               child: const Text('Cerrar'),
  //                               onPressed: () {
  //                                 Navigator.of(context).pop();
  //                               },
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   );
  //                 },
  //               );
  //             },
  //             child: Container(
  //               child: CircleAvatar(
  //                 radius: 30,
  //                 backgroundImage: NetworkImage(
  //                     'https://akamai.sscdn.co/uploadfile/letras/fotos/0/c/d/8/0cd84692be900a25db90e462fa8b95c9.jpg'),
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //       markers.add(marker2);
  //     }
  //   }
  //   return markers;
  // }
}
