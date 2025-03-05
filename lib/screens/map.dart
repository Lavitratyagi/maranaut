import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatelessWidget {
  final double startLat;
  final double startLng;
  final double destLat;
  final double destLng;

  const MapPage({
    Key? key,
    required this.startLat,
    required this.startLng,
    required this.destLat,
    required this.destLng,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startLatLng = LatLng(startLat, startLng);
    final destLatLng = LatLng(destLat, destLng);
    // Calculate a midpoint to center the map.
    final center = LatLng((startLat + destLat) / 2, (startLng + destLng) / 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Route Map"),
        backgroundColor: const Color(0xFF021934),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: 5, // Adjust zoom as needed
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.yourapp',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: startLatLng,
                width: 80.0,
                height: 80.0,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              Marker(
                point: destLatLng,
                width: 80.0,
                height: 80.0,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 40,
                ),
              ),
            ],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: [startLatLng, destLatLng],
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
