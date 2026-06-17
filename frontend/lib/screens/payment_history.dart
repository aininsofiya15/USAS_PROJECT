import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/manage_fees_provider.dart';
import '../provider/user_provider.dart'; 
import '../widgets/header.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/app_sidebar.dart';

class PaymentHistoryPage extends StatefulWidget {
  final String? targetStudentId;

  const PaymentHistoryPage({super.key, this.targetStudentId});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final String idToFetch = widget.targetStudentId ?? userProvider.userId.toString();

      Provider.of<FeesManagementProvider>(context, listen: false)
          .fetchPaymentHistory(idToFetch);
    });
  }

  double _calculateReceiptTotal(List<dynamic> payments) {
    return payments.fold(0.0, (sum, item) {
      final double amt = double.tryParse(item['total_payment']?.toString() ?? '0') ?? 0.0;
      return sum + amt;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isTreasurerView = widget.targetStudentId != null;

    return Scaffold(
      backgroundColor: isTreasurerView ? const Color(0xFFE8F8E3) : const Color(0xFFE3EFF8),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Consumer<FeesManagementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final payments = provider.paymentHistory;
          final double computedTotal = _calculateReceiptTotal(payments);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Payment History", 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                if (payments.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: Text("No payments found for this student."),
                    ),
                  )
                else
                  // ✅ Container with colored background behind payment history
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isTreasurerView 
                          ? const Color(0xFFC1F6AC) 
                          : const Color(0xFFC6E1EE),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05), 
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          // List Table Headers
                          const Row(
                            children: [
                              Expanded(flex: 3, child: Text("Receipt No", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                              Expanded(flex: 5, child: Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.left)),
                              Expanded(flex: 3, child: Text("Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.right)),
                            ],
                          ),
                          const Divider(thickness: 1, height: 20),

                          // List of Payments
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: payments.length,
                            separatorBuilder: (context, index) => const Divider(color: Colors.black12),
                            itemBuilder: (context, index) {
                              final payment = payments[index];
                              final double amountValue = double.tryParse(payment['total_payment']?.toString() ?? '0') ?? 0.0;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Receipt No
                                    Expanded(
                                      flex: 3, 
                                      child: Text(
                                        payment['payment_id']?.toString() ?? "-", 
                                        style: const TextStyle(color: Color(0xFF3949AB), fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    // Description
                                    Expanded(
                                      flex: 5, 
                                      child: Text(
                                        payment['payment_desc'] ?? "FEES PAYMENT", 
                                        style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.3),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    // Amount
                                    Expanded(
                                      flex: 3, 
                                      child: Text(
                                        "RM ${amountValue.toStringAsFixed(2)}", 
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), 
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const Divider(thickness: 1, height: 30),
                          
                          // Dynamic Total Footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text("TOTAL", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54)),
                              const SizedBox(width: 20),
                              Text(
                                "RM ${computedTotal.toStringAsFixed(2)}", 
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}