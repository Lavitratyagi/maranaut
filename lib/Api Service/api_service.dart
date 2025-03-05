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
}
