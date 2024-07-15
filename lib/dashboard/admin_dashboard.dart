import 'package:eventify_admin/dashboard/sidebar.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      drawer: Sidebar(),
      body: const Center(
        child: Text('Welcome to Admin Dashboard!'),
      ),
    );
  }
}
