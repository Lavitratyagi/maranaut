import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:geolocator/geolocator.dart';

class EmergencyAlertPage extends StatefulWidget {
  final String shipId;
  const EmergencyAlertPage({super.key, required this.shipId});

  @override
  _EmergencyAlertPageState createState() => _EmergencyAlertPageState();
}

class _EmergencyAlertPageState extends State<EmergencyAlertPage> {
  bool _menuExpanded = false;
  late WebSocketChannel _channel;
  
  // Class-level constant for option button size.
  static const double _optionButtonSize = 80.0;

  @override
  void initState() {
    super.initState();
    // Connect to your WebSocket server (replace with your URL).
    _channel = IOWebSocketChannel.connect(
      'ws://192.168.0.108:8000/broadcast/alerts',
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  /// Retrieves the current location using Geolocator.
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    
    // Check for location permissions.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, cannot request permissions.');
    }
    
    return await Geolocator.getCurrentPosition();
  }

  /// Sends an emergency alert with the given [alertType].
  Future<void> _sendEmergencyAlert(String alertType) async {
    try {
      final position = await _getCurrentLocation();
      final alertData = {
        "action": "alert",
        "reason": alertType,
        "longitude": position.longitude,
        "latitude": position.latitude,
        "timestamp": DateTime.now().toIso8601String(),
      };
      _channel.sink.add(jsonEncode(alertData));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("$alertType alert sent")));
      setState(() {
        _menuExpanded = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to get location: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Adjusted sizes.
    const double emergencyButtonSize = 100.0;
    const double bigCircleDiameter = 250.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF021934),
        title: const Text("Emergency Alert"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Emergency help",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "JUST HOLD THE BUTTON TO ACTIVATE THE EMERGENCY SYSTEM",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            // The dial with the central emergency button and, if expanded, the options.
            Stack(
              alignment: Alignment.center,
              children: [
                // Big circle dial background.
                Container(
                  width: bigCircleDiameter,
                  height: bigCircleDiameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.2),
                    border: Border.all(color: Colors.blueAccent, width: 2),
                  ),
                ),
                // Option buttons on the circumference – shown when _menuExpanded is true.
                if (_menuExpanded) ...[
                  // Top option: Piracy Alert.
                  Transform.translate(
                    offset: Offset(0, -bigCircleDiameter / 2),
                    child: _buildOptionButton(
                      "Piracy Alert",
                      Icons.security,
                      () => _sendEmergencyAlert("Piracy Alert"),
                    ),
                  ),
                  // Right option: Crew Management.
                  Transform.translate(
                    offset: Offset(bigCircleDiameter / 2, 0),
                    child: _buildOptionButton(
                      "Crew Management",
                      Icons.group,
                      () => _sendEmergencyAlert("Crew Management"),
                    ),
                  ),
                  // Bottom option: Equipment Issues.
                  Transform.translate(
                    offset: Offset(0, bigCircleDiameter / 2),
                    child: _buildOptionButton(
                      "Equipment Issues",
                      Icons.build,
                      () => _sendEmergencyAlert("Equipment Issues"),
                    ),
                  ),
                  // Left option: Sudden change in weather.
                  Transform.translate(
                    offset: Offset(-bigCircleDiameter / 2, 0),
                    child: _buildOptionButton(
                      "Sudden change in weather",
                      Icons.wb_cloudy,
                      () => _sendEmergencyAlert("Sudden change in weather"),
                    ),
                  ),
                ],
                // Central emergency button with gradient.
                GestureDetector(
                  onLongPressStart: (_) {
                    print("Long press started");
                    setState(() {
                      _menuExpanded = true;
                    });
                  },
                  child: Container(
                    width: emergencyButtonSize,
                    height: emergencyButtonSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF00A8C9), Color(0xFF6FCADC)],
                        center: Alignment.center,
                        radius: 0.8,
                      ),
                    ),
                    child: const Icon(
                      Icons.warning,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a circular option button with an icon and label.
  Widget _buildOptionButton(String label, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _optionButtonSize,
            height: _optionButtonSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent,
            ),
            child: Icon(icon, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 100,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
