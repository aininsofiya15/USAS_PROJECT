import 'package:flutter/material.dart';

import '../../domain/subject.dart';
import '../../provider/student_subject_provider.dart';

/// IMPORT SAME SIDEBAR & HEADER
import '../../widgets/app_sidebar.dart';
import '../../widgets/header.dart';

class StudentSubjectRegistrationPage
    extends StatefulWidget {

  const StudentSubjectRegistrationPage({
    super.key,
  });

  @override
  State<StudentSubjectRegistrationPage>
      createState() =>
          _SubjectRegistrationPageState();
}

class _SubjectRegistrationPageState
    extends State<StudentSubjectRegistrationPage> {

  final StudentSubjectProvider provider =
      StudentSubjectProvider();

  late Future<List<SubjectModel>>
      subjectsFuture;

  @override
  void initState() {

    super.initState();

    subjectsFuture =
        provider.fetchSubjects();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      /// SAME SIDEBAR
      drawer: const AppSidebar(),

      backgroundColor:
          const Color(0xFFEAF6FB),

      body: Column(

        children: [

          /// SAME HEADER
          const UsasHeader(),

          /// PAGE CONTENT
          Expanded(

            child:
                FutureBuilder<List<SubjectModel>>(

              future: subjectsFuture,

              builder:
                  (context, snapshot) {

                /// LOADING
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {

                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                /// ERROR
                if (snapshot.hasError) {

                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                    ),
                  );
                }

                /// EMPTY
                if (!snapshot.hasData ||
                    snapshot.data!.isEmpty) {

                  return const Center(
                    child: Text(
                      "No Subjects Available",
                    ),
                  );
                }

                final subjects =
                    snapshot.data!;

                return ListView.builder(

                  padding:
                      const EdgeInsets.all(
                    16,
                  ),

                  itemCount:
                      subjects.length,

                  itemBuilder:
                      (context, index) {

                    final subject =
                        subjects[index];

                    return Container(

                      margin:
                          const EdgeInsets.only(
                        bottom: 20,
                      ),

                      padding:
                          const EdgeInsets.all(
                        16,
                      ),

                      decoration:
                          BoxDecoration(

                        color:
                            Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),

                        boxShadow: [

                          BoxShadow(

                            color: Colors
                                .grey
                                .shade300,

                            blurRadius: 6,

                            offset:
                                const Offset(
                              0,
                              3,
                            ),
                          ),
                        ],
                      ),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          /// SUBJECT TITLE
                          Row(

                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [

                              Expanded(

                                child: Text(

                                  "${subject.subjectCode} - ${subject.subjectName}",

                                  style:
                                      const TextStyle(

                                    fontSize:
                                        16,

                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),

                              Text(

                                "${subject.creditHours} Credit",

                                style:
                                    const TextStyle(

                                  color:
                                      Colors
                                          .blue,

                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          /// NO SECTION
                          if (subject
                              .sections
                              .isEmpty)

                            const Center(

                              child: Padding(

                                padding:
                                    EdgeInsets
                                        .all(
                                  12,
                                ),

                                child: Text(
                                  "No Section Available",
                                ),
                              ),
                            ),

                          /// SECTION LIST
                          Column(

                            children:

                                subject
                                    .sections
                                    .map(
                              (section) {

                                return Container(

                                  margin:
                                      const EdgeInsets.only(
                                    bottom:
                                        10,
                                  ),

                                  child:
                                      Row(

                                    children: [

                                      /// SECTION
                                      Expanded(

                                        child:
                                            Container(

                                          padding:
                                              const EdgeInsets.symmetric(
                                            vertical:
                                                12,
                                          ),

                                          decoration:
                                              BoxDecoration(

                                            color: Colors
                                                .blue
                                                .shade100,

                                            borderRadius:
                                                BorderRadius.circular(
                                              20,
                                            ),
                                          ),

                                          child:
                                              Text(

                                            section
                                                .sectionNo,

                                            textAlign:
                                                TextAlign.center,

                                            style:
                                                const TextStyle(

                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(
                                        width:
                                            10,
                                      ),

                                      /// CAPACITY
                                      Expanded(

                                        child:
                                            Container(

                                          padding:
                                              const EdgeInsets.symmetric(
                                            vertical:
                                                12,
                                          ),

                                          decoration:
                                              BoxDecoration(

                                            color: Colors
                                                .teal
                                                .shade100,

                                            borderRadius:
                                                BorderRadius.circular(
                                              20,
                                            ),
                                          ),

                                          child:
                                              Text(

                                            "${section.capacity} Left",

                                            textAlign:
                                                TextAlign.center,

                                            style:
                                                const TextStyle(

                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(
                                        width:
                                            10,
                                      ),

                                      /// ADD BUTTON
                                      ElevatedButton(

                                        style:
                                            ElevatedButton.styleFrom(

                                          backgroundColor:
                                              Colors.green,

                                          shape:
                                              RoundedRectangleBorder(

                                            borderRadius:
                                                BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),

                                        onPressed:
                                            () {

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(

                                            SnackBar(

                                              content:
                                                  Text(

                                                "Registered ${subject.subjectCode} ${section.sectionNo}",
                                              ),
                                            ),
                                          );
                                        },

                                        child:
                                            const Text(

                                          "+ Add",

                                          style:
                                              TextStyle(
                                            color:
                                                Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        ],
                      ),
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