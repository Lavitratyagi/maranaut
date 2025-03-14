import 'package:flutter/material.dart';
import 'package:maranaut/Api%20Service/api_service.dart';
import 'package:maranaut/screens/map.dart';

class DestinationPage extends StatefulWidget {
  final String shipId;
  final String voyagers;
  final String availableFuel;

  const DestinationPage({
    super.key,
    required this.shipId,
    required this.voyagers,
    required this.availableFuel,
  });

  @override
  State<DestinationPage> createState() => _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage> {
  // Updated mock data.
  final List<Map<String, String>> mockLocations = [
    {
      "LOCODE": "INBOM",
      "NAME": "Mumbai (ex Bombay)",
      "LAT": "18.93486649067586",
      "LON": "72.85446166992188",
    },
    {
      "LOCODE": "INMAA",
      "NAME": "Chennai (ex Madras)",
      "LAT": "13.115508962306507",
      "LON": "80.30902862548831",
    },
    {
      "LOCODE": "INCCU",
      "NAME": "Kolkata",
      "LAT": "22.547796871438308",
      "LON": "88.30698966979983",
    },
    {
      "LOCODE": "INVTZ",
      "NAME": "Visakhapatnam",
      "LAT": "17.687121802737536",
      "LON": "83.30074310302737",
    },
  ];

  // Controllers for the location name fields.
  final TextEditingController _startNameController = TextEditingController();
  final TextEditingController _destinationNameController = TextEditingController();

  // FocusNodes to manage focus.
  final FocusNode _startFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  // Strings to hold non-editable location details.
  String _startDetails = "";
  String _destinationDetails = "";

  // Variables to store the selected coordinates.
  double? _startLat;
  double? _startLng;
  double? _destLat;
  double? _destLng;

  // Variables to store the selected LOCODE values.
  String? _srcLocode;
  String? _dstLocode;

  // Lists to hold filtered suggestions.
  List<Map<String, String>> _filteredStartingLocations = [];
  List<Map<String, String>> _filteredDestinationLocations = [];

  @override
  void initState() {
    super.initState();
    _filteredStartingLocations = List.from(mockLocations);
    _filteredDestinationLocations = List.from(mockLocations);

    _startFocusNode.addListener(() {
      setState(() {});
    });
    _destinationFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _startNameController.dispose();
    _destinationNameController.dispose();
    _startFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  // Called when a location suggestion is tapped.
  void _selectLocation(Map<String, String> location, bool isStarting) {
    final name = location['NAME'] ?? 'Unknown';
    final details =
        "${location['LAT']}, ${location['LON']} (Code: ${location['LOCODE']})";
    setState(() {
      if (isStarting) {
        _startNameController.text = name;
        _startDetails = details;
        _startLat = double.tryParse(location['LAT']!);
        _startLng = double.tryParse(location['LON']!);
        _srcLocode = location['LOCODE'];
        _filteredStartingLocations = List.from(mockLocations);
        _startFocusNode.unfocus();
      } else {
        _destinationNameController.text = name;
        _destinationDetails = details;
        _destLat = double.tryParse(location['LAT']!);
        _destLng = double.tryParse(location['LON']!);
        _dstLocode = location['LOCODE'];
        _filteredDestinationLocations = List.from(mockLocations);
        _destinationFocusNode.unfocus();
      }
    });
  }

  // Filter starting locations based on query.
  void _filterStartingLocations(String query) {
    setState(() {
      _filteredStartingLocations = mockLocations.where((loc) {
        final locName = loc['NAME']!.toLowerCase();
        return locName.contains(query.toLowerCase());
      }).toList();

      _filteredStartingLocations.sort((a, b) {
        final aName = a['NAME']!.toLowerCase();
        final bName = b['NAME']!.toLowerCase();
        final lowerQuery = query.toLowerCase();
        final aStarts = aName.startsWith(lowerQuery);
        final bStarts = bName.startsWith(lowerQuery);
        if (aStarts && !bStarts) return -1;
        if (bStarts && !aStarts) return 1;
        return aName.compareTo(bName);
      });
    });
  }

  // Filter destination locations based on query.
  void _filterDestinationLocations(String query) {
    setState(() {
      _filteredDestinationLocations = mockLocations.where((loc) {
        final locName = loc['NAME']!.toLowerCase();
        return locName.contains(query.toLowerCase());
      }).toList();

      _filteredDestinationLocations.sort((a, b) {
        final aName = a['NAME']!.toLowerCase();
        final bName = b['NAME']!.toLowerCase();
        final lowerQuery = query.toLowerCase();
        final aStarts = aName.startsWith(lowerQuery);
        final bStarts = bName.startsWith(lowerQuery);
        if (aStarts && !bStarts) return -1;
        if (bStarts && !aStarts) return 1;
        return aName.compareTo(bName);
      });
    });
  }

  // Widget to show suggestions.
  Widget _buildSuggestions(List<Map<String, String>> suggestions, bool isStarting) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final location = suggestions[index];
          return ListTile(
            title: Text(location['NAME'] ?? 'Unknown'),
            onTap: () => _selectLocation(location, isStarting),
          );
        },
      ),
    );
  }

  // Called when the Book button is pressed.
  Future<void> _onBookPressed() async {
    if (_startLat != null &&
        _startLng != null &&
        _destLat != null &&
        _destLng != null &&
        _srcLocode != null &&
        _dstLocode != null) {
      try {
        String shipId = widget.shipId;
        // Build coordinate strings in "lat,lng" format.
        String srcCoordinates = "$_startLat,$_startLng";
        String dstCoordinates = "$_destLat,$_destLng";
        // Call the API service function.
        var response = await ApiService().bookTripWithRoute(
          shipId: shipId,
          srcCoordinates: srcCoordinates,
          dstCoordinates: dstCoordinates,
          srcLocode: _srcLocode!,
          dstLocode: _dstLocode!,
        );
        // Extract the route points from the response.
        // Assuming the API returns: { "Path": { "Points": [ ... ] } }
        final routePoints = response["Path"]["Points"];
        if (routePoints == null) {
          throw Exception("No route data returned from API");
        }
        // Navigate to MapPage and pass the route data.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MapPage(
              shipId: widget.shipId,
              route: routePoints,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Booking failed: ${e.toString()}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select both starting and destination locations."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Standard AppBar.
      appBar: AppBar(
        backgroundColor: const Color(0xFF021934),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png', // Replace with your logo asset.
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
      body: Stack(
        children: [
          // Top map image.
          SizedBox(
            width: double.infinity,
            child: Image.asset(
              'assets/images/map_img.png', // Replace with your image asset.
              fit: BoxFit.cover,
            ),
          ),
          // White container with form below the map.
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "You're online",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Divider(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Set up your upcoming trip",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Tell us about your trip and help transport goods to everyone",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.directions_boat,
                          size: 32,
                          color: Colors.blueGrey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Starting location text field with suggestions.
                    TextField(
                      controller: _startNameController,
                      focusNode: _startFocusNode,
                      decoration: InputDecoration(
                        labelText: "Starting location",
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (query) {
                        setState(() {
                          _startDetails = "";
                        });
                        _filterStartingLocations(query);
                      },
                    ),
                    if (_startDetails.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _startDetails,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    if (_startFocusNode.hasFocus)
                      _buildSuggestions(_filteredStartingLocations, true),
                    const SizedBox(height: 16),
                    // Destination location text field with suggestions.
                    TextField(
                      controller: _destinationNameController,
                      focusNode: _destinationFocusNode,
                      decoration: InputDecoration(
                        labelText: "Destination location",
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (query) {
                        setState(() {
                          _destinationDetails = "";
                        });
                        _filterDestinationLocations(query);
                      },
                    ),
                    if (_destinationDetails.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _destinationDetails,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    if (_destinationFocusNode.hasFocus)
                      _buildSuggestions(_filteredDestinationLocations, false),
                    const SizedBox(height: 24),
                    Text(
                      "Ship ID: ${widget.shipId}\nVoyagers: ${widget.voyagers}\nAvailable Fuel: ${widget.availableFuel}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _onBookPressed,
              child: const Text(
                'Book',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
