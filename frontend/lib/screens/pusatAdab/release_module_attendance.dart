import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/attendance_provider.dart';
import '../../domain/module.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';

class ReleaseModuleAttendanceCodePage extends StatefulWidget {
  final Module module;
  final String code; 

  const ReleaseModuleAttendanceCodePage({
    super.key,
    required this.module,
    required this.code,
  });

  @override
  State<ReleaseModuleAttendanceCodePage> createState() => _ReleaseModuleAttendanceCodePageState();
}

class _ReleaseModuleAttendanceCodePageState extends State<ReleaseModuleAttendanceCodePage> {
  bool _isReleasing = false;

  Future<void> _releaseCode() async {
    setState(() => _isReleasing = true);

    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    
    // Uses the code passed from the previous page
    final success = await provider.storeModuleAttendance(
      moduleId: widget.module.id ?? 0,
      code: widget.code,
    );

    setState(() => _isReleasing = false);

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Attendance Released to Students!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to release code. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateString = widget.module.dateTime.contains(' ') 
        ? widget.module.dateTime.split(' ').first 
        : widget.module.dateTime;
    final timeString = widget.module.dateTime.contains(' ') 
        ? widget.module.dateTime.split(' ').last 
        : 'N/A';

    return Scaffold(
      backgroundColor: const Color(0xFFD1FFF3), // Green theme
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
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildDisplayRow("Activity:", widget.module.activityName),
                  _buildDisplayRow("Venue:", widget.module.venue),
                  _buildDisplayRow("Date:", dateString),
                  _buildDisplayRow("Time:", timeString),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                  ),
                  
                  const Text(
                    "STUDENT ATTENDANCE CODE",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Display the code generated on the previous page
                  Container(
                    width: double.infinity,
                    height: 110, 
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFF007BFF).withOpacity(0.1)),
                    ),
                    child: Text(
                      widget.code,
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
                      onPressed: _isReleasing ? null : _releaseCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF28A745),
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: _isReleasing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              "RELEASE CODE",
                              style: TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                color: Color(0xFF3F51B5), 
              ),
            ),
          ),
        ],
      ),
    );
  }
}