import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserEventsScreen extends StatefulWidget {
  const UserEventsScreen({super.key});

  @override
  _UserEventsScreenState createState() => _UserEventsScreenState();
}

class _UserEventsScreenState extends State<UserEventsScreen> {
  List<dynamic> _events = [];

  Future<void> _fetchEvents() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.68.109:5500/api/events'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _events = jsonData['events'];
        });
      } else {
        throw Exception(
            'Failed to load events. Status code: ${response.statusCode}. Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching events: ${e.toString()}');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Events')),
      body: _events.isEmpty
          ? const Center(child: Text('No events found'))
          : ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(_events[index]['eventName']),
                      Text(_events[index]['eventDate']),
                      Text(_events[index]['eventTime']),
                      Text(_events[index]['location']),
                      Text(_events[index]['ticketPrice'].toString()),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
