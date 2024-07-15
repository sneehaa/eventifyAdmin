import 'package:eventify_admin/config/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Eventify Admin',
        theme: ThemeData(
          textTheme: GoogleFonts.libreBaskervilleTextTheme(
            Theme.of(context).textTheme,
          ).copyWith(
            bodyLarge: GoogleFonts.libreBaskerville(),
            bodyMedium: GoogleFonts.libreBaskerville(),
          ),
        ),
        initialRoute: AppRoute.login,
        routes: AppRoute.getApplicationRoute(),
      ),
    );
  }
}
