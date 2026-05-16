import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'faculty_layout.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/header.dart';

class SubjectDetailsPage extends StatefulWidget {

  final Map subject;

  const SubjectDetailsPage({
    super.key,
    required this.subject,
  });

  @override
  State<SubjectDetailsPage> createState() =>
      _SubjectDetailsPageState();
}

class _SubjectDetailsPageState
    extends State<SubjectDetailsPage> {

  Map? subjectDetails;

  List sections = [];

  List labs = [];

  int? selectedSectionId;

  Future<void> fetchSubjectDetails() async {

    var response = await http.get(

      Uri.parse(
        "http://10.0.2.2:8000/api/subject-details/${widget.subject['subject_id']}",
      ),
    );

    if (response.statusCode == 200) {

      var data = jsonDecode(response.body);

      setState(() {

        subjectDetails = data['subject'];

        sections = data['sections'];

        if (sections.isNotEmpty) {

          selectedSectionId =
              sections[0]['section_id'];

          labs = sections[0]['labs'];
        }
      });
    }
  }

  @override
  void initState() {

    super.initState();

    fetchSubjectDetails();
  }

  @override
  Widget build(BuildContext context) {

    return FacultyLayout(

      body: subjectDetails == null

          ? const Center(
              child: CircularProgressIndicator(),
            )

          : SingleChildScrollView(

              child: Padding(

                padding: const EdgeInsets.all(20),

                child: Container(

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(

                    color: const Color(0xFFF3EDC8),

                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Column(

                    children: [

                      Text(

                        "${subjectDetails!['subject_code']} - ${subjectDetails!['subject_name']}",

                        textAlign: TextAlign.center,

                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(

                        "Credit Hours : ${subjectDetails!['credit_hours']}",

                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(

                        height: 45,

                        child: ListView.builder(

                          scrollDirection:
                              Axis.horizontal,

                          itemCount: sections.length,

                          itemBuilder: (context, index) {

                            var section =
                                sections[index];

                            return Padding(

                              padding:
                                  const EdgeInsets.only(
                                      right: 10),

                              child: ElevatedButton(

                                style:
                                    ElevatedButton.styleFrom(

                                  backgroundColor:
                                      selectedSectionId ==
                                              section[
                                                  'section_id']

                                          ? Colors.orange

                                          : Colors.white,

                                  foregroundColor:
                                      Colors.black,
                                ),

                                onPressed: () {

                                  setState(() {

                                    selectedSectionId =
                                        section[
                                            'section_id'];

                                    labs =
                                        section['labs'];
                                  });
                                },

                                child: Text(
                                  section['section_no'],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 25),

                      if (labs.isEmpty)

                        const Text(
                          "No lab available",
                        )

                      else

                        Column(

                          children:
                              labs.map((lab) {

                            int available =
                                lab['capacity'] -
                                    lab['enrolled'];

                            return Container(

                              width: double.infinity,

                              margin:
                                  const EdgeInsets.only(
                                      bottom: 20),

                              padding:
                                  const EdgeInsets.all(
                                      20),

                              decoration:
                                  BoxDecoration(

                                color: Colors.white,

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            20),

                                boxShadow: const [

                                  BoxShadow(
                                    blurRadius: 5,
                                    color:
                                        Colors.black12,
                                  )
                                ],
                              ),

                              child: Column(

                                children: [

                                  Text(

                                    lab['lab_name'],

                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      fontSize: 20,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 15),

                                  Align(

                                    alignment:
                                        Alignment
                                            .centerLeft,

                                    child: Text(
                                      "Capacity : ${lab['capacity']}",
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 5),

                                  Align(

                                    alignment:
                                        Alignment
                                            .centerLeft,

                                    child: Text(
                                      "Total Student : ${lab['enrolled']}",
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 5),

                                  Align(

                                    alignment:
                                        Alignment
                                            .centerLeft,

                                    child: Text(
                                      "Cap Available : $available",
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 20),

                      const Align(

                        alignment: Alignment.centerLeft,

                        child: Text(

                          "List Registered Student",

                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "No student registered yet",
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}