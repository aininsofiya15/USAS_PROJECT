import 'package:flutter/material.dart';
import '../widgets/base_layout.dart'; // This connects to your master code

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UsasBaseLayout(
      role: UsasRole.student, // Change this to .treasury to see the color change!
      title: "Student Dashboard",
      body: Center(
        child: Text("Welcome to USAS App!"),
      ),
    );
  }
}