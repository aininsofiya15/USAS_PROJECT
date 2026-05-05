import 'package:flutter/material.dart';
import 'subject_form_page.dart';

class SubjectRegistrationPage extends StatelessWidget {
  const SubjectRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Subject Registration")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SubjectFormPage(),
              ),
            );
          },
          child: const Text("+ Add Subject"),
        ),
      ),
    );
  }
}