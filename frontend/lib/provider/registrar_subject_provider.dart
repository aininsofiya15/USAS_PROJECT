import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api.dart';

class RegistrarSubjectProvider {

  Future registerSubject({

    required String subjectName,
    required String subjectCode,
    required String creditHours,
    required String totalSection,

  }) async {

    var response = await http.post(

      Uri.parse(Api.registerSubject),

      headers: {

        "Content-Type":
            "application/json",
      },

      body: jsonEncode({

        "subject_name":
            subjectName,

        "subject_code":
            subjectCode,

        "credit_hours":
            creditHours,

        "total_section":
            totalSection,
      }),
    );

    return jsonDecode(response.body);
  }
}