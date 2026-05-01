import 'package:flutter/material.dart';

class StudTuitionOverviewPage extends StatelessWidget {
  final Map<String, String> studentData;

  const StudTuitionOverviewPage({super.key, required this.studentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Overview: ${studentData['name']}")),
      body: Center(child: Text("Viewing details for ${studentData['matric']}")),
    );
  }
}