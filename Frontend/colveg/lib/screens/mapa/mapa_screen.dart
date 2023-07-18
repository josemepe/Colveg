import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapsScreen extends StatefulWidget {
  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final TextEditingController searchController = TextEditingController();
  final MapController mapController = MapController();
  LatLng currentLocation = LatLng(0.0, 0.0);
  Marker? currentMarker;
  String infoGuardar = ' ';

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      searchController.text =
          '${currentLocation.latitude.toStringAsFixed(5)}, ${currentLocation.longitude.toStringAsFixed(5)}';
      currentMarker = createMarker(currentLocation);
      mapController.move(currentLocation, 18.0); 
      infoGuardar = '${currentLocation.latitude.toStringAsFixed(10)}, ${currentLocation.longitude.toStringAsFixed(10)}';
    });
  }

  void searchLocation() {
    String coordinates = searchController.text;
    List<String> parts =
        coordinates.split(',').map((part) => part.trim()).toList();
    if (parts.length != 2) return;

    double? latitude = double.tryParse(parts[0]);
    double? longitude = double.tryParse(parts[1]);
    if (latitude == null || longitude == null) return;

    LatLng location = LatLng(latitude, longitude);
    setState(() {
      currentLocation = location;
      currentMarker = createMarker(location);
    });
    mapController.move(location, mapController.zoom);
  }

  void saveLocation() {
    String coordinates = searchController.text;
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 77, 113, 151), // Cambiar el color de fondo del AlertDialog
        title: Text(
          '¿Deseas guardar la siguiente dirección?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder(
              future: getAddressFromCoordinates(currentLocation),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
               
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error obteniendo la dirección');
                } else {
                  // String address = snapshot.data ?? '';
                  //   setState(() {
                  //     infoGuardar = address;
                  //   });
                  return Text(
                    snapshot.data!,
                    style: TextStyle(color: Colors.white),
                  );
                  
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // setState(() {
                  //   infoGuardar = snapshot.data!;
                  // });
              Navigator.pop(context, infoGuardar);
            },
            child: Text(
              'Aceptar',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void goToCurrentLocation() {
    mapController.move(currentLocation, mapController.zoom);
  }

  Marker createMarker(LatLng position) {
  return Marker(
    width: 80.0,
    height: 80.0,
    point: position,
    builder: (ctx) => GestureDetector(
      onTap: () async {
        String address = await getAddressFromCoordinates(position);
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            backgroundColor: Color.fromARGB(255, 77, 113, 151), // Cambiar el color de fondo del AlertDialog
            title: Text(
              'Dirección:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: Text(
              address,
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cerrar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        child: Tooltip(
          message: 'Más información',
          child: Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 50.0,
          ),
        ),
      ),
    ),
  );
}

  

  Future<String> getAddressFromCoordinates(LatLng position) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final address = jsonResponse['display_name'];
      // setState(() {
      //   infoPosition = address;
      // });
      return address;
    } else {
      return 'Dirección desconocida';
    }
  }

  void updateCoordinates(LatLng position) {
    setState(() {
      searchController.text =
          '${position.latitude.toStringAsFixed(11)}, ${position.longitude.toStringAsFixed(11)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Busca tú establecimiento'),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },)
        ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: currentLocation,
              zoom: 50.0,
              onTap: (tapPosition, point) {
                setState(() {
                  currentLocation = point;
                  currentMarker = createMarker(point);
                  updateCoordinates(point);
                });
              },
            ),
            nonRotatedChildren: [
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=pk.eyJ1Ijoiam9zZW1lcGUiLCJhIjoiY2xpbHo0b3I5MGQweDNlbzJ0Z2J6b2diNCJ9.g1qXwYRuDImpNgNjkYnJlw',
                additionalOptions: const {
                  'accessToken':
                      'pk.eyJ1Ijoiam9zZW1lcGUiLCJhIjoiY2xpbHo0b3I5MGQweDNlbzJ0Z2J6b2diNCJ9.g1qXwYRuDImpNgNjkYnJlw',
                  'id': 'mapbox.streets',
                },
              ),
              MarkerLayer(markers: currentMarker != null ? [currentMarker!] : []),
            ],
          ),
          Positioned(
            top: 20.0,
            right: 20.0,
            child: Container(
              width: 300.0,
              height: 50.0,
              decoration: BoxDecoration(
                color: Color.fromARGB(197, 62, 197, 238),
                borderRadius: BorderRadius.circular(0.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Ingresa coordenadas',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    onPressed: searchLocation,
                    icon: Icon(Icons.search),
                    color: Colors.white,
                    tooltip: 'Buscar',
                    splashColor: Color.fromARGB(255, 135, 200, 230),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
            floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: goToCurrentLocation,
            child: Icon(Icons.location_on),
            tooltip: 'Ir a ubicación actual',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () async {
                  final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${currentLocation.latitude}&lon=${currentLocation.longitude}';
            final response = await http.get(Uri.parse(url));
            if (response.statusCode == 200) {
              final jsonResponse = json.decode(response.body);
              final address = jsonResponse['display_name'];
              setState(() {
                infoGuardar = '${currentLocation.latitude}, ${currentLocation.longitude}';
              });
              List<String> resultados = [address, infoGuardar];
              Navigator.pop(context, resultados);
              return address;
            } else {
              return;
            }
            
            
            },
            child: Icon(Icons.save),
            tooltip: 'Guardar ubicación',
          ),
        ],
     ),
  );
  }
}

// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// const MAPBOX_ACCESS_TOKEN =
//     'pk.eyJ1Ijoiam9zZW1lcGUiLCJhIjoiY2xpbHo0b3I5MGQweDNlbzJ0Z2J6b2diNCJ9.g1qXwYRuDImpNgNjkYnJlw';

// final myPosition = LatLng(0, 0);

// class BuscarUbicacionScreen extends StatelessWidget {
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Buscar Ubicación'),
//       ),
//       body: Container(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               decoration: InputDecoration(
//                 labelText: 'Busca tu ubicación',
//                 labelStyle: TextStyle(color: Colors.black),
//                 suffixIcon: IconButton(
//                   icon: Icon(Icons.search),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => MapaScreen(),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MapaScreen extends StatefulWidget {
//   @override
//   _MapaScreenState createState() => _MapaScreenState();
// }

// class _MapaScreenState extends State<MapaScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   LatLng? ubicacionSeleccionada;
//   LatLng myPosition = LatLng(0, 0);
//   LatLng? searchPosition;
//   String savedCoordinate = '';
//   String currentCoordinate = '';

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<LatLng> determinePosition() async {
//   LocationPermission permission;
//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       // Utilizar coordenadas por defecto si se deniega el permiso
//       return LatLng(4.809860605186174, -74.09973810356246);
//     }
//   }
  
//     @override
//   void initState() {
//     super.initState();
//     determinePosition().then((LatLng position) {
//       setState(() {
//         myPosition = position;
//         currentCoordinate = '${position.latitude}, ${position.longitude}';
//         _searchController.text = currentCoordinate;
//       });
//     });
//   }



//   Position position = await Geolocator.getCurrentPosition(
//     desiredAccuracy: LocationAccuracy.high,
//   );

//   if (position != null) {
//     myPosition = LatLng(position.latitude, position.longitude);
//     return myPosition;
//   } else {
//     // Utilizar coordenadas por defecto si no se pueden obtener las coordenadas actuales
//     return LatLng(4.809860605186174, -74.09973810356246);
//   }
// }


//   void searchCoordinate() {
//     String coordinateText = _searchController.text.trim();
//     List<String> coordinates = coordinateText.split(',');
//     if (coordinates.length == 2) {
//       double latitude = double.tryParse(coordinates[0]) ?? 0;
//       double longitude = double.tryParse(coordinates[1]) ?? 0;
//       if (latitude != 0 && longitude != 0) {
//         setState(() {
//           searchPosition = LatLng(latitude, longitude);
//           savedCoordinate = coordinateText; // Guardar la coordenada ingresada
//           print(savedCoordinate); // Imprimir la coordenada en la terminal
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<LatLng>(
//       future: determinePosition(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return const Center(child: Text('Error obteniendo la posición'));
//         } else {
//           LatLng currentPosition = snapshot.data!;
//           return Scaffold(
//             appBar: AppBar(
//               title: const Text('MapaScreen'),
//             ),
//             body: Stack(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16.0),
//                   child: FlutterMap(
//                     options: MapOptions(
//                       center: searchPosition ?? currentPosition,
//                       minZoom: 5,
//                       maxZoom: 25,
//                       zoom: 18,
//                     ),
//                     nonRotatedChildren: [
//                       TileLayer(
//                         urlTemplate:
//                             'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
//                         additionalOptions: const {
//                           'accessToken': MAPBOX_ACCESS_TOKEN,
//                           'id': 'mapbox/streets-v9'
//                         },
//                       ),
//                       MarkerLayer(
//                         markers: [
//                           Marker(
//                             point: currentPosition,
//                             builder: (context) {
//                               return Container(
//                                 child: const Icon(
//                                   Icons.person_pin,
//                                   color: Colors.blueAccent,
//                                   size: 40,
//                                 ),
//                               );
//                             },
//                           ),
//                           if (searchPosition != null)
//                             Marker(
//                               point: searchPosition!,
//                               builder: (context) {
//                                 return Container(
//                                   child: const Icon(
//                                     Icons.location_pin,
//                                     color: Colors.redAccent,
//                                     size: 40,
//                                   ),
//                                 );
//                               },
//                             ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Align(
//                     alignment: Alignment.topRight,
//                     child: Container(
//                       constraints: const BoxConstraints(maxWidth: 300),
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           TextField(
//                             controller: _searchController,
//                             style: const TextStyle(
//                               color: Colors.white, // Texto en blanco
//                             ),
//                             decoration: const InputDecoration(
//                               prefixIcon: Icon(
//                                 Icons.search,
//                                 color:
//                                     Colors.white, // Color del icono en blanco
//                               ),
//                               hintText: 'Busca tu ubicación aquí',
//                               filled: true, // Rellenar con el fondo blanco
//                               fillColor: Color.fromARGB(
//                                   197, 62, 197, 238), // Color de relleno blanco
//                               border: OutlineInputBorder(
//                                 borderSide: BorderSide.none, // Sin borde
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 8.0),
//                           ElevatedButton(
//                             onPressed: searchCoordinate,
//                             child: const Text('Buscar'),
//                           ),
//                           const SizedBox(height: 8.0),
//                           ElevatedButton(
//                             onPressed: () {
//                               Navigator.pop(context, savedCoordinate); 
//                               // Navigator.pop(context, savedCoordinate);
                              
//                             },
//                             child: const Text('Guardar Ubicación'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           );
//         }
//       },
//   );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// const MAPBOX_ACCESS_TOKEN =
//     'pk.eyJ1Ijoiam9zZW1lcGUiLCJhIjoiY2xpbHo0b3I5MGQweDNlbzJ0Z2J6b2diNCJ9.g1qXwYRuDImpNgNjkYnJlw';

// final myPosition = LatLng(0, 0);

// class BuscarUbicacionScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Buscar Ubicación'),
//       ),
//       body: Container(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               decoration: InputDecoration(
//                 labelText: 'Busca tu ubicación',
//                 labelStyle: TextStyle(color: Colors.black),
//                 suffixIcon: IconButton(
//                   icon: Icon(Icons.search),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => MapaScreen(),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MapaScreen extends StatefulWidget {
//   @override
//   _MapaScreenState createState() => _MapaScreenState();
// }

// class _MapaScreenState extends State<MapaScreen> {
//   TextEditingController _searchController = TextEditingController();
//   LatLng myPosition = LatLng(0, 0);
//   LatLng? searchPosition;
//   String savedCoordinate = '';
//   String currentCoordinate = '';

//   @override
//   void initState() {
//     super.initState();
//     determinePosition().then((LatLng position) {
//       setState(() {
//         myPosition = position;
//         currentCoordinate = '${position.latitude}, ${position.longitude}';
//         _searchController.text = currentCoordinate;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<LatLng> determinePosition() async {
//     LocationPermission permission;
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Error');
//       }
//     }
//     Position position = await Geolocator.getCurrentPosition();
//     myPosition = LatLng(position.latitude, position.longitude);
//     return myPosition;
//   }

//   void searchCoordinate() {
//     String coordinateText = _searchController.text.trim();
//     List<String> coordinates = coordinateText.split(',');
//     if (coordinates.length == 2) {
//       double latitude = double.tryParse(coordinates[0]) ?? 0;
//       double longitude = double.tryParse(coordinates[1]) ?? 0;
//       if (latitude != 0 && longitude != 0) {
//         setState(() {
//           searchPosition = LatLng(latitude, longitude);
//           savedCoordinate = coordinateText;
//           currentCoordinate = coordinateText;
//           print(savedCoordinate);
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<LatLng>(
//       future: determinePosition(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return const Center(child: Text('Error obteniendo la posición'));
//         } else {
//           LatLng currentPosition = snapshot.data!;
//           return Scaffold(
//             appBar: AppBar(
//               title: Text('MapaScreen'),
//             ),
//             body: Stack(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(16.0),
//                   child: GestureDetector(
//                     onDoubleTap: () {
//                       setState(() {
                        
//                       });
//                     },
//                     child: FlutterMap(
//                       options: MapOptions(
//                         center: searchPosition ?? currentPosition,
//                         minZoom: 5,
//                         maxZoom: 25,
//                         zoom: 18,
//                       ),
//                       nonRotatedChildren: [
//                         TileLayer(
//                           urlTemplate:
//                               'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
//                           additionalOptions: {
//                             'accessToken': MAPBOX_ACCESS_TOKEN,
//                             'id': 'mapbox/streets-v9'
//                           },
//                         ),
//                         MarkerLayer(
//                           markers: [
//                             Marker(
//                               point: currentPosition,
//                               builder: (context) {
//                                 return Container(
//                                   child: const Icon(
//                                     Icons.person_pin,
//                                     color: Colors.blueAccent,
//                                     size: 40,
//                                   ),
//                                 );
//                               },
//                             ),
//                             if (searchPosition != null)
//                               Marker(
//                                 point: searchPosition!,
//                                 builder: (context) {
//                                   return Container(
//                                     child: const Icon(
//                                       Icons.location_pin,
//                                       color: Colors.redAccent,
//                                       size: 40,
//                                     ),
//                                   );
//                                 },
//                               ),
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(8.0),
//                   child: Align(
//                     alignment: Alignment.topRight,
//                     child: Container(
//                       constraints: BoxConstraints(maxWidth: 300),
//                       padding: EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           TextField(
//                             controller: _searchController,
//                             style: TextStyle(
//                               color: Colors.white,
//                             ),
//                             decoration: InputDecoration(
//                               prefixIcon: Icon(
//                                 Icons.search,
//                                 color: Colors.white,
//                               ),
//                               hintText: 'Busca tu ubicación aquí',
//                               filled: true,
//                               fillColor: Color.fromARGB(197, 62, 197, 238),
//                               border: OutlineInputBorder(
//                                 borderSide: BorderSide.none,
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 8.0),
//                           ElevatedButton(
//                             onPressed: searchCoordinate,
//                             child: Text('Buscar'),
//                           ),
//                           SizedBox(height: 8.0),
//                           ElevatedButton(
//                             onPressed: () {
//                               print(savedCoordinate);
//                             },
//                             child: Text('Guardar Ubicación'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           );
//         }
//       },
//     );  
// }
// }
