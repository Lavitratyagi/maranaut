import 'package:flutter/material.dart';
import 'package:maranaut/Api%20Service/api_service.dart';
import 'destination_page.dart'; // Ensure this page exists for navigation

class TripPlan extends StatefulWidget {
  final String shipId;
  const TripPlan({Key? key, required this.shipId}) : super(key: key);

  @override
  State<TripPlan> createState() => _TripPlanState();
}

class _TripPlanState extends State<TripPlan> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _voyagersController = TextEditingController();
  final TextEditingController _fuelController = TextEditingController();
  late Future<Ship> _futureShipDetail;

  @override
  void initState() {
    super.initState();
    _futureShipDetail = ApiService().fetchShipDetail(widget.shipId);
  }

  @override
  void dispose() {
    _voyagersController.dispose();
    _fuelController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      // Collect the form data.
      final voyagers = _voyagersController.text.trim();
      final availableFuel = _fuelController.text.trim();

      // Navigate to the DestinationPage and pass the data.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DestinationPage(
            shipId: widget.shipId,
            voyagers: voyagers,
            availableFuel: availableFuel,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with logo and icons.
      appBar: AppBar(
        backgroundColor: const Color(0xFF021934),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png', // Replace with your logo asset
              height: 30,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Text("MeraNaut", style: TextStyle(color: Colors.white)),
            const Spacer(),
            const Icon(Icons.location_on, color: Colors.white),
            const SizedBox(width: 8),
            const Icon(Icons.notifications, color: Colors.white),
            const SizedBox(width: 8),
            const Icon(Icons.person, color: Colors.white),
          ],
        ),
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/choose_voyage.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<Ship>(
          future: _futureShipDetail,
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
              final shipDetail = snapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // White card with ship details and form.
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shipDetail.shipName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              shipDetail.type,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const Divider(height: 24, thickness: 1),
                            // Voyagers on board field.
                            TextFormField(
                              controller: _voyagersController,
                              decoration: const InputDecoration(
                                labelText: "Voyagers on board :",
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter the number of voyagers.";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Available Fuel field.
                            TextFormField(
                              controller: _fuelController,
                              decoration: const InputDecoration(
                                labelText: "Available Fuel (during depart) :",
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter available fuel.";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: ElevatedButton(
                                onPressed: _handleNext,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF021934),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  "Choose Destination/Source",
                                  style: TextStyle(fontSize: 16, color: Colors.white),
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
            } else {
              return const Center(
                child: Text(
                  "No ship details found.",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
