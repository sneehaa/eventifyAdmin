import 'dart:convert';

import 'package:eventify_admin/config/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/flutter_secure_storage/flutter_secure_Storage.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _message = '';

  final SecureStorage secureStorage = SecureStorage();

  void _loginAdmin() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _message = 'Please enter username and password.';
      });
      return;
    }

    try {
      var url = Uri.parse('http://192.168.68.109:5500/api/user/login');

      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        String token = responseData['token'];

        await secureStorage.writeToken(token); // Save token using SecureStorage

        Navigator.pushNamed(context, AppRoute.dashboard);
      } else {
        setState(() {
          _message = 'Login failed. Please check your credentials.';
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _message = 'Error occurred. Please try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _loginAdmin,
              child: const Text('Login'),
            ),
            const SizedBox(height: 10.0),
            Text(
              _message,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
