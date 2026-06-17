import '../../provider/registrar_subject_provider.dart';
import 'package:flutter/material.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/header.dart';

class SubjectFormPage extends StatefulWidget {

  final Map? subject;

  const SubjectFormPage({
    super.key,
    this.subject,
  });

  @override
  State<SubjectFormPage> createState() => _SubjectFormPageState();
}

class _SubjectFormPageState extends State<SubjectFormPage> {
  // ── Admin theme colours ────────────────────────────────────────────────────
  static const Color kPrimary     = Color(0xFFD97706); // amber-600
  static const Color kPrimaryDark = Color(0xFFB45309); // amber-700
  static const Color kBg          = Color(0xFFFFFBF0); // warm off-white
  static const Color kCardBg      = Color(0xFFFEF9EE); // section card bg
  static const Color kBorder      = Color(0xFFFDE68A); // amber-200
  static const Color kLabel       = Color(0xFF92400E); // amber-900
  static const Color kHint        = Color(0xFFBFB49A);
  static const Color kText        = Color(0xFF1A1208);

  final TextEditingController nameController    = TextEditingController();
  final TextEditingController codeController    = TextEditingController();
  final TextEditingController creditController  = TextEditingController();
  final TextEditingController sectionController = TextEditingController();

  List lecturers = [];
  List<Map<String, dynamic>> sections = [];

  static const List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'
  ];

  @override
void initState() {
  super.initState();
  loadLecturers();

  if (widget.subject != null) {
    nameController.text = widget.subject!['subject_name'];
    codeController.text = widget.subject!['subject_code'];
    creditController.text =
        widget.subject!['credit_hours'].toString();
  }
}

  void loadLecturers() async {
    var data = await RegistrarSubjectProvider().getLecturers();
    setState(() => lecturers = data);
  }

  void _resetForm() {
    nameController.clear();
    codeController.clear();
    creditController.clear();
    sectionController.clear();
    setState(() => sections = []);
  }

  // ── Success dialog ─────────────────────────────────────────────────────────
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: kPrimary,
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Subject Registered!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kText,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "The subject has been registered successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: kLabel, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _resetForm();
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared input decoration ────────────────────────────────────────────────
  InputDecoration _inputDec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kHint, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
      );

  // ── Field label ────────────────────────────────────────────────────────────
  Widget _label(String text, {IconData? icon}) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: kLabel),
              const SizedBox(width: 5),
            ],
            Text(
              text.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: kLabel,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
      );

  // ── Text field ─────────────────────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    void Function(String)? onChanged,
    String hint = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, icon: icon),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, color: kText),
          decoration: _inputDec(hint),
        ),
      ],
    );
  }

  // ── Lecturer dropdown ──────────────────────────────────────────────────────
  Widget _buildLecturerDropdown(Map<String, dynamic> section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Lecturer', icon: Icons.person_outline),
        Theme(
          // Override dropdown menu theme so the popup is rounded + amber tinted
          data: Theme.of(context).copyWith(
            canvasColor: Colors.white,
            focusColor: kPrimary.withOpacity(0.08),
          ),
          child: DropdownButtonFormField<dynamic>(
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: kPrimary, size: 22),
            dropdownColor: Colors.white,
            menuMaxHeight: 240,
            value: section['lecturer_id'],
            items: lecturers.map((item) {
              final isSelected = section['lecturer_id'] == item['id'];
              return DropdownMenuItem<dynamic>(
                value: item['id'],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? kPrimary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? kPrimary
                              : kPrimary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: 16,
                          color: isSelected ? Colors.white : kPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        item['name'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected ? kPrimary : kText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) =>
                setState(() => section['lecturer_id'] = value),
            decoration: InputDecoration(
              hintText: 'Select lecturer',
              hintStyle: const TextStyle(color: kHint, fontSize: 14),
              prefixIcon: const Icon(Icons.person_outline,
                  color: kPrimary, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kBorder, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: kPrimary, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Modern day pill selector ───────────────────────────────────────────────
  Widget _buildDayPills(Map<String, dynamic> lab) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Schedule Day', icon: Icons.calendar_today_outlined),
        Wrap(
          spacing: 8,
          children: _days.map((day) {
            final selected = lab['selected_day'] == day;
            return GestureDetector(
              onTap: () => setState(() => lab['selected_day'] = day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected ? kPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: selected ? kPrimary : kBorder,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  day.substring(0, 3), // Mon, Tue …
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : kLabel,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Modern time picker button ──────────────────────────────────────────────
  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? time,
    required Future<void> Function() onTap,
  }) {
    final hasTime = time != null;
    final display = hasTime
        ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
        : 'Pick time';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, icon: Icons.access_time_rounded),
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: hasTime ? kPrimary.withOpacity(0.08) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasTime ? kPrimary : kBorder,
                width: hasTime ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: hasTime ? kPrimary : kHint,
                ),
                const SizedBox(width: 8),
                Text(
                  display,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        hasTime ? FontWeight.w600 : FontWeight.normal,
                    color: hasTime ? kPrimary : kHint,
                  ),
                ),
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
      backgroundColor: kBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Page header banner ───────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_book_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Subject Registration",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Fill in subject details below",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Main form card ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.shade50,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject Name
                  _buildField(
                    label: 'Subject Name',
                    controller: nameController,
                    icon: Icons.book_outlined,
                    hint: 'e.g. Data Structures & Algorithms',
                  ),
                  const SizedBox(height: 14),

                  // Subject Code
                  _buildField(
                    label: 'Subject Code',
                    controller: codeController,
                    icon: Icons.tag,
                    hint: 'e.g. CSC2103',
                  ),
                  const SizedBox(height: 14),

                  // Credit Hours + Total Sections
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          label: 'Credit Hours',
                          controller: creditController,
                          keyboardType: TextInputType.number,
                          icon: Icons.star_outline,
                          hint: '3',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                          label: 'Total Sections',
                          controller: sectionController,
                          keyboardType: TextInputType.number,
                          icon: Icons.view_list_outlined,
                          hint: '2',
                          onChanged: (value) {
                            int total = int.tryParse(value) ?? 0;
                            sections = List.generate(total, (index) {
                              return {
                                "section_name": "Section ${index + 1}",
                                "lecturer_id": null,
                                "lab_controller": TextEditingController(),
                                "labs": [],
                              };
                            });
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Section cards ────────────────────────────────────────────
            if (sections.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'SECTIONS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: kLabel,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            ...sections.asMap().entries.map((entry) {
              final sectionIndex = entry.key;
              final section = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: kBorder, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.shade50,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.08),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: kPrimary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${sectionIndex + 1}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            section['section_name'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Lecturer
                          _buildLecturerDropdown(section),
                          const SizedBox(height: 14),

                          // Total Labs
                          _buildField(
                            label: 'Total Labs',
                            controller: section['lab_controller'],
                            keyboardType: TextInputType.number,
                            icon: Icons.science_outlined,
                            hint: '2',
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

                          // Lab cards
                          if (section['labs'].isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: kPrimary.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 7),
                                const Text(
                                  'LABS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: kLabel,
                                    letterSpacing: 0.7,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],

                          ...section['labs'].map<Widget>((lab) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: kCardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: kBorder,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  // Lab name badge
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: kPrimary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      Text(
                                        lab['lab_name'],
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: kPrimary,
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
                                    icon: Icons.people_outline,
                                    hint: '30',
                                  ),

                                  const SizedBox(height: 14),

                                  // Day pills
                                  _buildDayPills(lab),

                                  const SizedBox(height: 14),

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
                                              builder: (ctx, child) =>
                                                  Theme(
                                                data: Theme.of(ctx)
                                                    .copyWith(
                                                  colorScheme:
                                                      const ColorScheme
                                                          .light(
                                                    primary: kPrimary,
                                                    onPrimary:
                                                        Colors.white,
                                                  ),
                                                ),
                                                child: child!,
                                              ),
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
                                              builder: (ctx, child) =>
                                                  Theme(
                                                data: Theme.of(ctx)
                                                    .copyWith(
                                                  colorScheme:
                                                      const ColorScheme
                                                          .light(
                                                    primary: kPrimary,
                                                    onPrimary:
                                                        Colors.white,
                                                  ),
                                                ),
                                                child: child!,
                                              ),
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
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 8),

            // ── Submit button ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline_rounded,
                    size: 20),
                label: const Text(
                  "Register Subject",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  print("BUTTON PRESSED");
                if (widget.subject != null) {

  var response =
      await RegistrarSubjectProvider().updateSubject(
    subjectId: widget.subject!['subject_id'],
    subjectName: nameController.text,
    subjectCode: codeController.text,
    creditHours: creditController.text,
  );

  if (response["success"] == true) {

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Subject Updated"),
      ),
    );
  }

  return;
}
                  FocusScope.of(context).unfocus();

                  List formattedSections = [];

                  for (var section in sections) {
                    List formattedLabs = [];

                    for (var lab in section['labs']) {
                      final startTime = lab['start_time'] as TimeOfDay?;
                      final endTime = lab['end_time'] as TimeOfDay?;
                      final scheduleTime =
                          (startTime != null && endTime != null)
                              ? "${startTime.format(context)} - ${endTime.format(context)}"
                              : "";

                      formattedLabs.add({
                        "lab_name": lab['lab_name'],
                        "capacity": lab['capacity_controller'].text,
                        "schedule_day": lab['selected_day'] ?? "",
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

if (response["success"] == true) {
  _showSuccessDialog();
} else {

  print("FULL RESPONSE = $response");

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Error"),
        content: Text(response.toString()),
      );
    },
  );
}
                 
                  
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}