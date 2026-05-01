import 'package:flutter/material.dart';

class FinancialReportPage extends StatelessWidget {
  const FinancialReportPage({super.key}); // This 'const' allows you to use 'const' elsewhere

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Financial Report")),
      body: const Center(child: Text("Financial Report Coming Soon")),
    );
  }
}