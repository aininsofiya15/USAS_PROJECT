import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/manage_fees_provider.dart';
import '../../provider/user_provider.dart'; 
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  @override
  void initState() {
    super.initState();
    // Fetch history when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false);
      Provider.of<FeesManagementProvider>(context, listen: false)
          .fetchPaymentHistory(user.userId.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6EAF8),
      appBar: const UsasHeader(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Consumer<FeesManagementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final payments = provider.paymentHistory;
          final total = provider.selectedStudentDetail?['total_payment'] ?? '0.00';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text("Payment History", 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                if (payments.isEmpty)
                  const Center(child: Text("No payments found."))
                else

                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      // Header
                      const Row(
                        children: [
                          Expanded(flex: 2, child: Text("Receipt No", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                          Expanded(flex: 4, child: Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center)),
                          Expanded(flex: 2, child: Text("Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.right)),
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
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Receipt No (payment_id)
                                Expanded(
                                  flex: 2, 
                                  child: Text(
                                    payment['payment_id']?.toString() ?? "-", 
                                    style: const TextStyle(color: Color(0xFF3949AB), fontSize: 11, fontWeight: FontWeight.w600)
                                  )
                                ),
                                // Description (payment_desc)
                                Expanded(
                                  flex: 4, 
                                  child: Text(
                                    payment['payment_desc'] ?? "FEES PAYMENT", 
                                    style: const TextStyle(fontSize: 10, color: Colors.black87),
                                    textAlign: TextAlign.left,
                                  )
                                ),
                                // Amount
                                Expanded(
                                  flex: 2, 
                                  child: Text(
                                    "RM ${payment['amount']}", 
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), 
                                    textAlign: TextAlign.right
                                  )
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const Divider(thickness: 1, height: 30),
                      // Total Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text("TOTAL", style: TextStyle(fontSize: 12, color: Colors.black54)),
                          const SizedBox(width: 20),
                          Text("RM $total", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
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