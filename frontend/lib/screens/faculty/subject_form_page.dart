import '../../provider/registrar_subject_provider.dart';
import 'package:flutter/material.dart';
import 'faculty_layout.dart';


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

  @override
  Widget build(BuildContext context) {
    return FacultyLayout(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(blurRadius: 8, color: Colors.black12),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "Subject Registration Form",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 25),

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Subject Name",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: "Subject Code",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: creditController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Credit Hours",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: sectionController,
                  keyboardType: TextInputType.number,
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
                  decoration: const InputDecoration(
                    labelText: "Total Section",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 25),

                ...sections.map((section) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F0D8),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section['section_name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 15),

                        DropdownButtonFormField(
                          items: lecturers.map((lecturer) {
                            return DropdownMenuItem(
                              value: lecturer['id'],
                              child: Text(lecturer['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            section['lecturer_id'] = value;
                          },
                          decoration: const InputDecoration(
                            labelText: "Select Lecturer",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 15),

                        TextField(
                          controller: section['lab_controller'],
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            int totalLabs = int.tryParse(value) ?? 0;
                            section['labs'] = List.generate(totalLabs, (labIndex) {
                              return {
                                "lab_name":
                                    "${section['section_name']}${String.fromCharCode(65 + labIndex)}",
                                "capacity_controller": TextEditingController(),
                                "selected_day": null,
                                "start_time": null,
                                "end_time": null,
                              };
                            });
                            setState(() {});
                          },
                          decoration: const InputDecoration(
                            labelText: "Total Labs",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        ...section['labs'].map<Widget>((lab) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lab['lab_name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(height: 15),

                                TextField(
                                  controller: lab['capacity_controller'],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Lab Capacity",
                                    border: OutlineInputBorder(),
                                  ),
                                ),

                                const SizedBox(height: 15),

                                /// DAY DROPDOWN
                                DropdownButtonFormField<String>(
                                  value: lab['selected_day'],
                                  decoration: const InputDecoration(
                                    labelText: "Schedule Day",
                                    border: OutlineInputBorder(),
                                  ),
                                  items: [
                                    "Monday",
                                    "Tuesday",
                                    "Wednesday",
                                    "Thursday",
                                    "Friday",
                                  ].map((day) {
                                    return DropdownMenuItem(
                                      value: day,
                                      child: Text(day),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      lab['selected_day'] = value;
                                    });
                                  },
                                ),

                                const SizedBox(height: 15),

                                /// TIME PICKERS
                                Row(
                                  children: [
                                    /// START TIME
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          final picked = await showTimePicker(
                                            context: context,
                                            initialTime: lab['start_time'] ??
                                                TimeOfDay.now(),
                                          );
                                          if (picked != null) {
                                            setState(() {
                                              lab['start_time'] = picked;
                                            });
                                          }
                                        },
                                        child: InputDecorator(
                                          decoration: const InputDecoration(
                                            labelText: "Start Time",
                                            border: OutlineInputBorder(),
                                            suffixIcon: Icon(Icons.access_time),
                                          ),
                                          child: Text(
                                            lab['start_time'] == null
                                                ? "Select"
                                                : _formatTime(
                                                    lab['start_time'], context),
                                            style: TextStyle(
                                              color: lab['start_time'] == null
                                                  ? Colors.grey
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    /// END TIME
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          final picked = await showTimePicker(
                                            context: context,
                                            initialTime: lab['end_time'] ??
                                                TimeOfDay.now(),
                                          );
                                          if (picked != null) {
                                            setState(() {
                                              lab['end_time'] = picked;
                                            });
                                          }
                                        },
                                        child: InputDecorator(
                                          decoration: const InputDecoration(
                                            labelText: "End Time",
                                            border: OutlineInputBorder(),
                                            suffixIcon: Icon(Icons.access_time),
                                          ),
                                          child: Text(
                                            lab['end_time'] == null
                                                ? "Select"
                                                : _formatTime(
                                                    lab['end_time'], context),
                                            style: TextStyle(
                                              color: lab['end_time'] == null
                                                  ? Colors.grey
                                                  : Colors.black,
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
                        }).toList(),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();

                      List formattedSections = [];

                      for (var section in sections) {
                        List formattedLabs = [];

                        for (var lab in section['labs']) {
                          // ✅ declared only once here
                          final startTime = lab['start_time'] as TimeOfDay?;
                          final endTime = lab['end_time'] as TimeOfDay?;
                          final scheduleTime = (startTime != null && endTime != null)
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

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Subject Registered Successfully"),
                        ),
                      );
                    },
                    child: const Text("Register Subject"),
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