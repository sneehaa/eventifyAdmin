import 'package:eventify_admin/dashboard/admin_dashboard.dart';
import 'package:eventify_admin/dashboard/admin_login.dart';
import 'package:eventify_admin/dashboard/events.dart';
import 'package:eventify_admin/dashboard/notifications_screen.dart';
import 'package:eventify_admin/dashboard/promo_code_screen.dart';
import 'package:eventify_admin/dashboard/user_events_screen.dart';
import 'package:eventify_admin/dashboard/user_screen.dart';
import 'package:eventify_admin/dashboard/venue_screen.dart';

class AppRoute {
  AppRoute._();

  static const String login = '/';
  static const String dashboard = 'dashboard';
  static const String usereventsRoute = '/userevents';
  static const String promocodeRoute = '/promo';
  static const String usersRoute = '/users';
  static const String venueRoute = '/venue';
  static const String notificationRoute = '/notification';
  static const String eventsRoute = '/events';

  static getApplicationRoute() {
    return {
      login: (context) => const AdminLoginScreen(),
      dashboard: (context) => const AdminDashboard(),
      usereventsRoute: (context) => const UserEventsScreen(),
      promocodeRoute: (context) => const PromoCodesScreen(),
      usersRoute: (context) => const UsersScreen(),
      venueRoute: (context) => const AdminVenueCreationPage(),
      notificationRoute: (context) => const AdminAddNotificationPage(),
      eventsRoute: (context) => const AdminAddEventPage(),
    };
  }
}
