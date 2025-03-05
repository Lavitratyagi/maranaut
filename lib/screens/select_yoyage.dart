import 'package:flutter/material.dart';
import 'package:maranaut/Api%20Service/api_service.dart';

class SelectVoyagePage extends StatefulWidget {
  const SelectVoyagePage({Key? key}) : super(key: key);

  @override
  State<SelectVoyagePage> createState() => _SelectVoyagePageState();
}

class _SelectVoyagePageState extends State<SelectVoyagePage> {
  late Future<List<Ship>> _futureShips;

  @override
  void initState() {
    super.initState();
    _futureShips = ApiService().fetchShips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF021934),
        title: Row(
          children: [
            // Logo and "MeraNaut" text on the left
            Image.asset(
              'assets/images/logo.png', // Replace with your logo asset
              height: 30,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Text(
              "MeraNaut",
              style: TextStyle(color: Colors.white),
            ),
            const Spacer(),
            // Icons on the right: location, bell, user
            const Icon(Icons.location_on, color: Colors.white),
            const SizedBox(width: 8),
            const Icon(Icons.notifications, color: Colors.white),
            const SizedBox(width: 8),
            const Icon(Icons.person, color: Colors.white),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Centered heading
            const Center(
              child: Text(
                "Select Your Voyage",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            // FutureBuilder to load ship data from the API
            Expanded(
              child: FutureBuilder<List<Ship>>(
                future: _futureShips,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final ships = snapshot.data!;
                    return ListView.builder(
                      itemCount: ships.length,
                      itemBuilder: (context, index) {
                        final ship = ships[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(ship.shipName),
                            subtitle: Text(ship.type),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text("No ships found."));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
