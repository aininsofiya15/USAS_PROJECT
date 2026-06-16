import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/manage_fees_provider.dart'; // Correct provider
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
    // Fetch data using the FeesManagementProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeesManagementProvider>(context, listen: false).fetchDashboardSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeesManagementProvider>(
      builder: (context, feeProvider, child) {
        return RefreshIndicator(
          onRefresh: () => feeProvider.fetchDashboardSummary(),
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

                  // --- SEARCH BAR ---
                  Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.74,
                      child: Container(
                        height: 36,
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
                  const SizedBox(height: 25),

                  // --- CATEGORIES SECTION ---
                  const Text(
                    "Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC1F6AC),
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
                            ).then((_) => feeProvider.refreshDashboard()),
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
                            ).then((_) => feeProvider.refreshDashboard()),
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

                  // --- OVERVIEW SECTION ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC1F6AC), 
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: _buildOverviewGrid(feeProvider),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Updated parameter to use FeesManagementProvider
  Widget _buildOverviewGrid(FeesManagementProvider provider) {
    // Show spinner if loading and we have no data yet
    if (provider.isLoading && provider.totalStudents == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TreasurySummaryCard(
                label: "Total Collected Today",
                value: "RM ${provider.totalCollectedToday.toStringAsFixed(2)}",
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: TreasurySummaryCard(
                label: "Total Collected This Week",
                value: "RM ${provider.totalCollectedThisWeek.toStringAsFixed(2)}",
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
                value: provider.totalStudents.toString(),
              ),
            ),
            const Spacer(), 
          ],
        ),
        // Error message handling
        if (provider.errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              "Note: ${provider.errorMessage}",
              style: const TextStyle(
                color: Colors.red, 
                fontSize: 12, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
      ],
    );
  }
}
