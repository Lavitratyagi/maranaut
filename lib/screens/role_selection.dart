import 'package:flutter/material.dart';
import 'package:maranaut/Api%20Service/api_service.dart';
import 'package:maranaut/screens/home_page.dart';

class RoleSelectionPage extends StatelessWidget {
  final String email;
  final String password;

  const RoleSelectionPage({
    Key? key,
    required this.email,
    required this.password,
  }) : super(key: key);

  // Function to call API service based on role selection
  void _handleRoleSelection(BuildContext context, bool isAdmin) async {
    final apiService = ApiService();

    try {
      final response = await apiService.signUp(
        email: email,
        password: password,
        admin: isAdmin,
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error occurred: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Full-screen background image without an AppBar
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/roleselection.png',
            ), // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Admin Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _handleRoleSelection(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Customize as needed
                    minimumSize: const Size(
                      double.infinity,
                      50,
                    ), // Regular size button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text('Admin', style: TextStyle(fontSize: 18)),
                      ),
                      Image.asset(
                        'assets/images/image 37.png', // Replace with your admin image asset path
                        height: 30,
                        width: 30,
                      ),
                    ],
                  ),
                ),
              ),
              // Crew Member Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _handleRoleSelection(context, false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Customize as needed
                    minimumSize: const Size(
                      double.infinity,
                      50,
                    ), // Regular size button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Crew Member',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Image.asset(
                        'assets/images/image 36.png', // Replace with your crew member image asset path
                        height: 30,
                        width: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
