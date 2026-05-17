import '../../provider/registrar_subject_provider.dart';
import 'package:flutter/material.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/header.dart';

class SubjectFormPage extends StatefulWidget {
  const SubjectFormPage({super.key});

  @override
  State<SubjectFormPage> createState() => _SubjectFormPageState();
}

class _SubjectFormPageState extends State<SubjectFormPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController creditController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();

  List lecturers = [];
  List<Map<String, dynamic>> sections = [];

  @override
  void initState() {
    super.initState();
    loadLecturers();
  }

  void loadLecturers() async {
    var data = await RegistrarSubjectProvider().getLecturers();
    setState(() {
      lecturers = data;
    });
  }

  String _formatTime(TimeOfDay time, BuildContext context) {
    return time.format(context);
  }

  // ─── Reset all form fields ─────────────────────────────────────────────────
  void _resetForm() {
    nameController.clear();
    codeController.clear();
    creditController.clear();
    sectionController.clear();
    setState(() {
      sections = [];
    });
  }

  // ─── Success popup ─────────────────────────────────────────────────────────
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF3DE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF3B6D11),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Subject Registration\nSuccess!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D3B6E),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "The subject has been registered\nsuccessfully.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8A7A55),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D3B6E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _resetForm();
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
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

  // ─── Reusable styled text field ───────────────────────────────────────────
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: const Color(0xFF8A7A55)),
              const SizedBox(width: 5),
            ],
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8A7A55),
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, color: Color(0xFF2A2010)),
          decoration: InputDecoration(
            hintText: _hintFor(label),
            hintStyle:
                const TextStyle(color: Color(0xFFBFB49A), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFFDFAF2),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFD9CFB0), width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF0D3B6E), width: 1),
            ),
          ),
        ),
      ],
    );
  }

  String _hintFor(String label) {
    switch (label.toLowerCase()) {
      case 'subject name':
        return 'e.g. Data Structures & Algorithms';
      case 'subject code':
        return 'e.g. CSC2103';
      case 'credit hours':
        return '3';
      case 'total sections':
        return '2';
      case 'total labs':
        return '2';
      case 'lab capacity':
        return '30';
      default:
        return '';
    }
  }

  // ─── Reusable dropdown field ───────────────────────────────────────────────
  Widget _buildDropdown({
    required String label,
    required List items,
    required void Function(dynamic) onChanged,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: const Color(0xFF8A7A55)),
              const SizedBox(width: 5),
            ],
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8A7A55),
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField(
          items: items.map((item) {
            return DropdownMenuItem(
              value: item['id'],
              child: Text(
                item['name'],
                style:
                    const TextStyle(fontSize: 14, color: Color(0xFF2A2010)),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Select lecturer',
            hintStyle:
                const TextStyle(color: Color(0xFFBFB49A), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFFDFAF2),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFD9CFB0), width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF0D3B6E), width: 1),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Day dropdown ──────────────────────────────────────────────────────────
  Widget _buildDayDropdown(Map<String, dynamic> lab) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.calendar_today_outlined,
                size: 14, color: Color(0xFF8A7A55)),
            SizedBox(width: 5),
            Text(
              'SCHEDULE DAY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8A7A55),
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: lab['selected_day'],
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFDFAF2),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFD9CFB0), width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF0D3B6E), width: 1),
            ),
          ),
          hint: const Text(
            'Select day',
            style: TextStyle(color: Color(0xFFBFB49A), fontSize: 14),
          ),
          items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
              .map((day) => DropdownMenuItem(
                    value: day,
                    child: Text(
                      day,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF2A2010)),
                    ),
                  ))
              .toList(),
          onChanged: (value) =>
              setState(() => lab['selected_day'] = value),
        ),
      ],
    );
  }

  // ─── Time picker tile ──────────────────────────────────────────────────────
  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? time,
    required Future<void> Function() onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time,
                size: 14, color: Color(0xFF8A7A55)),
            const SizedBox(width: 5),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8A7A55),
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFAF2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFFD9CFB0), width: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time == null
                      ? 'Select'
                      : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 14,
                    color: time == null
                        ? const Color(0xFFBFB49A)
                        : const Color(0xFF2A2010),
                  ),
                ),
                const Icon(Icons.access_time,
                    size: 16, color: Color(0xFF8A7A55)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      backgroundColor: const Color(0xFFFDF9EC),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: const Color(0xFFE8E0C4), width: 0.5),
              boxShadow: const [
                BoxShadow(blurRadius: 8, color: Colors.black12),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title ────────────────────────────────────────────────
                const Center(
                  child: Text(
                    "Subject Registration Form",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D3B6E),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Subject Name ─────────────────────────────────────────
                _buildField(
                  label: 'Subject Name',
                  controller: nameController,
                  icon: Icons.book_outlined,
                ),

                const SizedBox(height: 14),

                // ── Subject Code ─────────────────────────────────────────
                _buildField(
                  label: 'Subject Code',
                  controller: codeController,
                  icon: Icons.tag,
                ),

                const SizedBox(height: 14),

                // ── Credit Hours + Total Sections (side by side) ──────────
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        label: 'Credit Hours',
                        controller: creditController,
                        keyboardType: TextInputType.number,
                        icon: Icons.star_outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        label: 'Total Sections',
                        controller: sectionController,
                        keyboardType: TextInputType.number,
                        icon: Icons.view_list_outlined,
                        onChanged: (value) {
                          int total = int.tryParse(value) ?? 0;
                          sections = List.generate(total, (index) {
                            return {
                              "section_name": "Section ${index + 1}",
                              "lecturer_id": null,
                              "lab_controller":
                                  TextEditingController(),
                              "labs": [],
                            };
                          });
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),

                if (sections.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(height: 0.5, color: const Color(0xFFE8E0C4)),
                  const SizedBox(height: 16),
                  const Text(
                    'SECTIONS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8A7A55),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Section Cards ─────────────────────────────────────────
                ...sections.asMap().entries.map((entry) {
                  final sectionIndex = entry.key;
                  final section = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF9EC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color(0xFFD9CFB0), width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section header with numbered badge
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D3B6E),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${sectionIndex + 1}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              section['section_name'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A2E3B),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Lecturer dropdown
                        _buildDropdown(
                          label: 'Lecturer',
                          items: lecturers,
                          icon: Icons.person_outline,
                          onChanged: (value) =>
                              section['lecturer_id'] = value,
                        ),

                        const SizedBox(height: 14),

                        // Total labs field
                        _buildField(
                          label: 'Total Labs',
                          controller: section['lab_controller'],
                          keyboardType: TextInputType.number,
                          icon: Icons.science_outlined,
                          onChanged: (value) {
                            int totalLabs = int.tryParse(value) ?? 0;
                            section['labs'] = List.generate(
                              totalLabs,
                              (labIndex) => {
                                "lab_name":
                                    "${section['section_name']} ${String.fromCharCode(65 + labIndex)}",
                                "capacity_controller":
                                    TextEditingController(),
                                "selected_day": null,
                                "start_time": null,
                                "end_time": null,
                              },
                            );
                            setState(() {});
                          },
                        ),

                        if (section['labs'].isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Text(
                            'LABS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8A7A55),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        // ── Lab Cards ───────────────────────────────────
                        ...section['labs'].map<Widget>((lab) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFD9CFB0),
                                  width: 0.5),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // Lab name with blue dot
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF185FA5),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      lab['lab_name'],
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF185FA5),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Capacity
                                _buildField(
                                  label: 'Lab Capacity',
                                  controller:
                                      lab['capacity_controller'],
                                  keyboardType: TextInputType.number,
                                ),

                                const SizedBox(height: 12),

                                // Schedule day
                                _buildDayDropdown(lab),

                                const SizedBox(height: 12),

                                // Start & End time
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTimePicker(
                                        label: 'Start Time',
                                        time: lab['start_time'],
                                        onTap: () async {
                                          final picked =
                                              await showTimePicker(
                                            context: context,
                                            initialTime:
                                                lab['start_time'] ??
                                                    TimeOfDay.now(),
                                          );
                                          if (picked != null) {
                                            setState(() =>
                                                lab['start_time'] =
                                                    picked);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildTimePicker(
                                        label: 'End Time',
                                        time: lab['end_time'],
                                        onTap: () async {
                                          final picked =
                                              await showTimePicker(
                                            context: context,
                                            initialTime:
                                                lab['end_time'] ??
                                                    TimeOfDay.now(),
                                          );
                                          if (picked != null) {
                                            setState(() =>
                                                lab['end_time'] =
                                                    picked);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 8),

                // ── Submit Button ────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D3B6E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();

                      List formattedSections = [];

                      for (var section in sections) {
                        List formattedLabs = [];

                        for (var lab in section['labs']) {
                          final startTime =
                              lab['start_time'] as TimeOfDay?;
                          final endTime =
                              lab['end_time'] as TimeOfDay?;
                          final scheduleTime =
                              (startTime != null && endTime != null)
                                  ? "${startTime.format(context)} - ${endTime.format(context)}"
                                  : "";

                          formattedLabs.add({
                            "lab_name": lab['lab_name'],
                            "capacity":
                                lab['capacity_controller'].text,
                            "schedule_day":
                                lab['selected_day'] ?? "",
                            "schedule_time": scheduleTime,
                          });
                        }

                        formattedSections.add({
                          "section_name": section['section_name'],
                          "lecturer_id": section['lecturer_id'],
                          "labs": formattedLabs,
                        });
                      }

                      var response = await RegistrarSubjectProvider()
                          .registerSubject(
                        subjectName: nameController.text,
                        subjectCode: codeController.text,
                        creditHours: creditController.text,
                        totalSection: sectionController.text,
                        sections: formattedSections,
                      );

                      print(response);

                      _showSuccessDialog();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Register Subject",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}