import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/module_provider.dart';
import '../../domain/module.dart';
import '../../widgets/header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/navigation_bar.dart';

class StudentListPage extends StatefulWidget {
  final Module module;
  const StudentListPage({super.key, required this.module});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<ModuleProvider>(context, listen: false)
          .fetchRegisteredStudents(widget.module.id!),
    );
  }

  String _formatDateTime(String dateTime, String? description) {
    String _toAmPm(String time) {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return '$hour:$minute $period';
    }

    final endTimeMatch =
        RegExp(r'\[end_time:(\d{2}:\d{2})\]').firstMatch(description ?? '');
    if (endTimeMatch != null && dateTime.length >= 16) {
      final datePart = dateTime.substring(0, 10);
      final startTime = _toAmPm(dateTime.substring(11, 16));
      final endTime = _toAmPm(endTimeMatch.group(1)!);
      return "$datePart  $startTime - $endTime";
    }
    return dateTime;
  }

  @override
  Widget build(BuildContext context) {
    final moduleProvider = Provider.of<ModuleProvider>(context);

    final bool isCurrentModule =
        moduleProvider.registeredStudentsModuleId == widget.module.id;
    final dynamic rawData =
        isCurrentModule ? moduleProvider.registeredStudents : [];
    final List<dynamic> studentList = (rawData is List) ? rawData : [];

    final List<dynamic> filteredList = searchQuery.isEmpty
        ? studentList
        : studentList.where((s) {
            final String matricId =
                (s['matric_id'] ?? "").toString().toLowerCase();
            final String name =
                (s['student_name'] ?? "").toString().toLowerCase();
            final query = searchQuery.toLowerCase();
            return matricId.contains(query) || name.contains(query);
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFD1FFF3),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
          decoration: BoxDecoration(
            color: const Color(0xFFB9F6F0),
            borderRadius: BorderRadius.circular(34),
          ),
          child: Column(
            children: [
              _buildModuleInfoCard(studentList.length),
              const SizedBox(height: 28),
              Expanded(
                child: _buildStudentPanel(moduleProvider, filteredList),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleInfoCard(int studentCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.module.activityName.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          _infoText(
              "Current Registration: $studentCount / ${widget.module.capacity} Students"),
          _infoText(
              "Class Date: ${_formatDateTime(widget.module.dateTime, widget.module.description)}"),
          _infoText("Venue: ${widget.module.venue}"),
          _infoText("Lecturer Name: ${widget.module.lecturerName}"),
        ],
      ),
    );
  }

  Widget _buildStudentPanel(
    ModuleProvider moduleProvider,
    List<dynamic> filteredList,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: SizedBox(
              height: 32,
              child: TextField(
                onChanged: (val) => setState(() => searchQuery = val),
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: "Matric ID",
                  hintStyle: const TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                  ),
                  suffixIcon: const Icon(
                    Icons.search,
                    color: Colors.black54,
                    size: 18,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Colors.black54,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Colors.black87,
                      width: 1.6,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Header row — aligned to match student rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                SizedBox(width: 46), // avatar width (34) + gap (12)
                Expanded(
                  child: Text(
                    "Student Name",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    "Matric ID",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(width: 32), // delete button space
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: moduleProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_off_outlined,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "No students found",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 18),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final student = filteredList[index];
                          return _buildStudentRow(student);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentRow(dynamic student) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.black54, width: 1.5),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 22,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          // Name — left-aligned, same baseline as avatar center
          Expanded(
            child: Text(
              student['student_name'] ?? "Unknown",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Matric ID
          SizedBox(
            width: 80,
            child: Text(
              student['matric_id'] ?? "-",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Delete button
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Color(0xFFFF6B81),
                size: 19,
              ),
              padding: EdgeInsets.zero,
              onPressed: () => _confirmDelete(student),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          height: 1.15,
        ),
      ),
    );
  }

  void _confirmDelete(dynamic student) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                "Are you sure to remove this student?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Back",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Confirm",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true && context.mounted) {
      await Provider.of<ModuleProvider>(context, listen: false)
          .removeStudentFromModule(
        bookingId: student['booking_id'],
        moduleId: widget.module.id!,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Student removed successfully")),
        );
      }
    }
  }
}