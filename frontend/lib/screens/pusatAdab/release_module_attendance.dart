import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';
import '../../domain/module.dart';

class ReleaseModuleAttendanceCodePage extends StatelessWidget {
  final Module module;
  final String code;

  const ReleaseModuleAttendanceCodePage({
    super.key,
    required this.module,
    required this.code,
  });

  String _generateLiveTwoHourWindow() {
    DateTime currentTimeCreated = DateTime.now();
    DateTime expirationTime = currentTimeCreated.add(const Duration(hours: 2));
    
    DateFormat displayFormat = DateFormat("h:mm a");
    String startTimeStr = displayFormat.format(currentTimeCreated);
    String endTimeStr = displayFormat.format(expirationTime);
    
    return "$startTimeStr – $endTimeStr";
  }

  void _showSuccessPopup(BuildContext context) {
    final String explicitValidityRange = _generateLiveTwoHourWindow();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(Icons.check, color: Colors.black, size: 32),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Code released successfully!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 12),
                Text(
                  "Attendance code validity:\n$explicitValidityRange",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); 
                      Navigator.popUntil(context, (route) => route.isFirst); 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24D163), 
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFD1FFF3), 
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Release Attendance",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  _buildDisplayRow("Activity:", module.activityName ?? ""),
                  _buildDisplayRow("Date:", module.dateTime ?? ""),
                  _buildDisplayRow("Venue:", module.venue ?? ""),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                  ),
                  
                  const Text(
                    "STUDENT ATTENDANCE CODE",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 12),
                  ),
                  const SizedBox(height: 15),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFF007BFF).withOpacity(0.1)),
                    ),
                    child: Text(
                      code,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF007BFF), 
                        letterSpacing: 10,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 35),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showSuccessPopup(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF28A745), 
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text(
                        "RELEASE CODE",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Back to Edit",
                      style: TextStyle(color: Colors.black38, fontSize: 13),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3F51B5)),
            ),
          ),
        ],
      ),
    );
  }
}