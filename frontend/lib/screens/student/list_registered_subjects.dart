import 'package:flutter/material.dart';

import '../../domain/registration.dart';
import '../../provider/student_subject_provider.dart';

import '../../widgets/app_sidebar.dart';
import '../../widgets/header.dart';

class ListRegisteredSubjectsPage
    extends StatefulWidget {

  const ListRegisteredSubjectsPage({
    super.key,
  });

  @override
  State<ListRegisteredSubjectsPage>
      createState() =>
          _ListRegisteredSubjectsPageState();
}

class _ListRegisteredSubjectsPageState
    extends State<ListRegisteredSubjectsPage> {

  final StudentSubjectProvider
      provider =
          StudentSubjectProvider();

  late Future<List<Registration>>
      registeredSubjectsFuture;

  @override
  void initState() {

    super.initState();

    /// STUDENT ID TEMPORARY = 1
    registeredSubjectsFuture =
        provider
            .fetchRegisteredSubjects(
      1,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      /// SAME SIDEBAR
      drawer: const AppSidebar(),

      backgroundColor:
          const Color(0xFFEAF6FB),

      /// SAME HEADER
      appBar: const UsasHeader(),

      body:
          FutureBuilder<List<Registration>>(

        future:
            registeredSubjectsFuture,

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

          final subjects =
              snapshot.data ?? [];

          /// TOTAL CREDIT
          int totalCredit = 0;

          for (var subject
              in subjects) {

            totalCredit +=
                subject.creditHours;
          }

          return Padding(

            padding:
                const EdgeInsets.all(
              16,
            ),

            child: Container(

              padding:
                  const EdgeInsets.all(
                16,
              ),

              decoration: BoxDecoration(

                color:
                    const Color(
                  0xFFD9EEF8,
                ),

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  /// TITLE
                  const Center(

                    child: Text(

                      "List of Registered Subjects",

                      style: TextStyle(

                        fontSize: 22,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  /// TOTAL CREDIT
                  Container(

                    padding:
                        const EdgeInsets.symmetric(

                      horizontal: 14,

                      vertical: 10,
                    ),

                    decoration:
                        BoxDecoration(

                      color:
                          Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),

                    child: Text(

                      "Total Credit Hour: $totalCredit",

                      style:
                          const TextStyle(

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  /// TABLE HEADER
                  Row(

                    children: const [

                      Expanded(

                        flex: 3,

                        child: Text(

                          "Subject",

                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      Expanded(

                        child: Text(

                          "Credit",

                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      Expanded(

                        child: Text(

                          "Section",

                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(width: 30),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  /// SUBJECT LIST
                  Expanded(

                    child: ListView.builder(

                      itemCount:
                          subjects.length,

                      itemBuilder:
                          (context, index) {

                        final subject =
                            subjects[index];

                        return Container(

                          margin:
                              const EdgeInsets.only(
                            bottom: 10,
                          ),

                          padding:
                              const EdgeInsets.symmetric(

                            horizontal: 10,

                            vertical: 12,
                          ),

                          decoration:
                              BoxDecoration(

                            color:
                                Colors.white,

                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),

                          child: Row(

                            children: [

                              /// SUBJECT
                              Expanded(

                                flex: 3,

                                child: Text(

                                  "${subject.subjectCode} - ${subject.subjectName}",
                                ),
                              ),

                              /// CREDIT
                              Expanded(

                                child: Text(

                                  "${subject.creditHours}",
                                ),
                              ),

                              /// SECTION
                              Expanded(

                                child: Text(
                                  subject.sectionNo,
                                ),
                              ),

                              /// DELETE
                              IconButton(

                                onPressed: () {

                                },

                                icon: const Icon(

                                  Icons.delete,

                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}