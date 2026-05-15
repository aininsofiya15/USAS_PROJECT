import 'package:flutter/material.dart';

import '../../domain/subject.dart';
import '../../provider/student_subject_provider.dart';

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

      drawer: const AppSidebar(),

      backgroundColor:
          const Color(0xFFEAF6FB),

      body: Column(

        children: [

          const UsasHeader(),

          Expanded(

            child:
                FutureBuilder<List<SubjectModel>>(

              future: subjectsFuture,

              builder:
                  (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {

                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {

                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                    ),
                  );
                }

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

                          Column(

                            children:

                                subject
                                    .sections
                                    .map(
                              (section) {

                                if (section
                                    .labs
                                    .isEmpty) {

                                  return const Padding(

                                    padding:
                                        EdgeInsets.all(
                                      10,
                                    ),

                                    child: Text(
                                      "No Lab Available",
                                    ),
                                  );
                                }

                                return Column(

                                  children:

                                      section
                                          .labs
                                          .map(
                                    (lab) {

                                      return Container(

                                        margin:
                                            const EdgeInsets.only(
                                          bottom:
                                              12,
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

                                                  color:
                                                      Colors.blue.shade100,

                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    20,
                                                  ),
                                                ),

                                                child:
                                                    Column(

                                                  children: [

                                                    Text(

                                                      lab.labName ?? '',

                                                      textAlign:
                                                          TextAlign.center,

                                                      style:
                                                          const TextStyle(

                                                        fontWeight:
                                                            FontWeight.bold,

                                                        fontSize:
                                                            14,
                                                      ),
                                                    ),

                                                    const SizedBox(
                                                      height:
                                                          5,
                                                    ),

                                                    Text(
                                                      lab.scheduleDay ?? '',
                                                    ),

                                                    Text(
                                                      lab.scheduleTime ?? '',
                                                    ),
                                                  ],
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
                                                      20,
                                                ),

                                                decoration:
                                                    BoxDecoration(

                                                  color:
                                                      Colors.teal.shade100,

                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    20,
                                                  ),
                                                ),

                                                child:
                                                    Text(

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
                                                  () async {

                                                try {

                                                  await provider.registerSubject(

                                                    studentId:
                                                        1,

                                                    subjectId:
                                                        subject.subjectId,

                                                    sectionId:
                                                        section.sectionId,

                                                    labId:
                                                        lab.labId,
                                                  );

                                                  /// SUCCESS POPUP
                                                  showDialog(

                                                    context:
                                                        context,

                                                    barrierDismissible:
                                                        false,

                                                    builder:
                                                        (context) {

                                                      return Dialog(

                                                        child:
                                                            Container(

                                                          padding:
                                                              const EdgeInsets.all(
                                                            25,
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

                                                          child:
                                                              Column(

                                                            mainAxisSize:
                                                                MainAxisSize.min,

                                                            children: [

                                                              const Icon(

                                                                Icons.check_circle,

                                                                color:
                                                                    Colors.green,

                                                                size:
                                                                    70,
                                                              ),

                                                              const SizedBox(
                                                                height:
                                                                    20,
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
                                                                height:
                                                                    25,
                                                              ),

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
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );

                                                  setState(() {

                                                    subjectsFuture =
                                                        provider.fetchSubjects();
                                                  });

                                                }catch (e) {

  String errorMessage = e.toString();

  /// SCHEDULE CONFLICT
  if (errorMessage.contains("Schedule conflict")) {

    showDialog(

      context: context,

      barrierDismissible: false,

      builder: (context) {

        return Dialog(

          child: Container(

            padding: const EdgeInsets.all(25),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius: BorderRadius.circular(20),
            ),

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: [

                const Icon(

                  Icons.close,

                  color: Colors.red,

                  size: 70,
                ),

                const SizedBox(height: 20),

                const Text(

                  "Selected subject has a schedule conflict with your existing timetable",

                  textAlign: TextAlign.center,

                  style: TextStyle(

                    fontSize: 18,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.red,
                  ),

                  onPressed: () {

                    Navigator.pop(context);
                  },

                  child: const Text(

                    "OK",

                    style: TextStyle(

                      color: Colors.white,
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

  /// DUPLICATE SUBJECT
  else if (errorMessage.contains("already registered")) {

    showDialog(

      context: context,

      barrierDismissible: false,

      builder: (context) {

        return Dialog(

          child: Container(

            padding: const EdgeInsets.all(25),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius: BorderRadius.circular(20),
            ),

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: [

                const Icon(

                  Icons.warning,

                  color: Colors.orange,

                  size: 70,
                ),

                const SizedBox(height: 20),

                const Text(

                  "You have already registered this subject",

                  textAlign: TextAlign.center,

                  style: TextStyle(

                    fontSize: 18,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.orange,
                  ),

                  onPressed: () {

                    Navigator.pop(context);
                  },

                  child: const Text(

                    "OK",

                    style: TextStyle(

                      color: Colors.white,
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

  /// CREDIT LIMIT
  else {

    showDialog(

      context: context,

      barrierDismissible: false,

      builder: (context) {

        return Dialog(

          child: Container(

            padding: const EdgeInsets.all(25),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius: BorderRadius.circular(20),
            ),

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: [

                const Icon(

                  Icons.close,

                  color: Colors.red,

                  size: 70,
                ),

                const SizedBox(height: 20),

                const Text(

                  "You have reached the maximum subject registration limit",

                  textAlign: TextAlign.center,

                  style: TextStyle(

                    fontSize: 18,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.red,
                  ),

                  onPressed: () {

                    Navigator.pop(context);
                  },

                  child: const Text(

                    "OK",

                    style: TextStyle(

                      color: Colors.white,
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
}
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