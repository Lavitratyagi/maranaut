import 'package:flutter/material.dart';
import 'package:maranaut/Api%20Service/api_service.dart';
import 'package:maranaut/screens/trip_plan.dart';

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
      // Full-screen background image
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/choose_voyage.png', // Replace with your background asset
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Centered Heading
            const Center(
              child: Text(
                "Select Your Voyage",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Expanded list of ships
            Expanded(
              child: FutureBuilder<List<Ship>>(
                future: _futureShips,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.white)));
                  } else if (snapshot.hasData) {
                    final ships = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: ships.length,
                      itemBuilder: (context, index) {
                        final ship = ships[index];
                        return GestureDetector(
                          onTap: () {
                            // Pass the ship id to the next page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TripPlan(shipId: ship.id),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.white,
                            child: Container(
                              height: 100, // Increased height
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    ship.shipName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ship.type,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                        child: Text("No ships found.",
                            style: TextStyle(color: Colors.white)));
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
