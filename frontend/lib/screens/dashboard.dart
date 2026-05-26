import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';

import '../widgets/app_sidebar.dart';
import '../widgets/header.dart';
import '../widgets/navigation_bar.dart';

import 'pusatAdab/adab_dashboard.dart';
import 'lecturer/lecturer_dashboard.dart';
import 'treasurer/treasurer_dashboard.dart';
import 'student/student_dashboard.dart';
import 'faculty/faculty_dashboard.dart';
import 'faculty/subject_form_page.dart';

class DashboardPage extends StatelessWidget {

  const DashboardPage({super.key});

  // FETCH TOTAL SUBJECTS FROM LARAVEL API
  Future<int> fetchTotalSubjects() async {

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/total-subjects'),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return data['totalSubjects'];

    } else {

      throw Exception('Failed to load total subjects');
    }
  }

  // BACKGROUND COLOR
  Color getBackgroundColor(String role) {
    switch (role) {

      case 'student':
        return const Color(0xFFE3EFF8);

      case 'faculty':
        return const Color(0xFFFDF9EC);

      case 'treasury':
        return const Color(0xFFE8F8E3);

      case 'pusat_adab':
        return const Color(0xFFD5FFF7);

      case 'lecturer':
        return const Color(0xFFFBEBEB);

      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {

    // GET USER DATA FROM PROVIDER
    final user = Provider.of<UserProvider>(context);

    final String name = user.name;
    final String role = user.role;

    return _buildRoleSpecificBody(name, role);
  }

  Widget _buildRoleSpecificBody(String name, String role) {

    switch (role) {

      // STUDENT
      case 'student':

        return StudentDashboard(name: name);

      // PUSAT ADAB
      case 'pusat_adab':

        return Scaffold(
          backgroundColor: const Color(0xFFD5FFF7),
          appBar: const UsasHeader(),
          drawer: const AppSidebar(),
          bottomNavigationBar: const UsasBottomNav(),
          body: PusatAdabBody(name: name),
        );

      // FACULTY
      case 'faculty':

        return FutureBuilder<int>(

          future: fetchTotalSubjects(),

          builder: (context, snapshot) {

            // LOADING
            if (!snapshot.hasData) {

              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // SUCCESS
            return Scaffold(

              backgroundColor: const Color(0xFFFDF9EC),

              appBar: const UsasHeader(),

              drawer: const AppSidebar(),

              bottomNavigationBar: const UsasBottomNav(),

              body: FacultyDashboard(

                name: name,

                totalSubjects: snapshot.data!,
              ),
            );
          },
        );

      // LECTURER
      case 'lecturer':

        return Scaffold(
          backgroundColor: const Color(0xFFFBEBEB),
          appBar: const UsasHeader(),
          drawer: const AppSidebar(),
          bottomNavigationBar: const UsasBottomNav(),
          body: LecturerBody(name: name),
        );

      // TREASURY
      case 'treasury':

        return Scaffold(
          backgroundColor: const Color(0xFFE8F8E3),
          appBar: const UsasHeader(),
          drawer: const AppSidebar(),
          bottomNavigationBar: const UsasBottomNav(),
          body: TreasuryDashboardBody(name: name),
        );

      // DEFAULT
      default:

        return Scaffold(
          appBar: const UsasHeader(),
          body: Center(
            child: Text(
              "Welcome back, $name!\nRole: ${role.toUpperCase()}",
            ),
          ),
        );
    }
  }
}