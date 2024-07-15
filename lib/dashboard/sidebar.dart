import 'package:eventify_admin/config/router/app_routes.dart';
import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final List<String> options = [
    'Users',
    'Events', // Add the 'Events' option here
    'Venues',
    'Promo Codes',
    'User Events',
    'Notifications',
  ];

  Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Admin Dashboard',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          ListTile(
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ...options.map((option) => ListTile(
                title: Text(option),
                onTap: () {
                  switch (option) {
                    case 'Users':
                      Navigator.pushNamed(context, AppRoute.usersRoute);
                      break;
                    case 'Events':
                      Navigator.pushNamed(context, AppRoute.eventsRoute);
                      break;
                    case 'Venues':
                      Navigator.pushNamed(context, AppRoute.venueRoute);
                      break;
                    case 'Promo Codes':
                      Navigator.pushNamed(context, AppRoute.promocodeRoute);
                      break;
                    case 'User Events':
                      Navigator.pushNamed(context, AppRoute.usereventsRoute);
                      break;
                    case 'Notifications':
                      Navigator.pushNamed(context, AppRoute.notificationRoute);
                      break;
                    default:
                      break;
                  }
                },
              )),
        ],
      ),
    );
  }
}
