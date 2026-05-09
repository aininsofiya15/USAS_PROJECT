import 'package:flutter/material.dart';
import '../../widgets/header.dart'; 
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';
import 'financial_info.dart';

class StudentDashboard extends StatelessWidget {
  final String name;
  const StudentDashboard({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF), 
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, $name!",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            
            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 25),

            _buildSectionTitle("Categories"),
            const SizedBox(height: 10),

            // Categories Grid (2x2)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1,
              children: [
                _buildCategoryCard("Subject Registration", "assets/icons/sub_reg.png", () {}),
                _buildCategoryCard("Curriculum Activity", "assets/icons/curriculum.png", () {}),
                _buildCategoryCard("Attendance", "assets/icons/attendance.png", () {}),
                _buildCategoryCard("Tuition Fees", "assets/icons/tuition.png", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const FinancialInfoPage()));
                }),
              ],
            ),

            const SizedBox(height: 30),
            _buildSectionTitle("Recent Updates"),
            const SizedBox(height: 10),

            // Recent Updates Horizontal List
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildProgressCard("Curriculum Progress", 0.7),
                  _buildStatCard("Total Credit Current Sem", "12"),
                  _buildStatCard("Upcoming Due Date", "13 April\n12:30 PM", isDate: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Search",
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (title == "Categories")
          TextButton(onPressed: () {}, child: const Text("See All", style: TextStyle(color: Colors.green))),
      ],
    );
  }

  Widget _buildCategoryCard(String title, String iconPath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.apps, size: 40, color: Colors.blue), // Replace with Image.asset(iconPath)
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3F51B5))),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(String title, double progress) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
          const Spacer(),
          Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(value: progress, strokeWidth: 8, backgroundColor: Colors.grey.shade200),
              Text("${(progress * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: StadiumBorder(), padding: EdgeInsets.symmetric(horizontal: 10)),
            child: const Text("Add Module", style: TextStyle(fontSize: 10, color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, {bool isDate = false}) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Text(value, style: TextStyle(fontSize: isDate ? 16 : 40, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}