import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/treasurer_provider.dart';
import '../../widgets/menu_card.dart';
import '../../widgets/summary_card.dart';
import 'fees_management.dart';
import 'financial_report.dart';

class TreasuryDashboardBody extends StatefulWidget {
  final String name;
  const TreasuryDashboardBody({super.key, required this.name});

  @override
  State<TreasuryDashboardBody> createState() => _TreasuryDashboardBodyState();
}

class _TreasuryDashboardBodyState extends State<TreasuryDashboardBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TreasuryProvider>(context, listen: false).fetchDashboardSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TreasuryProvider>(
      builder: (context, treasuryProvider, child) {
        return RefreshIndicator(
          onRefresh: () => treasuryProvider.fetchDashboardSummary(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, ${widget.name}!",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // --- SEARCH BAR (New) ---
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Search",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  const Text(
                    "Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // --- CATEGORIES SECTION WITH PROTOTYPE BG ---
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC1F6AC), // Prototype Color
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TreasuryMenuCard(
                            icon: Icons.account_balance_wallet,
                            title: "Tuition Fees",
                            color: Colors.blue.shade700,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FeesManagementPage()),
                            ).then((_) => treasuryProvider.refreshDashboard()),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TreasuryMenuCard(
                            icon: Icons.assessment,
                            title: "Reports",
                            color: Colors.teal,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FinancialReportPage()),
                            ).then((_) => treasuryProvider.refreshDashboard()),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    "Overview",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // --- OVERVIEW SECTION WITH PROTOTYPE BG ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC1F6AC), // Prototype Color
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: _buildOverviewGrid(treasuryProvider),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewGrid(TreasuryProvider treasuryProvider) {
    if (treasuryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Layout following Screenshot 2026-05-06 142351.png
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TreasurySummaryCard(
                label: "Total Collected Today",
                value: "RM ${treasuryProvider.totalCollectedToday.toStringAsFixed(2)}",
                
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: TreasurySummaryCard(
                label: "Total Collected This Week",
                value: "RM ${treasuryProvider.totalCollectedThisWeek.toStringAsFixed(2)}",
                
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: TreasurySummaryCard(
                label: "Total Students",
                value: treasuryProvider.totalStudents.toString(),
                
              ),
            ),
            const Spacer(), // Matches the prototype layout where the 4th spot is empty
          ],
        ),
        if (treasuryProvider.errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              "Note: Showing cached data. ${treasuryProvider.errorMessage}",
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}