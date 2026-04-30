import 'package:flutter/material.dart';
import 'feesManagement.dart'; // Ensure this filename matches your project
import 'financialReport.dart'; // Ensure this filename matches your project

class TreasuryDashboardBody extends StatelessWidget {
  final String name;
  const TreasuryDashboardBody({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section based on UI-401
          Text(
            "Welcome, $name!",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Categories Section
          const Text(
            "Categories",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildMenuCard(
                  context,
                  Icons.account_balance_wallet,
                  "Tuition Fees",
                  Colors.blue.shade700,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FeesManagementPage()),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildMenuCard(
                  context,
                  Icons.assessment,
                  "Reports",
                  Colors.teal,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FinancialReportPage()),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Overview Section based on UI-401 Mockup
          const Text(
            "Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          
          // Financial Summary Cards
          _buildOverviewCard(
            "Total Collected This Week",
            "RM 25,200.00",
            Icons.trending_up,
            Colors.green,
          ),
          const SizedBox(height: 15),
          _buildOverviewCard(
            "Total Collected Today",
            "RM 5,780.00",
            Icons.today,
            Colors.orange,
          ),
          const SizedBox(height: 15),
          _buildOverviewCard(
            "Total Students",
            "5,815",
            Icons.people,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  // Widget for the top category buttons
  Widget _buildMenuCard(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // Widget for the Overview statistics list
  Widget _buildOverviewCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }
}