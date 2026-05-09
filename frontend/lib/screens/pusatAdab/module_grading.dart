import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/attendance_provider.dart';
import '../../domain/module.dart';
import '../../widgets/header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/navigation_bar.dart';

class GradeStudentPage extends StatefulWidget {
  final dynamic student; // your StudentRecord domain object
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

  // Radio options that map a label to the threshold it represents
  static const List<_GradeOption> _gradeOptions = [
    _GradeOption(label: 'Excellent',    min: 80),
    _GradeOption(label: 'Satisfactory', min: 60),
    _GradeOption(label: 'Pass',         min: 50),
    _GradeOption(label: 'Fail',         min: 0),
  ];

  // Which radio is currently selected (derived from typed marks)
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final existing = widget.student.marks?.toString() ?? '';
    _marksController.text = existing;
    if (existing.isNotEmpty) {
      _selectedCategory = _categoryFromMarks(double.tryParse(existing));
    }
  }

  @override
  void dispose() {
    _marksController.dispose();
    super.dispose();
  }

  String? _categoryFromMarks(double? marks) {
    if (marks == null) return null;
    if (marks >= 80) return 'Excellent';
    if (marks >= 60) return 'Satisfactory';
    if (marks >= 50) return 'Pass';
    return 'Fail';
  }

  void _onMarksChanged(String val) {
    final parsed = double.tryParse(val);
    setState(() => _selectedCategory = _categoryFromMarks(parsed));
  }

  void _onRadioChanged(String category) {
    setState(() => _selectedCategory = category);
    // Optionally pre-fill the marks field with the midpoint of the range
    final midpoints = {
      'Excellent': '90',
      'Satisfactory': '70',
      'Pass': '55',
      'Fail': '40',
    };
    if (_marksController.text.isEmpty) {
      _marksController.text = midpoints[category] ?? '';
    }
  }

  Future<void> _saveChanges() async {
    final marks = double.tryParse(_marksController.text);
    if (marks == null || marks < 0 || marks > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid mark between 0–100')),
      );
      return;
    }
    final category = _categoryFromMarks(marks) ?? 'Fail';
    await context.read<AttendanceProvider>().updateStudentGrade(
      widget.student.id,
      marks,
      category,
    );

    if (!mounted) return;

    final provider = context.read<AttendanceProvider>();
    if (provider.errorMessage != null) {
      // Show error — stay on page so user can retry
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red[700],
        ),
      );
    } else {
      // Success — go back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grade saved successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
    final module  = widget.module;

    return Scaffold(
      backgroundColor: const Color(0xFFD1FFF3),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Page Title ─────────────────────────────────────────────
            const Center(
              child: Text(
                'Attendance Records',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Student Info Card ──────────────────────────────────────
            _infoCard(student, module),

            const SizedBox(height: 16),

            // ── Student Marks Card ────────────────────────────────────
            _marksCard(),
          ],
        ),
      ),
    );
  }

  // ── Student Info Card ─────────────────────────────────────────────────────
  Widget _infoCard(dynamic student, Module module) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow('Student ID',     student.studentId),
          _infoRow('Student Name',   student.studentName),
          _infoRow('Module',         module.activityName.toUpperCase()),
          _infoRow('Date',           _formatDate(module.dateTime)),
          _infoRow('Time',           _formatTime(module.dateTime)),
          _infoRow('Current Status', student.status,
              valueColor: student.status.toLowerCase() == 'present'
                  ? Colors.green[700]
                  : Colors.red[700]),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                color: valueColor ?? Colors.black87,
                fontWeight: valueColor != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Marks Card ────────────────────────────────────────────────────────────
  Widget _marksCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title
          const Text(
            'Student Marks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),

          // Marks Text Field
          TextField(
            controller: _marksController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: _onMarksChanged,
            decoration: InputDecoration(
              hintText: 'Enter marks (0-100%)',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF4D8EFF), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Radio Grade Options
          ..._gradeOptions.map((opt) => _gradeRadio(opt.label)),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00CC66),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'SAVE CHANGES',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gradeRadio(String label) {
    final isSelected = _selectedCategory == label;
    return InkWell(
      onTap: () => _onRadioChanged(label),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Radio<String>(
                value: label,
                groupValue: _selectedCategory,
                onChanged: (val) => _onRadioChanged(val!),
                activeColor: const Color(0xFF4D8EFF),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? const Color(0xFF1A3C7A) : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _formatDate(String dateTime) {
    // Expected format: "2026-05-18 08:00:00" → "18-05-2026"
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day.toString().padLeft(2, '0')}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.year}';
    } catch (_) {
      return dateTime;
    }
  }

  String _formatTime(String dateTime) {
    // Expected format: "2026-05-18 08:00:00 - 2026-05-18 17:00:00"
    // or just a single datetime; adapt as needed
    try {
      final parts = dateTime.split(' - ');
      String start = _timeOnly(parts[0]);
      String end   = parts.length > 1 ? _timeOnly(parts[1]) : '';
      return end.isEmpty ? start : '$start - $end';
    } catch (_) {
      return dateTime;
    }
  }

  String _timeOnly(String s) {
    final dt = DateTime.parse(s.trim());
    final h  = dt.hour   % 12 == 0 ? 12 : dt.hour   % 12;
    final m  = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m$amPm';
  }
}

// ── Helper data class ─────────────────────────────────────────────────────────
class _GradeOption {
  final String label;
  final int min;
  const _GradeOption({required this.label, required this.min});
}