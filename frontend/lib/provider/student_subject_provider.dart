import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../domain/subject.dart';
import '../domain/registration.dart';

class StudentSubjectProvider {

  Future<List<SubjectModel>> fetchSubjects() async {

    final response = await http.get(

      Uri.parse(
        "${Api.baseUrl}/student/subjects",
      ),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      List subjectsJson = data['data'];

      return subjectsJson

          .map(
            (json) =>
                SubjectModel.fromJson(json),
          )

          .toList();

    } else {

      throw Exception(
        "Failed to load subjects",
      );
    }
  }

  Future<List<Registration>>
    fetchRegisteredSubjects(
  int studentId,
) async {

  final response = await http.get(

    Uri.parse(
      "${Api.baseUrl}/student/registered-subjects/$studentId",
    ),
  );

  if (response.statusCode == 200) {

    final data =
        jsonDecode(response.body);

    List subjectsJson =
        data['data'];

    return subjectsJson

        .map(
          (json) =>
              Registration.fromJson(
            json,
          ),
        )

        .toList();

  } else {

    throw Exception(
      "Failed to load registered subjects",
    );
  }
}

Future<void> registerSubject({

  required int studentId,

  required int subjectId,

  required int sectionId,

  required int labId,

}) async {

  final response = await http.post(

    Uri.parse(
      "${Api.baseUrl}/student/register-subject",
    ),

    headers: {

      "Content-Type":
          "application/json",
    },

    body: jsonEncode({

      "student_id":
          studentId,

      "subject_id":
          subjectId,

      "section_id":
          sectionId,

      "lab_id":
          labId,
    }),
  );

  final data =
      jsonDecode(response.body);

  if (data['success'] != true) {

    throw Exception(
      data['message'],
    );
  }
}

Future<void> dropSubject(
  int registrationId,
) async {

  final response = await http.put(

    Uri.parse(

      "${Api.baseUrl}/student/drop-subject/$registrationId",
    ),
  );

  if (response.statusCode != 200) {

    throw Exception(
      "Failed to drop subject",
    );
  }
}
}