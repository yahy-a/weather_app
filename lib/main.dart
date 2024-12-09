import 'package:flutter/material.dart';
import 'package:weather_app/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'weather app',
      theme: ThemeData(
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}