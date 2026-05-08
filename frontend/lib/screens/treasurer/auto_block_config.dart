import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../provider/manage_fees_provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';

class AutoBlockConfigPage extends StatefulWidget {
  const AutoBlockConfigPage({Key? key}) : super(key: key);

  @override
  State<AutoBlockConfigPage> createState() => _AutoBlockConfigPageState();
}

class _AutoBlockConfigPageState extends State<AutoBlockConfigPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<FeesManagementProvider>(context, listen: false).fetchUnpaidCount()
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.black, size: 80),
            const SizedBox(height: 16),
            const Text("Block start date has been set!", 
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(100, 40),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FeesManagementProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFDCF8C6),
      appBar: const UsasHeader(),
      bottomNavigationBar: const UsasBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Block Settings", 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSection("Block Start Date", 
                          child: Row(
                            children: [
                              Text(DateFormat('dd MMMM yyyy').format(provider.selectedBlockDate)),
                              IconButton(
                                icon: const Icon(Icons.calendar_today_outlined, size: 20),
                                onPressed: () async {
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: provider.selectedBlockDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setState(() => provider.selectedBlockDate = picked);
                                  }
                                },
                              )
                            ],
                          )
                        ),
                        _buildSection("Block Eligibility Preview", 
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text("Unpaid students    ${provider.unpaidCount}"),
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "On block date, ${provider.unpaidCount} student will automatically blocked from academic activities. They can still access Tuition Fees to pay.",
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2ECC71),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          bool success = await provider.saveBlockDate();
                          if (success) _showSuccessDialog();
                        },
                        child: const Text("Save", style: TextStyle(color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, {required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        child,
      ],
    );
  }
}