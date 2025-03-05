import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:maranaut/Api%20Service/api_service.dart'; // Adjust the import as needed

class MapPage extends StatefulWidget {
  final String shipId;
  final double startLat;
  final double startLng;
  final double destLat;
  final double destLng;

  const MapPage({
    super.key,
    required this.shipId,
    required this.startLat,
    required this.startLng,
    required this.destLat,
    required this.destLng,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late Future<Ship> _futureShipInfo;
  late Future<Trip> _futureLastTrip;

  @override
  void initState() {
    super.initState();
    _futureShipInfo = ApiService().fetchShipDetail(widget.shipId);
    _futureLastTrip = ApiService().fetchLastTrip(widget.shipId);
  }

  @override
  Widget build(BuildContext context) {
    final startLatLng = LatLng(widget.startLat, widget.startLng);
    final destLatLng = LatLng(widget.destLat, widget.destLng);
    final center = LatLng(
      (widget.startLat + widget.destLat) / 2,
      (widget.startLng + widget.destLng) / 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Route Map"),
        backgroundColor: const Color(0xFF021934),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              // For older versions of flutter_map use initialCenter/initialZoom.
              // For flutter_map v4+ use center and zoom.
              initialCenter: center,
              initialZoom: 5,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
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
          // Draggable bottom sheet for ship info and last trip details.
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.1,
            maxChildSize: 0.5,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle.
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Ship Details",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FutureBuilder<Ship>(
                        future: _futureShipInfo,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else if (snapshot.hasData) {
                            final ship = snapshot.data!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Name: ${ship.shipName}",
                                    style: const TextStyle(fontSize: 16)),
                                Text("ID: ${ship.id}",
                                    style: const TextStyle(fontSize: 16)),
                                Text("Type: ${ship.type}",
                                    style: const TextStyle(fontSize: 16)),
                                Text("AIS: ${ship.ais}",
                                    style: const TextStyle(fontSize: 16)),
                                Text("Fuel Type: ${ship.fuelType}",
                                    style: const TextStyle(fontSize: 16)),
                                Text("Top Speed: ${ship.topSpeed}",
                                    style: const TextStyle(fontSize: 16)),
                                Text("Dimension: ${ship.shipDimension}",
                                    style: const TextStyle(fontSize: 16)),
                              ],
                            );
                          } else {
                            return const Text("No ship data.");
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Last Trip",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FutureBuilder<Trip>(
                        future: _futureLastTrip,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else if (snapshot.hasData) {
                            final trip = snapshot.data!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "From: (${trip.srcLatitude}, ${trip.srcLongitude})",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "To: (${trip.distLatitude}, ${trip.distLongitude})",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "Passengers: ${trip.passengers}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "Fuel Used: ${trip.availableFuel}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "Date: ${trip.date}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            );
                          } else {
                            return const Text("No trip data.");
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
