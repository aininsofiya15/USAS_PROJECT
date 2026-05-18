import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'subject_form_page.dart';
import 'subject_details_page.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/header.dart';

class SubjectRegistrationPage extends StatefulWidget {
  const SubjectRegistrationPage({super.key});

  @override
  State<SubjectRegistrationPage> createState() =>
      _SubjectRegistrationPageState();
}

class _SubjectRegistrationPageState extends State<SubjectRegistrationPage> {
  TextEditingController searchController = TextEditingController();

  List subjects = [];
  List filteredSubjects = [];

  // ── Admin theme colours (amber/orange) ────────────────────────────────────
  static const Color kPrimary     = Color(0xFFD97706); // amber-600
  static const Color kPrimaryDark = Color(0xFFB45309); // amber-700
  static const Color kBg          = Color(0xFFFFFBF0); // warm off-white
  static const Color kCardBorder  = Color(0xFFFDE68A); // amber-200
  static const Color kAccentBg    = Color(0xFFFEF3C7); // amber-100

  Future<void> fetchSubjects() async {
    var url = Uri.parse("http://10.0.2.2:8000/api/subjects");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        subjects = jsonDecode(response.body);
        filteredSubjects = subjects;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      backgroundColor: kBg,
      body: Column(
        children: [
          // ── Header banner ───────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            color: kPrimary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Subject Management",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "${filteredSubjects.length} Subject${filteredSubjects.length == 1 ? '' : 's'}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Search bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.shade100,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    filteredSubjects = subjects.where((subject) {
                      return subject['subject_code']
                              .toString()
                              .toLowerCase()
                              .contains(value.toLowerCase()) ||
                          subject['subject_name']
                              .toString()
                              .toLowerCase()
                              .contains(value.toLowerCase());
                    }).toList();
                  });
                },
                style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
                decoration: InputDecoration(
                  hintText: "Search subject name or code…",
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: kPrimary),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // ── Add Subject button ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text(
                  "Add New Subject",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SubjectFormPage()),
                  );
                  fetchSubjects();
                },
              ),
            ),
          ),

          // ── Subject list ────────────────────────────────────────────────
          Expanded(
            child: filteredSubjects.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_rounded,
                            size: 56, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          "No subjects found",
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: filteredSubjects.length,
                    itemBuilder: (context, index) {
                      var subject = filteredSubjects[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SubjectDetailsPage(subject: subject),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: kCardBorder, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.shade50,
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Left amber accent bar
                              Container(
                                width: 5,
                                height: 90,
                                decoration: const BoxDecoration(
                                  color: kPrimary,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(18),
                                    bottomLeft: Radius.circular(18),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 14),

                              // Content
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subject['subject_code'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: kPrimary,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        subject['subject_name'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Color(0xFF1A1A2E),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          _InfoChip(
                                            icon: Icons.star_rounded,
                                            label:
                                                "${subject['credit_hours']} Credit",
                                            color: kPrimaryDark,
                                            bgColor: kAccentBg,
                                          ),
                                          const SizedBox(width: 8),
                                          _InfoChip(
                                            icon: Icons.groups_rounded,
                                            label:
                                                "${subject['total_section']} Section",
                                            color: const Color(0xFFB45309),
                                            bgColor: const Color(0xFFFEF9C3),
                                          ),
                                          const SizedBox(width: 8),
                                          _InfoChip(
                                            icon: Icons.science_rounded,
                                            label:
                                                "${subject['total_lab']} Lab",
                                            color: const Color(0xFF92400E),
                                            bgColor: const Color(0xFFFFEDD5),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Chevron
                              Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.grey.shade300,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Info chip widget ─────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}