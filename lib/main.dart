import 'package:flutter/material.dart';
import 'package:nearby_helper_app/screens/requests_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_request_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nearby Helper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),

      // 🗺️ Define app routes
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/add-request': (context) => const AddRequestScreen(),
        '/requests-list': (context) => const RequestsListScreen(),
      },
    );
  }
}
