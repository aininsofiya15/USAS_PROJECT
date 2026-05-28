import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/module.dart';
import '../../provider/attendance_provider.dart';
import '../../widgets/header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/navigation_bar.dart';

class GradeStudentPage extends StatefulWidget {
  final dynamic student; 
  final Module module;

  const GradeStudentPage({
    super.key,
    required this.student,
    required this.module,
  });

  @override
  State<GradeStudentPage> createState() => _GradeStudentPageState();
}

class _GradeStudentPageState extends State<GradeStudentPage> {
  final TextEditingController _marksController = TextEditingController();
  String _selectedGradeCategory = 'Fail'; // Default fallback status option

  @override
  void initState() {
    super.initState();

    // ── 🎯 NEW: Pre-fill fields if the student has already been graded ──
    if (widget.student['marks'] != null) {
      double existingMarks = double.tryParse(widget.student['marks'].toString()) ?? 0;
      
      // Strips trailing decimal points for cleaner layout text display (e.g., 85.0 -> 85)
      _marksController.text = existingMarks % 1 == 0 
          ? existingMarks.toInt().toString() 
          : existingMarks.toString();
          
      _selectedGradeCategory = widget.student['grade_category'] ?? 'Fail';
    }

    // Attached listener to handle live grade category auto-calculations as you type
    _marksController.addListener(_handleLiveGradeCalculation);
  }

  @override
  void dispose() {
    _marksController.removeListener(_handleLiveGradeCalculation);
    _marksController.dispose();
    super.dispose();
  }

  // ── Live Category Calculation (Typing -> Updates Radio Selection) ─────
  void _handleLiveGradeCalculation() {
    final text = _marksController.text.trim();
    if (text.isEmpty) {
      setState(() => _selectedGradeCategory = 'Fail');
      return;
    }

    final double? marks = double.tryParse(text);
    if (marks == null) return;

    String calculatedCategory = 'Fail';
    if (marks >= 80) {
      calculatedCategory = 'Excellent';
    } else if (marks >= 60) {
      calculatedCategory = 'Satisfactory';
    } else if (marks >= 40) {
      calculatedCategory = 'Pass';
    }

    if (_selectedGradeCategory != calculatedCategory) {
      setState(() => _selectedGradeCategory = calculatedCategory);
    }
  }

  // ── Radio Click Option Handler (Radio Click -> Auto-fills Text Field) ──
  void _handleRadioSelection(String category) {
    setState(() {
      _selectedGradeCategory = category;
      
      switch (category) {
        case 'Excellent':
          _marksController.text = '80';
          break;
        case 'Satisfactory':
          _marksController.text = '60';
          break;
        case 'Pass':
          _marksController.text = '40';
          break;
        case 'Fail':
          _marksController.text = '0';
          break;
      }
      
      _marksController.selection = TextSelection.fromPosition(
        TextPosition(offset: _marksController.text.length),
      );
    });
  }

  // ── Custom Success Dialog Window Popup Layout ────────────────────────
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 5,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Outline Checkmark Circle
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black87, width: 2),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.black87,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),

                // Success Description Label
                const Text(
                  'Marks updated successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Solid Green UI Dismiss Button
                SizedBox(
                  width: 90,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog modal
                      Navigator.pop(context, true); // Pop back to active list view screen with refresh flag
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2EB85C),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
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

  // ── Form Submission Logic ─────────────────────────────────────────────
  Future<void> _handleSave(AttendanceProvider provider, int recordId) async {
    final text = _marksController.text.trim();
    
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter student marks before saving.')),
      );
      return;
    }

    try {
      final double marks = double.parse(text);
      
      bool success = await provider.submitStudentGrade(recordId, marks);

      if (success && mounted) {
        _showSuccessDialog(); // Triggers your clean wireframe alert dialog window popup
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Grading Error: ${e.toString().replaceAll('Exception:', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Component Construction Tree Layouts ───────────────────────────────
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioItem(String category) {
    bool isSelected = _selectedGradeCategory == category;
    return InkWell(
      onTap: () => _handleRadioSelection(category), 
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.black87 : Colors.grey.shade400,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              category,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String studentName = widget.student['student_name'] ?? 'Unknown';
    final String matrixNo = widget.student['matrix_no'] ?? 'N/A';
    final String currentStatus = widget.student['attendance_status'] ?? 'Present';
    
    // Safely pulls your record ID with fallback support matching your newly updated Laravel controller query select statement aliases
    final int recordId = widget.student['id'] ?? 0;

    // Connect page layout elements to look up current loading states
    final attendanceProvider = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFD1FFF3), // Custom USAS cyan tint profile token
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Page Title
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                'Attendance Records',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),

            // Profile Container Info Box
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Student ID:', matrixNo),
                  _buildDetailRow('Student Name:', studentName),
                  _buildDetailRow('Module:', widget.module.activityName.toUpperCase()),
                  _buildDetailRow('Date:', widget.module.dateTime?.split(' ')[0] ?? '2026-05-20'),
                  _buildDetailRow('Time:', '08:00AM - 05:00PM'),
                  _buildDetailRow('Current Status:', currentStatus),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Assessment Container Layout Form Box
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Student Marks',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),

                  // Numeric input Field Window Block
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _marksController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                        hintText: 'Enter marks (0-100%)',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(bottom: 6),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  _buildRadioItem('Excellent'),
                  _buildRadioItem('Satisfactory'),
                  _buildRadioItem('Pass'),
                  _buildRadioItem('Fail'),

                  const SizedBox(height: 24),

                  // Action Buttons Footer Row Layout Control Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Cancel Button
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE55353),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: const Text(
                            'CANCEL',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Async Progress Submission Button
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: attendanceProvider.isSubmitting 
                              ? null 
                              : () => _handleSave(attendanceProvider, recordId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2EB85C),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: attendanceProvider.isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'SAVE CHANGES',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}