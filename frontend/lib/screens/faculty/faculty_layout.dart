import 'package:flutter/material.dart';

import '../../widgets/app_sidebar.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';

class FacultyLayout extends StatelessWidget {

  final Widget body;

  const FacultyLayout({
    super.key,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFFDF9EC),

      appBar: const UsasHeader(),

      drawer: const AppSidebar(),

      bottomNavigationBar: const UsasBottomNav(),

      body: body,
    );
  }
}