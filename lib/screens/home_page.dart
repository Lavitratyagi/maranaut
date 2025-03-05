import 'package:flutter/material.dart';
import 'package:maranaut/screens/history_voyage.dart';
import 'package:maranaut/screens/select_ship.dart';
import 'package:maranaut/screens/select_yoyage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Default placeholder values.
  double totalFuelSaved = 1234.56;
  String shipName = "Sea Explorer";
  String shipModel = "X-200";

  // Function to refresh the fuel data.
  void _refreshFuelData() {
    setState(() {
      totalFuelSaved = totalFuelSaved + 10;
    });
  }

  // Function to load the selected ship data from local storage.
  Future<void> loadShipData() async {
    final prefs = await SharedPreferences.getInstance();
    final shipJson = prefs.getString("selectedShip");
    if (shipJson != null) {
      final shipData = json.decode(shipJson);
      setState(() {
        shipName = shipData["shipName"] ?? shipName;
        shipModel = shipData["type"] ?? shipModel;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadShipData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with logo, text, and user icon.
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png', // Replace with your logo asset
              height: 30,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            const Text("MaraNaut", style: TextStyle(color: Colors.white)),
            const Spacer(),
            const Icon(Icons.person, color: Colors.white),
          ],
        ),
      ),
      // Stack to display the background image and bottom card.
      body: Stack(
        children: [
          // Full-screen Background image.
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/bg.png',
                ), // Replace with your background asset
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main scrollable content.
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Text.
                const Text(
                  "Let’s manage your Ocean Moves.",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                // Total Fuel Saved Section.
                const Text(
                  "Total Fuel Saved",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "$totalFuelSaved L",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _refreshFuelData,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Ship Information Section.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.directions_boat,
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shipName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          shipModel,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelectShip(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFFA6CEEF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size(0, 50),
                      ),
                      child: const Text("Select Ship"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Row with two buttons: Check Route and Recent Alerts.
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // TODO: Implement Check Route action.
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("Check Route"),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // TODO: Implement Recent Alerts action.
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("Recent Alerts"),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryVoyagePage(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("History"),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // TODO: Implement Recent Alerts action.
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("Recent Alerts"),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // White card pinned at the bottom.
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add the details of your ship",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Update your ship info to locate, update and cross-check your voyage whenever needed!",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelectVoyagePage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "ADD VOYAGE",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
