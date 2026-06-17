import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/attendance_provider.dart';
import '../../domain/module.dart';
import '../../widgets/header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/navigation_bar.dart';
import 'module_grading.dart';
import 'edit_student_module_attendance.dart';

class AttendanceRecordListPage extends StatefulWidget {
  final Module module;
  final int bookingId;

  const AttendanceRecordListPage({
    super.key,
    required this.bookingId,
    required this.module,
  });

  @override
  State<AttendanceRecordListPage> createState() =>
      _AttendanceRecordListPageState();
}

class _AttendanceRecordListPageState extends State<AttendanceRecordListPage> {
  bool showPresent = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<AttendanceProvider>()
          .fetchAttendanceDetails(widget.bookingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        final students = provider.presentModuleStudent;

        return Scaffold(
          backgroundColor: const Color(0xFFD1FFF3),
          appBar: const UsasHeader(),
          drawer: const AppSidebar(),
          bottomNavigationBar: const UsasBottomNav(),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              // ── 🎨 HIGH-CONTRAST DEEP TEAL OUTLINE BORDER ──
              decoration: BoxDecoration(
                color: const Color(0xFFB9F6F0),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(
                  color: const Color(0xFF5CB0A0), // Darkened border color for high visibility
                  width: 2.5,                     // Slightly thicker stroke
                ),
              ),
              child: Column(
                children: [
                  // ── Page Title ──
                  const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 8),
                    child: Text(
                      'Attendance Records',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // ── Module Info Card ──
                  _buildModuleCard(widget.module, provider),
                  const SizedBox(height: 12),

                  // ── Present / Not Present Toggle ──
                  _buildStatusToggle(),
                  const SizedBox(height: 12),

                  // ── Student List ──
                  Expanded(
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildStudentList(students, provider), 
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Module Info Card ──────────────────────────────────────────────────────
  Widget _buildModuleCard(Module module, AttendanceProvider provider) {
    final presentCount = provider.presentModuleStudent.length;
    final totalCapacity =
        provider.currentModuleDetails?['capacity'] ?? module.capacity ?? 0;
    final venueText =
        provider.currentModuleDetails?['venue'] ?? module.venue ?? 'N/A';
    final lecturerText =
        provider.currentModuleDetails?['lecturer_name'] ??
            module.lecturerName ??
            'N/A';
    final dateText =
        provider.currentModuleDetails?['date_time'] ?? module.dateTime ?? 'N/A';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            module.activityName.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          _infoRow('Number of Student: $presentCount / $totalCapacity Students'),
          _infoRow('Class Date: $dateText'),
          _infoRow('Venue: $venueText'),
          _infoRow('Lecturer Name: $lecturerText'),
        ],
      ),
    );
  }

  Widget _infoRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ── Present / Not Present Toggle ──────────────────────────────────────────
  Widget _buildStatusToggle() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          _toggleItem(
            'Present',
            showPresent,
            () => setState(() => showPresent = true),
          ),
          _toggleItem(
            'Not Present',
            !showPresent,
            () => setState(() => showPresent = false),
          ),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFFD1E3FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color:
                    isSelected ? const Color(0xFF1A3C7A) : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Student List ──────────────────────────────────────────────────────────
  Widget _buildStudentList(List<dynamic> students, AttendanceProvider provider) {
    final filtered = students.where((s) {
      final statusStr =
          s['attendance_status']?.toString().toLowerCase() ?? 'present';
      final statusMatch = showPresent
          ? statusStr == 'present'
          : statusStr != 'present';

      final query = _searchController.text.toLowerCase();
      final nameStr = s['student_name']?.toString().toLowerCase() ?? '';
      final matricStr = s['matrix_no']?.toString().toLowerCase() ?? '';

      final searchMatch = query.isEmpty ||
          nameStr.contains(query) ||
          matricStr.contains(query);

      return statusMatch && searchMatch;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF9ADAD4),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon:
                      Icon(Icons.search, color: Colors.grey, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),

          // Table Header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: const [
                SizedBox(
                  width: 32,
                  child: Text(
                    'No',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 85,
                  child: Text(
                    'Student ID',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),

          // Student Rows
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_outlined,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        Text(
                          'No student records matched your selection.',
                          style: TextStyle(
                            color: Colors.grey[500], fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      final student = filtered[index];
                      return _buildStudentRow(index + 1, student, provider); 
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentRow(int no, dynamic student, AttendanceProvider provider) {
    final String matrixNo = student['matrix_no'] ?? 'N/A';
    final String studentName = student['student_name'] ?? 'Unknown';
    final String status =
        student['attendance_status']?.toString().toLowerCase().trim() ?? '';
    final bool isNotPresent = status != 'present';

    final bool isGraded = student['marks'] != null;
    final Color rowTextColor = isNotPresent
        ? Colors.red
        : isGraded
            ? const Color(0xFF1D9E75)
            : Colors.black87;
    final FontWeight rowFontWeight =
        (isNotPresent || isGraded) ? FontWeight.w600 : FontWeight.normal;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$no',
              style: TextStyle(
                fontSize: 13,
                color: rowTextColor,
                fontWeight: rowFontWeight,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 85,
            child: Text(
              matrixNo,
              style: TextStyle(
                fontWeight: rowFontWeight,
                fontSize: 13,
                color: rowTextColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    studentName,
                    style: TextStyle(
                      fontSize: 13,
                      overflow: TextOverflow.ellipsis,
                      color: rowTextColor,
                      fontWeight: rowFontWeight,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _actionBtn(
                'Grade',
                const Color(0xFF00CC66),
                () async {
                  final refreshed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GradeStudentPage(
                        student: student,
                        module: widget.module,
                      ),
                    ),
                  );
                  if (refreshed == true && mounted) {
                    context
                        .read<AttendanceProvider>()
                        .fetchAttendanceDetails(widget.bookingId);
                  }
                },
              ),
              const SizedBox(width: 6),
              _actionBtn(
                'Edit',
                const Color(0xFF4D8EFF),
                () async {
                  final String fullDateTime = provider.currentModuleDetails?['date_time']?.toString() ?? widget.module.dateTime ?? '';

                  final bool? refreshed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditStudentModuleAttendance(
                        attendanceId: int.tryParse(widget.bookingId.toString()) ?? 1, 
                        recordId: student['id'] ?? 0,    
                        studentId: student['student_id'] ?? 1,   
                        matricNo: student['matrix_no'] ?? 'N/A', 
                        studentName: student['student_name'] ?? 'Unknown', 
                        moduleName: widget.module.activityName, 
                        date: fullDateTime.split(' ').first, 
                        time: fullDateTime.contains(' ') ? fullDateTime.substring(fullDateTime.indexOf(' ') + 1) : fullDateTime, 
                        currentStatus: student['attendance_status'] ?? 'Present', 
                      ),
                    ),
                  );

                  if (refreshed == true && mounted) {
                    context.read<AttendanceProvider>().fetchAttendanceDetails(int.tryParse(widget.bookingId.toString()) ?? 1); 
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 24,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}