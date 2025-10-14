import 'package:flutter/material.dart';
import 'package:nearby_helper_app/screens/home_screen.dart';
import 'package:nearby_helper_app/screens/add_request_screen.dart';
import 'package:nearby_helper_app/screens/requests_list_screen.dart';
import 'package:nearby_helper_app/screens/nearby_map_screen.dart';
import 'package:nearby_helper_app/screens/request_detail_screen.dart';

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
      initialRoute: '/',

      routes: {
        '/': (context) => const HomeScreen(),
        '/add-request': (context) => const AddRequestScreen(),
        '/requests-list': (context) => const RequestsListScreen(),
        '/nearby-map': (context) => const NearbyMapScreen(),
      },

      // ✅ Dynamic routing for RequestDetailScreen with arguments
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
