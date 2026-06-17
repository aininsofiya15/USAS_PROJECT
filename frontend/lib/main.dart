import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_page.dart'; 
import 'screens/student/bank_acc_info.dart';
import 'screens/payment_history.dart';
import 'screens/student/notification.dart';
import 'provider/user_provider.dart';
import 'provider/treasurer_provider.dart';
import 'provider/module_provider.dart'; 
import 'provider/attendance_provider.dart';
import 'provider/manage_fees_provider.dart';
import 'provider/credit_provider.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; 

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Stripe Sandbox Test Publishable Key globally
  Stripe.publishableKey = "pk_test_51ThxWlCFCHNeyCRCz2socpSOuAsAHZ7QrLfRbldPQmJ4dzgAqlmMViyRYahaGwi6PrSuLmjLsO1oa6Q2DDXg1pEo00ow9C5NFK";
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ModuleProvider()), 
        ChangeNotifierProvider(create: (_) => TreasuryProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => FeesManagementProvider()),
        ChangeNotifierProvider(create: (_) => CreditProvider()), 
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
        ).copyWith(
          bodyLarge: const TextStyle(fontWeight: FontWeight.w600), 
          bodyMedium: const TextStyle(fontWeight: FontWeight.w600),
          titleLarge: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      home: const LoginPage(), 
      routes: {
        '/bank_acc_info': (context) => const BankAccountInfoPage(),
        '/payment_history': (context) => const PaymentHistoryPage(),
        '/notifications': (context) => const NotificationPage(),      
      },
    );
  }
}