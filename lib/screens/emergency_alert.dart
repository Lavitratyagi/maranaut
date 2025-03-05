import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class EmergencyAlertPage extends StatefulWidget {
  final String shipId;
  const EmergencyAlertPage({Key? key, required this.shipId}) : super(key: key);

  @override
  _EmergencyAlertPageState createState() => _EmergencyAlertPageState();
}

class _EmergencyAlertPageState extends State<EmergencyAlertPage> {
  bool _menuExpanded = false;
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    // Connect to your WebSocket server (replace with your URL).
    _channel = IOWebSocketChannel.connect('ws://your-websocket-url');
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  /// Sends an emergency alert with the provided [alertType].
  void _sendEmergencyAlert(String alertType) {
    final alertData = {
      "ship_id": widget.shipId,
      "alert_type": alertType,
      "timestamp": DateTime.now().toIso8601String(),
    };
    _channel.sink.add(jsonEncode(alertData));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$alertType alert sent")),
    );
    setState(() {
      _menuExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Main button dimensions.
    const double buttonSize = 100.0;
    // Radius for option placement.
    const double optionRadius = 120.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF021934),
        title: const Text("Emergency Alert"),
      ),
      body: Stack(
        children: [
          // Simple background color (you can change it to any background image if needed)
          Container(color: Colors.red.shade50),
          Center(
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
                const SizedBox(height: 40),
                // Main emergency button.
                GestureDetector(
                  onLongPressStart: (_) {
                    setState(() {
                      _menuExpanded = true;
                    });
                  },
                  onLongPressEnd: (_) {
                    // Optionally collapse the menu if no option is chosen.
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) {
                        setState(() {
                          _menuExpanded = false;
                        });
                      }
                    });
                  },
                  child: Container(
                    width: buttonSize,
                    height: buttonSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: const Icon(
                      Icons.warning,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Radial menu options overlay (displayed only when _menuExpanded is true)
          if (_menuExpanded)
            Center(
              child: Stack(
                children: [
                  // Option 1: Piracy Alert at top.
                  Positioned(
                    top: -optionRadius,
                    left: (buttonSize / 2) - 40,
                    child: _buildOptionButton(
                      "Piracy Alert",
                      Icons.security,
                      () => _sendEmergencyAlert("Piracy Alert"),
                    ),
                  ),
                  // Option 2: Crew Management at right.
                  Positioned(
                    right: -optionRadius,
                    top: (buttonSize / 2) - 40,
                    child: _buildOptionButton(
                      "Crew Management",
                      Icons.group,
                      () => _sendEmergencyAlert("Crew Management"),
                    ),
                  ),
                  // Option 3: Equipment Issues at bottom.
                  Positioned(
                    bottom: -optionRadius,
                    left: (buttonSize / 2) - 40,
                    child: _buildOptionButton(
                      "Equipment Issues",
                      Icons.build,
                      () => _sendEmergencyAlert("Equipment Issues"),
                    ),
                  ),
                  // Option 4: Sudden change in weather at left.
                  Positioned(
                    left: -optionRadius,
                    top: (buttonSize / 2) - 40,
                    child: _buildOptionButton(
                      "Sudden change in weather",
                      Icons.wb_cloudy,
                      () => _sendEmergencyAlert("Sudden change in weather"),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Builds a circular option button with an [icon] and [label]. When tapped,
  /// [onPressed] is invoked.
  Widget _buildOptionButton(String label, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
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
