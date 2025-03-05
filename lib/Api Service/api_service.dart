import 'dart:convert';
import 'package:http/http.dart' as http;

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
}
