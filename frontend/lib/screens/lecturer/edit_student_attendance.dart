import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';
import '../../provider/attendance_provider.dart'; 

class EditStudentAttendance extends StatefulWidget {
  final int attendanceId; // 🔑 Fixed: Received tracking constraint from parent view context
  final int recordId;
  final String matricNo;
  final String studentName;
  final String subjectName;
  final String date;
  final String time;
  final String currentStatus;

  const EditStudentAttendance({
    super.key,
    required this.attendanceId, // 🔑 Fixed: Added to class instance properties
    required this.recordId,
    required this.matricNo,
    required this.studentName,
    required this.subjectName,
    required this.date,
    required this.time,
    required this.currentStatus,
  });

  @override
  State<EditStudentAttendance> createState() => _EditStudentAttendanceState();
}

class _EditStudentAttendanceState extends State<EditStudentAttendance> {
  late String _selectedStatus;
  final TextEditingController _remarkController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus.toLowerCase();
    if (!['present', 'late', 'absent', 'medical'].contains(_selectedStatus)) {
      _selectedStatus = 'present'; 
    }
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveChanges() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final provider = Provider.of<AttendanceProvider>(context, listen: false);
      
      // 🔑 Fixed: Invoked your correct update method using the Postman verified keys!
      bool success = await provider.updateStudentAttendance(
        attendanceId: widget.attendanceId,
        matricNo: widget.matricNo,
        status: _selectedStatus,
        recordId: widget.recordId,
      );

      if (success) {
        // 🔄 Force refresh both database layout streams inside your app interface!
        await provider.fetchClassPresentStudent(widget.attendanceId);
        await provider.fetchClassNotPresentStudent(widget.attendanceId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Attendance updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Safe routing escape back to updated dashboard
        }
      } else {
        throw Exception("Failed to synchronize status update to backend controller.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3D8DA),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            const Text(
              "Student Attendance Detail",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // Profile Data Overview Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildProfileRow("Student ID:", widget.matricNo),
                  const SizedBox(height: 10),
                  _buildProfileRow("Student Name:", widget.studentName),
                  const SizedBox(height: 10),
                  _buildProfileRow("Subject:", widget.subjectName),
                  const SizedBox(height: 10),
                  _buildProfileRow("Date:", widget.date),
                  const SizedBox(height: 10),
                  _buildProfileRow("Time:", widget.time),
                  const SizedBox(height: 10),
                  _buildProfileRow("Current Status:", widget.currentStatus, isStatus: true),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Attendance Operations Action Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Attendance Status",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  
                  _buildRadioOption("Present", "present"),
                  _buildRadioOption("Late", "late"),
                  _buildRadioOption("Absent", "absent"),
                  _buildRadioOption("Medical", "medical"),
                  
                  const SizedBox(height: 10),
                  const Text("Remark:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 5),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _remarkController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Button Set
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _isSaving ? null : () => Navigator.pop(context),
                          child: const Text("CANCEL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ecc71),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _isSaving ? null : _handleSaveChanges,
                          child: _isSaving 
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text("SAVE CHANGES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
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

  Widget _buildProfileRow(String label, String value, {bool isStatus = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isStatus ? FontWeight.bold : FontWeight.normal,
              color: isStatus && value.toLowerCase() == 'present' ? Colors.green : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 13)),
        Radio<String>(
          value: value,
          groupValue: _selectedStatus,
          activeColor: Colors.black,
          onChanged: _isSaving ? null : (String? val) {
            setState(() {
              if (val != null) _selectedStatus = val;
            });
          },
        ),
      ],
    );
  }
}