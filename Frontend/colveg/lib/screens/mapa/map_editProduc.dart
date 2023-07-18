import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapEditProduc extends StatefulWidget {
  final String initialCoordinates;

  const MapEditProduc({super.key, required this.initialCoordinates});

  @override
  // ignore: library_private_types_in_public_api
  _MapEditProducState createState() => _MapEditProducState();
}

class _MapEditProducState extends State<MapEditProduc> {
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
    if (widget.initialCoordinates.isNotEmpty) {
    List<String> coordinates = widget.initialCoordinates.split(',');
    double latitude = double.tryParse(coordinates[0].trim()) ?? 0.0;
    double longitude = double.tryParse(coordinates[1].trim()) ?? 0.0;
    LatLng initialLocation = LatLng(latitude, longitude);
    setState(() {
       currentLocation = initialLocation;
      searchController.text =
          '${currentLocation.latitude.toStringAsFixed(5)}, ${currentLocation.longitude.toStringAsFixed(5)}';
      currentMarker = createMarker(currentLocation);
      mapController.move(currentLocation, 18.0); 
      infoGuardar = '${currentLocation.latitude.toStringAsFixed(10)}, ${currentLocation.longitude.toStringAsFixed(10)}';
    });
  }
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
