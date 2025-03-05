import 'package:flutter/material.dart';
import 'package:maranaut/Api%20Service/api_service.dart';

class HistoryPage extends StatefulWidget {
  final String shipId;
  const HistoryPage({Key? key, required this.shipId}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<History>> _futureHistory;

  @override
  void initState() {
    super.initState();
    _futureHistory = ApiService().fetchShipHistory(widget.shipId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF021934),
        title: Row(
          children: [
            // Logo and "MeraNaut" text on the left.
            Image.asset(
              'assets/images/logo.png', // Replace with your logo asset.
              height: 30,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Text("MeraNaut", style: TextStyle(color: Colors.white)),
            const Spacer(),
            // Icons on the right.
            const Icon(Icons.location_on, color: Colors.white),
            const SizedBox(width: 8),
            const Icon(Icons.notifications, color: Colors.white),
            const SizedBox(width: 8),
            const Icon(Icons.person, color: Colors.white),
          ],
        ),
      ),
      // Full-screen background image.
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/choose_voyage.png', // Replace with your background asset.
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Centered heading.
            const Center(
              child: Text(
                "Voyage History",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Expanded list of history records.
            Expanded(
              child: FutureBuilder<List<History>>(
                future: _futureHistory,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    final historyList = snapshot.data!;
                    if (historyList.isEmpty) {
                      return const Center(
                        child: Text(
                          "No history records found.",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: historyList.length,
                      itemBuilder: (context, index) {
                        final history = historyList[index];
                        return GestureDetector(
                          onTap: () {
                            // Optional: Navigate to a detailed history page.
                          },
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.white,
                            child: Container(
                              height: 140, // Adjust the height as needed.
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Ship ID: ${history.shipId}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Route: (${history.srcLatitude}, ${history.srcLongitude}) → (${history.distLatitude}, ${history.distLongitude})",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Passengers: ${history.passengers}    Fuel: ${history.availableFuel}",
                                    style: const TextStyle(
                                      fontSize: 14,
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
                      child: Text(
                        "No history records found.",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
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
