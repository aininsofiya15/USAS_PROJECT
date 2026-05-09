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
  bool _hasError = false;
  final List<String> _banks = ['Select bank', 'Maybank', 'CIMB Bank', 'RHB Islamic Bank', 'Bank Islam'];

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to ensure the provider is accessed after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final feeProvider = Provider.of<FeesManagementProvider>(context, listen: false);
      final studentDetail = feeProvider.selectedStudentDetail;

      if (studentDetail != null) {
        setState(() {
          // Fill existing account number
          _accController.text = studentDetail['acc_no']?.toString() ?? '';
          
          // Fill existing bank name if it matches our list
          String? existingBank = studentDetail['bank_name'];
          if (_banks.contains(existingBank)) {
            _selectedBank = existingBank;
          } else {
            _selectedBank = _banks[0]; // Default to 'Select bank'
          }
        });
      }
    });
  }

  // VALIDATION LOGIC
  bool _validateInput() {
    String acc = _accController.text.trim();
    
    if (!RegExp(r'^[0-9]+$').hasMatch(acc)) return false;

    switch (_selectedBank) {
      case 'Maybank':
        return acc.length >= 11 && acc.length <= 15;
      case 'CIMB Bank':
        return acc.length >= 10 && acc.length <= 16 && 
               RegExp(r'^(70|71|80|86|88)').hasMatch(acc);
      case 'RHB Islamic Bank':
        return acc.length >= 12 && acc.length <= 16 && 
               RegExp(r'^(1|2|3)').hasMatch(acc);
      case 'Bank Islam':
        return acc.length >= 12 && acc.length <= 16 && 
               RegExp(r'^(12|13|14|19|20)').hasMatch(acc);
      default:
        return false; 
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, size: 80, color: Colors.black87),
                const SizedBox(height: 20),
                const Text("Record has been saved!", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(context); 
                      Navigator.pop(context); 
                    },
                    child: const Text("OK", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final feeProvider = Provider.of<FeesManagementProvider>(context);
    final studentDetail = feeProvider.selectedStudentDetail;

    return Scaffold(
      backgroundColor: const Color(0xFFD6EAF8), 
      appBar: const UsasHeader(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFBDDDF4),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Column(
              children: [
                const Text(
                  "Tuition Fees",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bank Account No Information",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _accController,
                        keyboardType: TextInputType.number,
                        onChanged: (val) => setState(() => _hasError = !_validateInput()),
                        decoration: InputDecoration(
                          hintText: "Account Number",
                          errorText: _hasError ? "Invalid account number." : null,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedBank,
                            isExpanded: true,
                            items: _banks.map((bank) => DropdownMenuItem(
                              value: bank, 
                              child: Text(bank)
                            )).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedBank = val;
                                _hasError = !_validateInput();
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Insert account number without (-) symbol",
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Note: Only accounts in the student's name are allowed to be updated in the system.",
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9C4), 
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "DECLARATION",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "I confirm that the information provided is true.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                            ),
                            Text(
                              "Name: ${userProvider.name}",
                              style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                            ),
                            Text(
                              "IC Number: ${studentDetail?['ic_no'] ?? 'N/A'}",
                              style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _accController.clear();
                                _selectedBank = _banks[0];
                                _hasError = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE74C3C),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Reset", style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () async {
                              if (_validateInput()) {
                                setState(() => _hasError = false);
                                
                                bool success = await feeProvider.updateBankAccount(
                                  userProvider.userId.toString(), 
                                  _accController.text, 
                                  _selectedBank!
                                );

                                if (success) {
                                  _showSuccessDialog(); 
                                }
                              } else {
                                setState(() => _hasError = true);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2ECC71),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
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
        ],
      ),
    );
  }
}