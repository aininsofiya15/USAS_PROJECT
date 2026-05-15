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

}) async {

  final response = await http.post(

    Uri.parse(
      "${Api.baseUrl}/student/register-subject",
    ),

    body: {

      'student_id':
          studentId.toString(),

      'subject_id':
          subjectId.toString(),

      'section_id':
          sectionId.toString(),
    },
  );

  if (response.statusCode != 200) {

    throw Exception(
      "Failed to register subject",
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