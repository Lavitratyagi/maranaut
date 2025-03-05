import 'dart:convert';
import 'package:http/http.dart' as http;

class Ship {
  final String id;
  final String shipName;
  final String type;
  final int ais;
  final String fuelType;
  final int topSpeed;
  final String shipDimension;

  Ship({
    required this.id,
    required this.shipName,
    required this.type,
    required this.ais,
    required this.fuelType,
    required this.topSpeed,
    required this.shipDimension,
  });

  factory Ship.fromJson(Map<String, dynamic> json) {
    return Ship(
      id: json['id'],
      shipName: json['ship_name'],
      type: json['type'],
      ais: json['ais'],
      fuelType: json['fuel_type'],
      topSpeed: json['top_speed'],
      shipDimension: json['ship_dimension'],
    );
  }
}

class History {
  final String shipId;
  final double srcLatitude;
  final double srcLongitude;
  final double distLatitude;
  final double distLongitude;
  final int passengers;
  final int availableFuel;

  History({
    required this.shipId,
    required this.srcLatitude,
    required this.srcLongitude,
    required this.distLatitude,
    required this.distLongitude,
    required this.passengers,
    required this.availableFuel,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      shipId: json['ship_id'].toString(),
      srcLatitude: (json['src_latitude'] as num).toDouble(),
      srcLongitude: (json['src_longitude'] as num).toDouble(),
      distLatitude: (json['dist_latitude'] as num).toDouble(),
      distLongitude: (json['dist_longitude'] as num).toDouble(),
      passengers: json['passengers'] is int
          ? json['passengers']
          : int.tryParse(json['passengers'].toString()) ?? 0,
      availableFuel: json['available_fuel'] is int
          ? json['available_fuel']
          : int.tryParse(json['available_fuel'].toString()) ?? 0,
    );
  }
}

class ApiService {
  // Replace with your actual backend URL
  static const String baseUrl = 'http://192.168.0.108:8000';

  Future<http.Response> signUp({
    required String email,
    required String password,
    required bool admin,
  }) async {
    final url = Uri.parse('$baseUrl/account/create');
    final body = jsonEncode({
      "email": email,
      "password": password,
      "admin": admin,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    return response;
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    // Construct the GET request URL with query parameters
    final url = Uri.parse(
      '$baseUrl/account/login?email=$email&password=$password',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      if (response.body != 'false') {
        return response.body; // Return the response as a string
      }
      throw Exception('Invalid credentials');
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  }

  Future<List<Ship>> fetchShips() async {
    final url = Uri.parse('$baseUrl/ships/all'); // Adjust endpoint as needed.
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Ship.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load ships');
    }
  }

  Future<Ship> fetchShipDetail(String shipId) async {
    final url = Uri.parse('$baseUrl/ships?id=$shipId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Ship.fromJson(jsonData);
    } else {
      throw Exception('Failed to load ship details');
    }
  }

  Future<bool> bookTrip({
    required String shipId,
    required double srcLatitude,
    required double srcLongitude,
    required double distLatitude,
    required double distLongitude,
    required int passengers,
    required int availableFuel,
  }) async {
    final String url = '$baseUrl/trip/register';
    final Map<String, dynamic> body = {
      "ship_id": shipId,
      "src_latitude": srcLatitude,
      "src_longitude": srcLongitude,
      "dist_latitude": distLatitude,
      "dist_longitude": distLongitude,
      "passengers": passengers,
      "available_fuel": availableFuel,
    };
    print('step 1');
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      print('step 2');
      return true;
    } else {
      throw Exception("Failed to book trip: ${response.body}");
    }
  }

   Future<List<History>> fetchShipHistory(String shipId) async {
    final String url = '$baseUrl/trip/history?id=$shipId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => History.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch ship history: ${response.body}");
    }
  }
}
