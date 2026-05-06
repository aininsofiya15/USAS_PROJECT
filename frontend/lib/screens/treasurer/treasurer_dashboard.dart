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
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome, ${widget.name}!",
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

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
      return Center(child: CircularProgressIndicator());
    }

    if (treasuryProvider.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          children: [
            Text(treasuryProvider.errorMessage),
            ElevatedButton(
              onPressed: () => treasuryProvider.fetchDashboardSummary(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
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
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Students',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      treasuryProvider.totalStudents.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Today\'s Collection'),
                    Text(
                      'RM ${treasuryProvider.totalCollectedToday.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('This Week\'s Collection'),
                    Text(
                      'RM ${treasuryProvider.totalCollectedThisWeek.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}