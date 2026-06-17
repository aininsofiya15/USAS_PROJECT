import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';
import '../../provider/attendance_provider.dart'; 

class EditStudentModuleAttendance extends StatefulWidget {
  final int attendanceId; 
  final int recordId;
  final int studentId;       // 🟢 Used for backend API sync
  final String matricNo;     // 🟢 Used for UI layout text display
  final String studentName;
  final String moduleName;
  final String date;
  final String time;
  final String currentStatus;

  const EditStudentModuleAttendance({
    super.key,
    required this.attendanceId, 
    required this.recordId,
    required this.studentId,   
    required this.matricNo,    
    required this.studentName,
    required this.moduleName,
    required this.date,
    required this.time,
    required this.currentStatus,
  });

  @override
  State<EditStudentModuleAttendance> createState() => _EditStudentModuleAttendanceState();
}

class _EditStudentModuleAttendanceState extends State<EditStudentModuleAttendance> {
  late String _selectedStatus;
  final TextEditingController _remarkController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus.toLowerCase().trim();
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
  setState(() => _isSaving = true);

  try {
    final provider = Provider.of<AttendanceProvider>(context, listen: false);

    bool success = await provider.updateStudentModuleAttendance(
      attendanceId: widget.attendanceId,
      recordId: widget.recordId,
      studentId: widget.studentId,
      status: _selectedStatus,
      remark: _remarkController.text.trim(),
    );

    if (success) {
      // ✅ Provider already re-fetched; just pop back with true
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Module attendance updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      throw Exception('Failed to sync changes to server.');
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
    if (mounted) setState(() => _isSaving = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8FDF9), 
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          decoration: BoxDecoration(
            color: const Color(0xFFC2F0E5), 
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const Text(
                "Module Attendance Records",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildModuleRow("Student ID:", widget.matricNo), // Displays readable matric no (e.g. CB23024)
                    const SizedBox(height: 12),
                    _buildModuleRow("Student Name:", widget.studentName, isLongText: true),
                    const SizedBox(height: 12),
                    _buildModuleRow("Module:", widget.moduleName.toUpperCase(), isLongText: true), 
                    const SizedBox(height: 12),
                    _buildModuleRow("Date:", widget.date),
                    const SizedBox(height: 12),
                    _buildModuleRow("Time:", widget.time),
                    const SizedBox(height: 12),
                    _buildModuleRow("Current Status:", widget.currentStatus, isStatus: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Attendance Status",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                    ),
                    const SizedBox(height: 15),
                    
                    _buildRadioOption("Present", "present"),
                    _buildRadioOption("Late", "late"),
                    _buildRadioOption("Absent", "absent"),
                    _buildRadioOption("Medical", "medical"),
                    
                    const SizedBox(height: 12),
                    const Text("Remark:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
                    const SizedBox(height: 6),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4F3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _remarkController,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                          hintText: "Add remarks here...",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE57373),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _isSaving ? null : () => Navigator.pop(context, false),
                            child: const Text("CANCEL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2ECC71),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _isSaving ? null : _handleSaveChanges,
                            child: _isSaving 
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text("SAVE CHANGES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
      ),
    );
  }

  Widget _buildModuleRow(String label, String value, {bool isStatus = false, bool isLongText = false}) {
    Color textColor = Colors.black87;
    FontWeight weight = FontWeight.normal;
    
    if (isStatus) {
      weight = FontWeight.bold;
      switch (value.toLowerCase().trim()) {
        case 'present': textColor = const Color(0xFF27AE60); break;
        case 'late': textColor = const Color(0xFFF2994A); break;
        case 'absent': textColor = const Color(0xFFD32F2F); break;
        case 'medical': textColor = const Color(0xFF2980B9); break;
      }
    }

    return Row(
      crossAxisAlignment: isLongText ? CrossAxisAlignment.end : CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: weight,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String title, String value) {
    final bool isChecked = (_selectedStatus == value);
    return InkWell(
      onTap: _isSaving ? null : () {
        setState(() {
          _selectedStatus = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              isChecked ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isChecked ? Colors.black : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}