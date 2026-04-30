import 'package:flutter/material.dart';

class FeesManagementPage extends StatelessWidget {
  const FeesManagementPage({super.key}); // This 'const' allows you to use 'const' elsewhere

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fees Management")),
      body: const Center(child: Text("Fees Management Content Coming Soon")),
    );
  }
}