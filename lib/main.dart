import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/weather_screen.dart';

void main() => runApp(const FarmAssistApp());

class FarmAssistApp extends StatelessWidget {
  const FarmAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farm Assist',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      routes: {
        '/weather': (context) => const WeatherScreen(),
      },
    );
  }
}