import '../../provider/registrar_subject_provider.dart';

import 'package:flutter/material.dart';


import 'faculty_layout.dart';

class SubjectFormPage extends StatefulWidget {
  const SubjectFormPage({super.key});

  @override
  State<SubjectFormPage> createState() =>
      _SubjectFormPageState();
}

class _SubjectFormPageState
    extends State<SubjectFormPage> {

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController codeController =
      TextEditingController();

  final TextEditingController creditController =
      TextEditingController();

  final TextEditingController sectionController =
      TextEditingController();

  List<Map<String, dynamic>> sections = [];

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

              borderRadius:
                  BorderRadius.circular(20),

              boxShadow: const [

                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black12,
                )
              ],
            ),

            child: Column(

              children: [

                const Text(

                  "Subject Registration Form",

                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                TextField(

                  controller: nameController,

                  decoration:
                      const InputDecoration(
                    labelText: "Subject Name",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(

                  controller: codeController,

                  decoration:
                      const InputDecoration(
                    labelText: "Subject Code",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(

                  controller: creditController,

                  keyboardType:
                      TextInputType.number,

                  decoration:
                      const InputDecoration(
                    labelText: "Credit Hours",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(

                  controller: sectionController,

                  keyboardType:
                      TextInputType.number,

                  onChanged: (value) {

                    int total =
                        int.tryParse(value) ?? 0;

                    sections = List.generate(
                      total,
                      (index) {

                        return {

                          "section_name":
                              "Section ${index + 1}",

                          "lecturer": "",

                          "capacity_controller":
                              TextEditingController(),

                          "lab_controller":
                              TextEditingController(),

                          "labs": [],
                        };
                      },
                    );

                    setState(() {});
                  },

                  decoration:
                      const InputDecoration(
                    labelText: "Total Section",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 25),

                ...sections.map((section) {

                  return Container(

                    margin:
                        const EdgeInsets.only(
                            bottom: 20),

                    padding:
                        const EdgeInsets.all(15),

                    decoration: BoxDecoration(

                      color:
                          const Color(0xFFF6F0D8),

                      borderRadius:
                          BorderRadius.circular(
                              15),

                      border: Border.all(
                        color: Colors.black12,
                      ),
                    ),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        Text(

                          section['section_name'],

                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(
                            height: 15),

                        DropdownButtonFormField<
                            String>(

                          items: const [

                            DropdownMenuItem(
                              value:
                                  "Dr Kirahman",
                              child: Text(
                                  "Dr Kirahman"),
                            ),

                            DropdownMenuItem(
                              value: "Dr Amin",
                              child:
                                  Text("Dr Amin"),
                            ),

                            DropdownMenuItem(
                              value:
                                  "Dr Sarah",
                              child:
                                  Text("Dr Sarah"),
                            ),
                          ],

                          onChanged: (value) {

                            section['lecturer'] =
                                value;
                          },

                          decoration:
                              const InputDecoration(
                            labelText:
                                "Select Lecturer",
                            border:
                                OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(
                            height: 15),

                        TextField(

                          controller: section[
                              'capacity_controller'],

                          keyboardType:
                              TextInputType
                                  .number,

                          decoration:
                              const InputDecoration(
                            labelText:
                                "Section Capacity",
                            border:
                                OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(
                            height: 15),

                        TextField(

                          controller: section[
                              'lab_controller'],

                          keyboardType:
                              TextInputType
                                  .number,

                          onChanged: (value) {

                            int totalLabs =
                                int.tryParse(
                                        value) ??
                                    0;

                            section['labs'] =
                                List.generate(
                              totalLabs,
                              (labIndex) {

                                return {

                                  "lab_name":
                                      "${section['section_name']}${String.fromCharCode(65 + labIndex)}",

                                  "capacity_controller":
                                      TextEditingController(),

                                  "schedule_day_controller":
                                      TextEditingController(),

                                  "schedule_time_controller":
                                      TextEditingController(),
                                };
                              },
                            );

                            setState(() {});
                          },

                          decoration:
                              const InputDecoration(
                            labelText:
                                "Total Labs",
                            border:
                                OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(
                            height: 20),

                        ...section['labs']
                            .map<Widget>((lab) {

                          return Container(

                            margin:
                                const EdgeInsets
                                    .only(
                                    bottom: 15),

                            padding:
                                const EdgeInsets
                                    .all(15),

                            decoration:
                                BoxDecoration(

                              color: Colors.white,

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          15),

                              border: Border.all(
                                color:
                                    Colors.black12,
                              ),
                            ),

                            child: Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(

                                  lab['lab_name'],

                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(
                                    height: 15),

                                TextField(

                                  controller: lab[
                                      'capacity_controller'],

                                  keyboardType:
                                      TextInputType
                                          .number,

                                  decoration:
                                      const InputDecoration(
                                    labelText:
                                        "Lab Capacity",
                                    border:
                                        OutlineInputBorder(),
                                  ),
                                ),

                                const SizedBox(
                                    height: 15),

                                TextField(

                                  controller: lab[
                                      'schedule_day_controller'],

                                  decoration:
                                      const InputDecoration(
                                    labelText:
                                        "Schedule Day",
                                    border:
                                        OutlineInputBorder(),
                                  ),
                                ),

                                const SizedBox(
                                    height: 15),

                                TextField(

                                  controller: lab[
                                      'schedule_time_controller'],

                                  decoration:
                                      const InputDecoration(
                                    labelText:
                                        "Schedule Time",
                                    border:
                                        OutlineInputBorder(),
                                  ),
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

                      FocusScope.of(context)
                          .unfocus();

                    
                       
                       onPressed: () async {

  FocusScope.of(context)
      .unfocus();

  var response =
      await RegistrarSubjectProvider()
          .registerSubject(

    subjectName:
        nameController.text,

    subjectCode:
        codeController.text,

    creditHours:
        creditController.text,

    totalSection:
        sectionController.text,
  );

  print(response);

  ScaffoldMessenger.of(context)
      .showSnackBar(

    const SnackBar(

      content: Text(
        "Subject Registered Successfully",
      ),
    ),
  );
};
                      

                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(

                        const SnackBar(

                          content: Text(
                            "Subject Registered Successfully",
                          ),
                        ),
                      );
                    },

                    child: const Text(
                        "Register Subject"),
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