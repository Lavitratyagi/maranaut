import 'package:flutter/material.dart';
import 'package:maranaut/screens/login_signup_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Signup App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginSignupPage(),
    );
  }
}