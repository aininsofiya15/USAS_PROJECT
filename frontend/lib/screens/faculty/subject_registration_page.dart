import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'faculty_layout.dart';
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

class _SubjectRegistrationPageState
    extends State<SubjectRegistrationPage> {

  TextEditingController searchController =
      TextEditingController();

  List subjects = [];

  List filteredSubjects = [];

  Future<void> fetchSubjects() async {

    var url = Uri.parse(
      "http://10.0.2.2:8000/api/subjects",
    );

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

    return FacultyLayout(

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Container(

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(

            color: const Color(0xFFF3EDC8),

            borderRadius: BorderRadius.circular(20),

          ),

          child: Column(

            children: [

              TextField(

                controller: searchController,

                onChanged: (value) {

                  setState(() {

                    filteredSubjects =
                        subjects.where((subject) {

                      return subject['subject_code']
                          .toString()
                          .toLowerCase()
                          .contains(
                            value.toLowerCase(),
                          ) ||

                          subject['subject_name']
                              .toString()
                              .toLowerCase()
                              .contains(
                                value.toLowerCase(),
                              );

                    }).toList();
                  });
                },

                decoration: InputDecoration(

                  hintText: "Search Subject",

                  prefixIcon:
                      const Icon(Icons.search),

                  filled: true,

                  fillColor: Colors.white,

                  border: OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(30),

                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Align(

                alignment: Alignment.centerLeft,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    backgroundColor:
                        const Color(0xFFD8C7A3),

                    foregroundColor: Colors.black,

                    shape: RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ),

                  onPressed: () async {

                    await Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            const SubjectFormPage(),
                      ),
                    );

                    fetchSubjects();
                  },

                  child:
                      const Text("+ Add Subject"),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(

                child: ListView.builder(

                  itemCount:
                      filteredSubjects.length,

                  itemBuilder: (context, index) {

                    var subject =
                        filteredSubjects[index];

                    return GestureDetector(

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                                SubjectDetailsPage(

                              subject: subject,
                            ),
                          ),
                        );
                      },

                      child: Container(

                        margin:
                            const EdgeInsets.only(
                                bottom: 15),

                        padding:
                            const EdgeInsets.all(
                                20),

                        decoration: BoxDecoration(

                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                                  20),

                          boxShadow: const [

                            BoxShadow(
                              blurRadius: 5,
                              color: Colors.black12,
                            )
                          ],
                        ),

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(

                              "${subject['subject_code']} - ${subject['subject_name']}",

                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(
                                height: 10),

                            Text(
                              "Credit Hours : ${subject['credit_hours']}",
                            ),

                            const SizedBox(
                                height: 5),

                            Text(
                              "Total Section : ${subject['total_section']}",
                            ),

                            const SizedBox(
                                height: 5),

                            Text(
                              "Total Lab : ${subject['total_lab']}",
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
        ),
      ),
    );
  }
}