import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api.dart';

class RegistrarSubjectProvider {

  Future registerSubject({

    required String subjectName,
    required String subjectCode,
    required String creditHours,
    required String totalSection,
    required List sections,

  }) 
  
  
  async {

    print("========== API CALLED ==========");

    final body = {

      "subject_name": subjectName,

      "subject_code": subjectCode,

      "credit_hours": creditHours,

      "total_section": totalSection,

      "sections": sections,
    };

    print("========== REQUEST BODY ==========");
    print(jsonEncode(body));

    try {

      var response = await http.post(

        Uri.parse(Api.registerSubject),

        headers: {

          "Content-Type": "application/json",
          "Accept": "application/json",
        },

        body: jsonEncode(body),
      );

      print("========== STATUS CODE ==========");
print(response.statusCode);

print("========== RESPONSE BODY ==========");
print(response.body);

try {
  var decoded = jsonDecode(response.body);

  print("========== FULL RESPONSE ==========");
  print(decoded);

  print("========== ERROR ==========");
  print(decoded["error"]);

  print("========== MESSAGE ==========");
  print(decoded["message"]);
} catch (e) {
  print("JSON DECODE ERROR: $e");
}

      // Prevent crash if backend returns HTML
      if (response.body.startsWith("<!DOCTYPE html>")) {

        return {
          "success": false,
          "message":
              "Laravel backend crashed. Check php artisan serve terminal.",
        };
      }

      return jsonDecode(response.body);

    } catch (e) {

      print("========== ERROR ==========");
      print(e);

      return {

        "success": false,
        "message": e.toString(),
      };
    }
  }


Future updateSubject({
  required int subjectId,
  required String subjectName,
  required String subjectCode,
  required String creditHours,
}) async {

  var response = await http.put(
    Uri.parse("${Api.baseUrl}/subject/$subjectId"),
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
    body: jsonEncode({
      "subject_name": subjectName,
      "subject_code": subjectCode,
      "credit_hours": creditHours,
    }),
  );

  return jsonDecode(response.body);
}

Future deleteSubject(dynamic subjectId) async {

  var response = await http.delete(
    Uri.parse("${Api.baseUrl}/subject/$subjectId"),
  );

  print(response.statusCode);
  

  print(response.body);

return {};
}

  Future getLecturers() async {

    try {

      var response = await http.get(

        Uri.parse(Api.lecturers),
      );

      print("LECTURERS STATUS: ${response.statusCode}");
      print("LECTURERS BODY: ${response.body}");

      return jsonDecode(response.body);

    } catch (e) {

      print(e);

      return [];
    }
  }
}