import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MockGatewayPage extends StatefulWidget {
  final String userId;
  final double amountToPay;

  const MockGatewayPage({
    super.key,
    required this.userId,
    required this.amountToPay,
  });

  @override
  State<MockGatewayPage> createState() => _MockGatewayPageState();
}

class _MockGatewayPageState extends State<MockGatewayPage> {
  bool _isLoading = false;
  String _selectedBank = 'Maybank2u';

  final List<String> _banks = [
    'Maybank2u',
    'CIMB Clicks',
    'Bank Islam',
    'RHB Now',
    'Public Bank'
  ];

  Future<void> _processMockPayment() async {
    setState(() => _isLoading = true);

    try {
      // 1. Hit your backend to process the database update directly
      // Replace with your exact machine IP (10.0.2.2 for default Android Emulator)
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/student/complete-payment'),
        body: {
          'user_id': widget.userId,
          'amount': widget.amountToPay.toString(),
          'method': 'Internet Banking ($_selectedBank)',
        },
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        // 2. Show a native Success Dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
            title: const Text('Payment Successful'),
            content: Text('RM ${widget.amountToPay.toStringAsFixed(2)} successfully processed via $_selectedBank.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close Dialog
                  Navigator.pop(context, true); // Return to Tuition Page with 'true' signal to refresh
                },
                child: const Text('OK'),
              )
            ],
          ),
        );
      } else {
        _showErrorSnackBar('Server rejected transaction. Try again.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Network connection failed.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FPX Sandbox Terminal', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Amount to Paid:', style: TextStyle(fontSize: 16)),
                          Text(
                            'RM ${widget.amountToPay.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Select Your Bank:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedBank,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _banks.map((bank) {
                      return DropdownMenuItem(value: bank, child: Text(bank));
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedBank = val!);
                    },
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: _processMockPayment,
                      child: const Text(
                        'Proceed Secure Payment',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}