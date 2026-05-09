import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_page.dart'; 
import 'provider/user_provider.dart';
import 'provider/treasurer_provider.dart';
import 'provider/module_provider.dart'; 
import 'provider/attendance_provider.dart';
import 'provider/manage_fees_provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ModuleProvider()), // 3. Register ModuleProvider
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TreasuryProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => FeesManagementProvider()),
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
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const LoginPage(), 
    );
  }
}