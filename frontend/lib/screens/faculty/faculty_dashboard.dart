import 'package:flutter/material.dart';
import 'subject_registration_page.dart';


class FacultyDashboard extends StatelessWidget {
  final String name;
  final int totalSubjects;

  const FacultyDashboard({
    super.key,
    required this.name,
    required this.totalSubjects,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),

      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Welcome Text
            Text(
              "Welcome, $name!",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2C3E),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Manage subjects, sections and labs",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 25),

            // Search Bar
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.74,
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const TextField(
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                      suffixIcon: Icon(Icons.search, color: Colors.black45, size: 19),
                      suffixIconConstraints: BoxConstraints(minWidth: 42, minHeight: 36),
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(18, 10, 0, 10),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),

            // Categories Title
            const Center(
              child: Text(
                "Categories",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Subject Registration Card
            Center(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const SubjectRegistrationPage(),
                    ),
                  );
                },
                child: Container(
                  width: 170,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EDC9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [

                        Image.asset(
                          "assets/icons/sub_reg.png",
                          width: 90,
                          height: 90,
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Subject\nRegistration",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Recent Updates Title
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Updates",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Statistic Card
            Center(
              child: Container(
                width: 150,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    const Text(
                      "Total Current\nRegistered Subjects",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      totalSubjects.toString(),
                      style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8A8D04),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
