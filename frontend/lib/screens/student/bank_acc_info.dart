import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/manage_fees_provider.dart';
import '../../provider/user_provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';

class BankAccountInfoPage extends StatefulWidget {
  const BankAccountInfoPage({super.key});

  @override
  State<BankAccountInfoPage> createState() => _BankAccountInfoPageState();
}

class _BankAccountInfoPageState extends State<BankAccountInfoPage> {
  final TextEditingController _accController = TextEditingController();
  String? _selectedBank;
  final List<String> _banks = ['Maybank', 'CIMB Bank', 'RHB Islamic Bank', 'Bank Islam'];

  @override
  void initState() {
    super.initState();
    // Pre-fill existing data if available
    final data = Provider.of<FeesManagementProvider>(context, listen: false).selectedStudentDetail;
    if (data != null) {
      _accController.text = data['acc_no'] ?? '';
      if (_banks.contains(data['bank_name'])) {
        _selectedBank = data['bank_name'];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final feeData = Provider.of<FeesManagementProvider>(context).selectedStudentDetail;

    return Scaffold(
      backgroundColor: const Color(0xFFD6EAF8),
      appBar: const UsasHeader(),
      bottomNavigationBar: const UsasBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Tuition Fees", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Bank Account No Information", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  
                  // Account Number Field
                  TextField(
                    controller: _accController,
                    decoration: const InputDecoration(
                      hintText: "Account Number",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Bank Selection Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedBank,
                        hint: const Text("Select bank"),
                        isExpanded: true,
                        items: _banks.map((bank) => DropdownMenuItem(value: bank, child: Text(bank))).toList(),
                        onChanged: (val) => setState(() => _selectedBank = val),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  const Text("Insert account number without (-) symbol", style: TextStyle(fontSize: 11, color: Colors.black54)),
                  const Text("Note: Only accounts in the student's name are allowed to be updated in the system.", 
                    style: TextStyle(fontSize: 11, color: Colors.black54)),
                  
                  const SizedBox(height: 20),

                  // Yellow Declaration Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9C4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text("DECLARATION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 5),
                        const Text("I confirm that the information provided is true.", style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
                        Text("Name: ${userProvider.userName}", style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
                        Text("IC Number: ${feeData?['ic_no'] ?? 'N/A'}", style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => _accController.clear(),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text("Reset", style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Logic to call provider.updateBankAccount() goes here
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ECC71)),
                        child: const Text("Save", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}