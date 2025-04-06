import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Quest', 
      theme: ThemeData(
        primarySwatch: Colors.lightBlue, 
        fontFamily: 'ComicSans',
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ),
      home: SplashScreen(), 
      debugShowCheckedModeBanner: false, 
    );
  }
}