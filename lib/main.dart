import 'package:flutter/material.dart';
import 'package:nearby_helper_app/screens/home_screen.dart';
import 'package:nearby_helper_app/screens/add_request_screen.dart';
import 'package:nearby_helper_app/screens/requests_list_screen.dart';
import 'package:nearby_helper_app/screens/nearby_map_screen.dart';

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

      // ✅ Only screens without required parameters go here
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/add-request': (context) => const AddRequestScreen(),
        '/requests-list': (context) => const RequestsListScreen(),
        '/nearby-map': (context) => const NearbyMapScreen(),
        // ❌ remove RequestDetailScreen from here
      },
    );
  }
}
