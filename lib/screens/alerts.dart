import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({Key? key}) : super(key: key);

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  late WebSocketChannel _channel;
  // List to hold incoming alert messages.
  final List<Map<String, dynamic>> _alerts = [];

  @override
  void initState() {
    super.initState();
    // Connect to your WebSocket server.
    _channel = IOWebSocketChannel.connect(
      'ws://192.168.0.108:8000/broadcast/alerts',
    );
    // Listen for incoming messages.
    _channel.stream.listen((message) {
      try {
        final data = jsonDecode(message);
        if (data is Map<String, dynamic>) {
          setState(() {
            // Insert new alert at the top.
            _alerts.insert(0, data);
          });
        }
      } catch (e) {
        print("Error decoding message: $e");
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alerts"),
        backgroundColor: const Color(0xFF021934),
      ),
      body: Container(
        // Optional: set a background image.
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/alerts_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: _alerts.isEmpty
            ? const Center(
                child: Text(
                  "No alerts received yet.",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              )
            : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _alerts.length,
                itemBuilder: (context, index) {
                  final alert = _alerts[index];
                  final reason = alert["reason"] ?? "Unknown";
                  final latitude = alert["latitude"]?.toString() ?? "N/A";
                  final longitude = alert["longitude"]?.toString() ?? "N/A";
                  final timestamp = alert["timestamp"] ?? "";
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.warning,
                        color: Colors.red,
                      ),
                      title: Text(
                        reason,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Lat: $latitude, Long: $longitude"),
                          Text(
                            "Time: $timestamp",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
