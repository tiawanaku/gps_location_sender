import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS Location Sender',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LocationSender(),
    );
  }
}

class LocationSender extends StatefulWidget {
  @override
  _LocationSenderState createState() => _LocationSenderState();
}

class _LocationSenderState extends State<LocationSender> {
  String _locationMessage = "Presiona el botón para obtener la ubicación";

  Future<void> _getLocationAndSend() async {
    // Solicitar permisos usando permission_handler
    PermissionStatus status = await Permission.locationWhenInUse.request();
    if (status != PermissionStatus.granted) {
      setState(() {
        _locationMessage = "Permiso de ubicación denegado";
      });
      return;
    }

    // Obtener la posición actual
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // Formatear la posición en un JSON
    Map<String, dynamic> locationData = {
      "latitude": position.latitude,
      "longitude": position.longitude,
    };

    String jsonLocation = jsonEncode(locationData);

    // Enviar la ubicación al endpoint
    try {
      final response = await http.post(
        Uri.parse('http://64.225.54.113:8046/gps'),
        //headers: {"Content-Type": "application/json"},
        body: jsonLocation,
      );

      if (response.statusCode == 200) {
        setState(() {
          _locationMessage = "Ubicación enviada: ${jsonLocation}";
        });
      } else {
        setState(() {
          _locationMessage = "Error al enviar la ubicación: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _locationMessage = "Error de red: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enviar Ubicación GPS'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _locationMessage,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getLocationAndSend,
              child: Text('Obtener y Enviar Ubicación'),
            ),
          ],
        ),
      ),
    );
  }
}
