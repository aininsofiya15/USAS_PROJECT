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

      /// NO LAB
      if (section.labs.isEmpty) {

        return const Padding(

          padding:
              EdgeInsets.all(10),

          child: Text(
            "No Lab Available",
          ),
        );
      }

      /// SHOW ALL LABS
      return Column(

        children:

            section.labs.map(
          (lab) {

            return Container(

              margin:
                  const EdgeInsets.only(
                bottom: 12,
              ),

              child: Row(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  /// LAB INFO
                  Expanded(

                    flex: 2,

                    child: Container(

                      padding:
                          const EdgeInsets.all(
                        10,
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

                      child: Column(

                        children: [

                          Text(

                            lab.labName,

                            textAlign:
                                TextAlign.center,

                            style:
                                const TextStyle(

                              fontWeight:
                                  FontWeight.bold,

                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            lab.scheduleDay,
                          ),

                          Text(
                            lab.scheduleTime,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  /// CAPACITY
                  Expanded(

                    child: Container(

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 20,
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

                      child: Text(

                        "${lab.capacity - lab.enrolled} Left",

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
                    width: 10,
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

                    onPressed: () async {

                      try {

                        await provider
                            .registerSubject(

                          studentId: 1,

                          subjectId:
                              subject.subjectId,

                          sectionId:
                              section.sectionId,

                          labId:
                              lab.labId,
                        );

                        /// SUCCESS POPUP
                        showDialog(

                          context: context,

                          barrierDismissible:
                              false,

                          builder: (context) {

                            return Dialog(

                              backgroundColor:
                                  Colors.transparent,

                              child: Container(

                                padding:
                                    const EdgeInsets.symmetric(

                                  horizontal: 25,
                                  vertical: 30,
                                ),

                                decoration:
                                    BoxDecoration(

                                  color:
                                      Colors.white,

                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),
                                ),

                                child: Column(

                                  mainAxisSize:
                                      MainAxisSize.min,

                                  children: [

                                    Container(

                                      width: 70,
                                      height: 70,

                                      decoration:
                                          BoxDecoration(

                                        shape:
                                            BoxShape.circle,

                                        border: Border.all(
                                          color:
                                              Colors.black,
                                          width: 2,
                                        ),
                                      ),

                                      child:
                                          const Icon(

                                        Icons.check,

                                        size: 45,

                                        color:
                                            Colors.black,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 20,
                                    ),

                                    const Text(

                                      "Subject added successfully",

                                      textAlign:
                                          TextAlign.center,

                                      style:
                                          TextStyle(

                                        fontSize:
                                            18,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 25,
                                    ),

                                    SizedBox(

                                      width: 120,

                                      height: 40,

                                      child:
                                          ElevatedButton(

                                        style:
                                            ElevatedButton.styleFrom(

                                          backgroundColor:
                                              Colors.green,
                                        ),

                                        onPressed:
                                            () {

                                          Navigator.pop(
                                            context,
                                          );
                                        },

                                        child:
                                            const Text(

                                          "OK",

                                          style:
                                              TextStyle(
                                            color:
                                                Colors.white,
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

                        /// REFRESH
                        setState(() {

                          subjectsFuture =
                              provider
                                  .fetchSubjects();
                        });

                      } catch (e) {

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(

                          SnackBar(
                            content:
                                Text("$e"),
                          ),
                        );
                      }
                    },

                    child: const Text(

                      "+ Add",

                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ).toList(),
      );
    },
  ).toList(),
),                           const SizedBox(
                            height: 10,
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