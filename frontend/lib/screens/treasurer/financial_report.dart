import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; 
import '../../provider/manage_fees_provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import 'package:intl/intl.dart';

class FinancialReportPage extends StatelessWidget {
  const FinancialReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCF8C6),
      appBar: const UsasHeader(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Consumer<FeesManagementProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                const Text("Reports", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                
                // Date Filter Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text("1/3/2026 - 31/3/2026"),
                      Icon(Icons.filter_list, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Graphs Row
                Row(
                  children: [
                    Expanded(child: _buildChartCard("Payment Summary", _buildBarChart())),
                    const SizedBox(width: 10),
                    Expanded(child: _buildChartCard("Paid vs Unpaid", _buildPieChart(provider))),
                  ],
                ),
                const SizedBox(height: 20),

                // Statistics Row
                // Inside your Stat Row in financial_report.dart
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        "Total Paid", 
                        "RM ${NumberFormat('#,##0.00').format(provider.totalPaidReport)}"
                      )
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        "Outstanding Balance", 
                        "RM ${NumberFormat('#,##0.00').format(provider.totalOutstandingReport)}"
                      )
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        "Blocked Students", 
                        "${provider.summary['blocked'] ?? 0}"
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Download Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton("Download as PDF", Colors.blue),
                    const SizedBox(width: 10),
                    _buildActionButton("Download as CSV", Colors.blue),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 15),
          Expanded(child: chart),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 10),
          Text(value, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  // Hardcoded Bar Chart for Payment Summary
  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 10, color: Colors.cyanAccent, width: 15)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 6, color: Colors.cyan, width: 15)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 3, color: Colors.blueAccent, width: 15)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 2, color: Colors.blueGrey, width: 15)]),
        ],
      ),
    );
  }

  // Dynamic Pie Chart based on Status
  Widget _buildPieChart(FeesManagementProvider provider) {
  return PieChart(
    PieChartData(
      sectionsSpace: 0,
      centerSpaceRadius: 30,
      sections: [
        // Paid Section
        PieChartSectionData(
          color: const Color(0xFFB39DDB),
          value: provider.paidCount.toDouble(),
          title: 'Paid',
          radius: 40,
          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        // Unpaid Section
        PieChartSectionData(
          color: const Color(0xFFFFCC80),
          value: provider.unpaidCountStatus.toDouble(),
          title: 'Unpaid',
          radius: 40,
          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    ),
  );
}

  Widget _buildActionButton(String text, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}