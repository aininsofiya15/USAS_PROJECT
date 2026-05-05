import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/treasurer_provider.dart';
import '../../widgets/menu_card.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/overview_card.dart';
import '../../widgets/error.dart';
import '../../widgets/loading.dart';
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
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message
                Text(
                  "Welcome, ${widget.name}!",
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Categories section
                const Text(
                  "Categories",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Row(
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
                    const SizedBox(width: 20),
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

                const SizedBox(height: 30),
                const Text(
                  "Overview",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Dynamic content based on state
                _buildDynamicContent(treasuryProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDynamicContent(TreasuryProvider treasuryProvider) {
    if (treasuryProvider.isLoading) {
      return const TreasuryLoadingWidget();
    }

    if (treasuryProvider.errorMessage.isNotEmpty) {
      return TreasuryErrorWidget(
        errorMessage: treasuryProvider.errorMessage,
        onRetry: () => treasuryProvider.fetchDashboardSummary(),
      );
    }

    return Column(
      children: [
        // Summary Cards Row (Paid, Unpaid, Blocked)
        Row(
          children: [
            Expanded(
              child: TreasurySummaryCard(
                label: "Paid Students",
                value: treasuryProvider.paidStudents.toString(),
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: TreasurySummaryCard(
                label: "Unpaid Students",
                value: treasuryProvider.unpaidStudents.toString(),
                icon: Icons.warning,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: TreasurySummaryCard(
                label: "Blocked Students",
                value: treasuryProvider.blockedStudents.toString(),
                icon: Icons.block,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Total Students Card
        TreasuryOverviewCard(
          label: "Total Students",
          value: treasuryProvider.totalStudents.toString(),
          icon: Icons.people,
          color: Colors.purple,
        ),
        const SizedBox(height: 15),

        // Financial Cards
        TreasuryOverviewCard(
          label: "Total Collected Today",
          value: "RM ${treasuryProvider.totalCollectedToday.toStringAsFixed(2)}",
          icon: Icons.today,
          color: Colors.orange,
        ),
        const SizedBox(height: 15),
        TreasuryOverviewCard(
          label: "Total Collected This Week",
          value: "RM ${treasuryProvider.totalCollectedThisWeek.toStringAsFixed(2)}",
          icon: Icons.trending_up,
          color: Colors.green,
        ),
      ],
    );
  }
}