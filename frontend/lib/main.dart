import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_page.dart'; 
import 'provider/UserProvider.dart';

void main() {
  runApp(
    // 3. Wrap your app in a MultiProvider or ChangeNotifierProvider
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'USAS System',
      debugShowCheckedModeBanner: false, // Removes that "Debug" banner in the corner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF004D73)),
        useMaterial3: true,
      ),
      // This is where we tell Flutter to start with your new layout
      home: const LoginPage(), 
    );
  }
}