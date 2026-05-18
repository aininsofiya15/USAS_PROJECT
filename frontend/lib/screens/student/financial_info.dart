import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/manage_fees_provider.dart';
import '../../provider/user_provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import 'payment_gateway.dart'; // Ensure MockGatewayPage is written here or update import accordingly

class FinancialInfoPage extends StatefulWidget {
  const FinancialInfoPage({super.key});

  @override
  State<FinancialInfoPage> createState() => _FinancialInfoPageState();
}

class _FinancialInfoPageState extends State<FinancialInfoPage> {
  String? _selectedMethod;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false);
      Provider.of<FeesManagementProvider>(context, listen: false)
          .fetchStudentFinancialProfile(user.userId.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    // Read user provider once to obtain the core ID string safely
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.userId.toString();

    return Scaffold(
      backgroundColor: const Color(0xFFD6EAF8),
      appBar: const UsasHeader(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Consumer<FeesManagementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = provider.selectedStudentDetail;
          if (data == null) return const Center(child: Text("No records found."));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text("Tuition Fees", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                // Reminder Banner
                _buildReminderBanner(),
                const SizedBox(height: 15),

                // Fee Summary Card
                _buildCard("Fee Summary", [
                  _buildRow("Course", data['course_name'] ?? "N/A"),
                  _buildRow("Program", data['program'] ?? "N/A"),
                  _buildRow("Bank", data['bank_name'] ?? "Not Linked"),
                  _buildRow("Bank Account No.", data['acc_no'] ?? "Not Linked"),
                  _buildRow("Total Invoice", "RM ${data['total_invoice'] ?? '0.00'}", isBlue: false), 

                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/payment_history'),
                    child: _buildRow(
                      "Total Payment", 
                      "RM ${data['total_payment'] ?? '0.00'}", 
                      isBlue: true, 
                    ),
                  ),
                  _buildRow("Balance", "RM ${data['outstanding_amount'] ?? '0.00'}"),
                  _buildRow(
                    "Other Bank Account No.", 
                    data['acc_no'] ?? "-", 
                    trailing: SizedBox(
                      height: 25,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/bank_acc_info'),
                        child: const Text("Add or Edit", style: TextStyle(fontSize: 10, color: Colors.white)),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 20),

                // Pay Balance Card
                _buildCard("Pay Balance Fees", [
                  _buildRow("Amount to Pay", "RM ${data['outstanding_amount'] ?? '0.00'}", valueColor: Colors.red),
                  const SizedBox(height: 10),
                  _buildSelectionRow("Choose Payment", "Internet Banking"),
                  _buildSelectionRow("Method", "Credit Card/Debit Card"),
                  const SizedBox(height: 20),
                  
                  // FIXED: Now accurately passing the mapped data state and userId string variables
                  _buildPayButton(data, currentUserId),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper to ensure wide spacing between label and value
  Widget _buildRow(String label, String value, {bool isBlue = false, Color? valueColor, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140, 
            child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          const SizedBox(width: 10), 
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBlue ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? (isBlue ? const Color(0xFF3949AB) : Colors.black87),
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildSelectionRow(String label, String radioTitle) {
    return Row(
      children: [
        SizedBox(
          width: 140, 
          child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: [
              Radio<String>(
                value: radioTitle,
                groupValue: _selectedMethod,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (val) => setState(() => _selectedMethod = val),
              ),
              Text(radioTitle, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReminderBanner() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 11),
                children: [
                  TextSpan(text: "Reminder: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  TextSpan(text: "Access will be blocked after Week 5 if balance unpaid."),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPayButton(Map<String, dynamic> financialData, String dynamicUserId) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2ECC71),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () async {
          final outstanding = double.tryParse(financialData['outstanding_amount']?.toString() ?? '0') ?? 0.0;
          
          if (outstanding <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Your account balance is already settled.")),
            );
            return;
          }

          if (_selectedMethod == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please select a payment method before proceeding.")),
            );
            return;
          }

          final bool? paymentSuccess = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MockGatewayPage(
                userId: dynamicUserId,
                amountToPay: outstanding,
              ),
            ),
          );

          if (paymentSuccess == true) {
            Provider.of<FeesManagementProvider>(context, listen: false)
                .fetchStudentFinancialProfile(dynamicUserId);
          }
        },
        child: const Text(
          "Pay", 
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }
}