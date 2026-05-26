import 'package:flutter/material.dart';
import '../../domain/subject.dart';
import '../../provider/student_subject_provider.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/header.dart';

class StudentSubjectRegistrationPage extends StatefulWidget {
  const StudentSubjectRegistrationPage({super.key});

  @override
  State<StudentSubjectRegistrationPage> createState() =>
      _SubjectRegistrationPageState();
}

class _SubjectRegistrationPageState
    extends State<StudentSubjectRegistrationPage> {
  final StudentSubjectProvider provider = StudentSubjectProvider();

  late Future<List<SubjectModel>> subjectsFuture;

  List<SubjectModel> allSubjects = [];
  List<SubjectModel> filteredSubjects = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    subjectsFuture = provider.fetchSubjects();
  }

  void searchSubjects(String keyword) {
    setState(() {
      filteredSubjects = allSubjects.where((subject) {
        final subjectName = subject.subjectName.toLowerCase();
        final subjectCode = subject.subjectCode.toLowerCase();
        return subjectName.contains(keyword.toLowerCase()) ||
            subjectCode.contains(keyword.toLowerCase());
      }).toList();
    });
  }

  // ─── Reusable dialog builder ──────────────────────────────────────────────
  void _showStatusDialog({
    required BuildContext ctx,
    required IconData icon,
    required Color iconColor,
    required Color buttonColor,
    required String message,
  }) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 44),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: const Color(0xFFF0F7FF),
      body: Column(
        children: [
          const UsasHeader(),

          // ── Search bar ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: searchSubjects,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1A2E),
                ),
                decoration: InputDecoration(
                  hintText: "Search subject name or code…",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.blue.shade400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // ── Subject list ───────────────────────────────────────────────────
          Expanded(
            child: FutureBuilder<List<SubjectModel>>(
              future: subjectsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue.shade400,
                      strokeWidth: 3,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Subjects Available",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                allSubjects = snapshot.data!;

                if (filteredSubjects.isEmpty &&
                    searchController.text.isEmpty) {
                  filteredSubjects = allSubjects;
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: filteredSubjects.length,
                  itemBuilder: (context, index) {
                    final subject = filteredSubjects[index];

                    return _SubjectCard(
                      subject: subject,
                      onRegister: (section, lab) async {
                        try {
                          await provider.registerSubject(
                            studentId: 1,
                            subjectId: subject.subjectId,
                            sectionId: section.sectionId,
                            labId: lab.labId,
                          );

                          _showStatusDialog(
                            ctx: context,
                            icon: Icons.check_circle_rounded,
                            iconColor: const Color(0xFF22C55E),
                            buttonColor: const Color(0xFF22C55E),
                            message: "Subject added successfully!",
                          );

                          setState(() {
                            subjectsFuture = provider.fetchSubjects();
                          });
                        } catch (e) {
                          final errorMessage = e.toString();

                          if (errorMessage.contains("Schedule conflict")) {
                            _showStatusDialog(
                              ctx: context,
                              icon: Icons.event_busy_rounded,
                              iconColor: const Color(0xFFEF4444),
                              buttonColor: const Color(0xFFEF4444),
                              message:
                                  "Selected subject has a schedule conflict with your existing timetable.",
                            );
                          } else if (errorMessage
                              .contains("already registered")) {
                            _showStatusDialog(
                              ctx: context,
                              icon: Icons.warning_rounded,
                              iconColor: const Color(0xFFF97316),
                              buttonColor: const Color(0xFFF97316),
                              message:
                                  "You have already registered this subject.",
                            );
                          } else {
                            _showStatusDialog(
                              ctx: context,
                              icon: Icons.block_rounded,
                              iconColor: const Color(0xFFEF4444),
                              buttonColor: const Color(0xFFEF4444),
                              message:
                                  "You have reached the maximum subject registration limit.",
                            );
                          }
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Subject Card ─────────────────────────────────────────────────────────────

class _SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final Future<void> Function(dynamic section, dynamic lab) onRegister;

  const _SubjectCard({
    required this.subject,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade50,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${subject.subjectCode} · ${subject.subjectName}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${subject.creditHours} Credit",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sections
          if (subject.sections.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  "No Section Available",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: subject.sections.map((section) {
                  if (section.labs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        "No Lab Available",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return Column(
                    children: section.labs.map((lab) {
                      final spotsLeft = lab.capacity - lab.enrolled;
                      final isFull = spotsLeft <= 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FBFF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFDDEAFF),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Section & schedule info
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Section name badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE3EEFF),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      lab.labName ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1565C0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        lab.scheduleDay ?? '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        lab.scheduleTime ?? '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Spots left badge
                            Container(
                              width: 68,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isFull
                                    ? const Color(0xFFFFEDED)
                                    : const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "$spotsLeft",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isFull
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF16A34A),
                                    ),
                                  ),
                                  Text(
                                    "Left",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isFull
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF16A34A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Add button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFull
                                    ? Colors.grey.shade300
                                    : const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isFull
                                  ? null
                                  : () => onRegister(section, lab),
                              child: const Text(
                                "+ Add",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}