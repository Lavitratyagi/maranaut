import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  final String shipId;
  final List<dynamic> route; // Expected route data: list of [longitude, latitude]

  const MapPage({
    super.key,
    required this.shipId,
    required this.route,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    // Convert the route data to a list of LatLng.
    List<LatLng> polylinePoints = widget.route.map<LatLng>((point) {
      double lon = point[0] is double ? point[0] : double.parse(point[0].toString());
      double lat = point[1] is double ? point[1] : double.parse(point[1].toString());
      return LatLng(lat, lon); // LatLng expects (lat, lon)
    }).toList();

    final startLatLng = polylinePoints.first;
    final destLatLng = polylinePoints.last;

    // Compute map center as the average of start and destination.
    final center = LatLng(
      (startLatLng.latitude + destLatLng.latitude) / 2,
      (startLatLng.longitude + destLatLng.longitude) / 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Route Map"),
        backgroundColor: const Color(0xFF021934),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: 5,
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
                points: polylinePoints,
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
