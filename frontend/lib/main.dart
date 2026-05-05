import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_page.dart'; 
import 'provider/user_provider.dart';
import 'provider/module_provider.dart'; 

void main() {
  runApp(
    
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ModuleProvider()), // 3. Register ModuleProvider
        
      ],
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
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF004D73)),
        useMaterial3: true,
      ),
      home: const LoginPage(), 
    );
  }
}