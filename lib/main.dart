import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nearby_helper_app/screens/home_screen.dart';
import 'package:nearby_helper_app/screens/add_request_screen.dart';
import 'package:nearby_helper_app/screens/requests_list_screen.dart';
import 'package:nearby_helper_app/screens/request_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // ✅ added missing const constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nearby Helper',

      // ✅ App-wide theme setup
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(), // ✅ Google Fonts applied
      ),

      // ✅ Initial route (Home Screen)
      initialRoute: '/',

      // ✅ Static routes
      routes: {
        '/': (context) => const HomeScreen(),
        '/add-request': (context) => const AddRequestScreen(),
        '/requests-list': (context) => const RequestsListScreen(),
      },

      // ✅ Dynamic route for detail screen
      onGenerateRoute: (settings) {
        if (settings.name == '/request-detail') {
          final request = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => RequestDetailScreen(request: request),
          );
        }
        return null;
      },
    );
  }
}
