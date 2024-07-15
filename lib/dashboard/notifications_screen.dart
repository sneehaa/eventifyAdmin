// admin_add_notification_page.dart
import 'dart:convert';

import 'package:eventify_admin/core/flutter_secure_storage/flutter_secure_Storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class AdminAddNotificationPage extends StatefulWidget {
  const AdminAddNotificationPage({super.key});

  @override
  _AdminAddNotificationPageState createState() =>
      _AdminAddNotificationPageState();
}

class _AdminAddNotificationPageState extends State<AdminAddNotificationPage> {
  final Logger _logger = Logger();
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _message = '';

  void _addNotification() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final token = await SecureStorage().readToken();

        final response = await http.post(
          Uri.parse(
              'http://192.168.68.109:5500/api/notifications/add-notification'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: json.encode({'title': _title, 'message': _message}),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notification added successfully')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to add notification')));
          _logger.e(
              'Failed to add notification. Status code: ${response.statusCode}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error adding notification')));
        _logger.e('Error adding notification: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Notification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Message'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
                onSaved: (value) => _message = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addNotification,
                child: const Text('Add Notification'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
