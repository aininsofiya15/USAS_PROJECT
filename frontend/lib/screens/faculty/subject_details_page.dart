import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../widgets/app_sidebar.dart';
import '../../widgets/header.dart';
import 'subject_form_page.dart';
import '../../provider/registrar_subject_provider.dart';
import '../../widgets/navigation_bar.dart';


// Subject details page
class SubjectDetailsPage extends StatefulWidget {

// Selected subject from subject list
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

 // Store subject details from API
  Map? subjectDetails;

// Store all sections for the subject
  List sections = [];

 // Store labs for selected section
  List labs = [];

// Track selected section
  int? selectedSectionId;

// Retrieve subject details from backend
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

// Load subject details when page starts
    super.initState();

    fetchSubjectDetails();
  }

// Build Subject Details page UI
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: const UsasHeader(),

      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      backgroundColor:
          const Color(0xFFFDF9EC),

      body: subjectDetails == null

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : SingleChildScrollView(

              child: Padding(

                padding:
                    const EdgeInsets.all(20),

                child: Container(

                  padding:
                      const EdgeInsets.all(20),

                  decoration: BoxDecoration(

                    color:
                        const Color(0xFFF3EDC8),

                    borderRadius:
                        BorderRadius.circular(
                            20),
                  ),

                  child: Column(

                    children: [

                      Text(

                        "${subjectDetails!['subject_code']} - ${subjectDetails!['subject_name']}",

                        textAlign:
                            TextAlign.center,

                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                          height: 5),

                      Text(

                        "Credit Hours : ${subjectDetails!['credit_hours']}",

                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                          height: 20),

                          Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    ElevatedButton.icon(
      icon: const Icon(Icons.edit),
      label: const Text("Edit"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      // Navigate to Edit Subject page
      onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SubjectFormPage(
        subject: subjectDetails,
      ),
    ),
  );
},
    ),

    const SizedBox(width: 10),

    ElevatedButton.icon(
      icon: const Icon(Icons.delete),
      label: const Text("Deactive"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),

      // Deactivate selected subject
      onPressed: () async {

  var response =
      await RegistrarSubjectProvider()
          .deleteSubject(
              widget.subject['subject_id']);

  print(response);

  Navigator.pop(context);
},
    ),
  ],
),

const SizedBox(height: 20),

                      SizedBox(

                        height: 45,

                        child:
                            ListView.builder(

                          scrollDirection:
                              Axis.horizontal,

                          itemCount:
                              sections.length,

                          itemBuilder:
                              (context, index) {

                            var section =
                                sections[index];

                            return Padding(

                              padding:
                                  const EdgeInsets.only(
                                      right: 10),

                              child:
                                  ElevatedButton(

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

                                  shape:
                                      RoundedRectangleBorder(

                                    borderRadius:
                                        BorderRadius.circular(
                                            20),
                                  ),
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
                                  section[
                                      'section_no'],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                          height: 25),

                      if (labs.isEmpty)

                        const Text(
                          "No lab available",
                        )

                      else

                        Column(

                          children:
                              labs.map((lab) {

                            int available =
                                lab['available'] ??
                                    0;

                            return Container(

                              width:
                                  double.infinity,

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

                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Center(

                                    child: Text(

                                      lab['lab_name'],

                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 20),

                                  Text(
                                    "Capacity : ${lab['capacity']}",
                                  ),

                                  const SizedBox(
                                      height: 5),

                                  Text(
                                    "Total Student : ${lab['total_students']}",
                                  ),

                                  const SizedBox(
                                      height: 5),

                                  Text(
                                    "Cap Available : $available",
                                  ),

                                  const SizedBox(
                                      height: 25),

                                  const Text(

                                    "List Registered Student",

                                    style:
                                        TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 12),

                                  if (lab['registrations'] ==
                                          null ||
                                      (lab['registrations']
                                              as List)
                                          .isEmpty)

                                    const Text(
                                      "No student registered yet",
                                    )

                                  else

                                    Column(

                                      children:
                                          (lab['registrations'] ??
                                                  [])
                                              .map<Widget>(
                                                  (student) {

                                        return Container(

                                          width:
                                              double.infinity,

                                          margin:
                                              const EdgeInsets.only(
                                                  bottom:
                                                      12),

                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal:
                                                14,
                                            vertical:
                                                14,
                                          ),

                                          decoration:
                                              BoxDecoration(

                                            color: Colors
                                                .white,

                                            borderRadius:
                                                BorderRadius.circular(
                                                    16),

                                            border:
                                                Border.all(
                                              color: Colors
                                                  .black12,
                                            ),

                                            boxShadow:
                                                const [

                                              BoxShadow(
                                                blurRadius:
                                                    4,
                                                color: Colors
                                                    .black12,
                                                offset:
                                                    Offset(
                                                        0,
                                                        2),
                                              )
                                            ],
                                          ),

                                          child: Row(

                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,

                                            children: [

                                              Expanded(

                                                child:
                                                    Column(

                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,

                                                  children: [

                                                    Text(

                                                      student['name']
                                                              ?.toString() ??
                                                          "-",

                                                      style:
                                                          const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            16,
                                                      ),
                                                    ),

                                                    const SizedBox(
                                                        height:
                                                            4),

                                                    Text(

                                                      student['email']
                                                              ?.toString() ??
                                                          "-",

                                                      style:
                                                          const TextStyle(
                                                        color:
                                                            Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Container(

                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal:
                                                      10,
                                                  vertical:
                                                      4,
                                                ),

                                                decoration:
                                                    BoxDecoration(

                                                  color:
                                                      student['status']?.toString() ==
                                                              "active"

                                                          ? Colors.green

                                                          : Colors.orange,

                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20),
                                                ),

                                                child:
                                                    Text(

                                                  student['status']
                                                          ?.toString() ??
                                                      "active",

                                                  style:
                                                      const TextStyle(
                                                    color:
                                                        Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize:
                                                        12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );

                                      }).toList(),
                                    ),
                                ],
                              ),
                            );

                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}