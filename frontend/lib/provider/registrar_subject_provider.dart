import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class RegistrarSubjectProvider {

  // Register a new subject with sections and labs
  Future registerSubject({

    required String subjectName,
    required String subjectCode,
    required String creditHours,
    required String totalSection,
    required List sections,

  }) async {

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

      // Display API response status
      print("========== STATUS CODE ==========");
      print(response.statusCode);

      // Display API response body
      print("========== RESPONSE BODY ==========");
      print(response.body);

      try {

        var decoded = jsonDecode(response.body);

        // Display decoded response
        print("========== FULL RESPONSE ==========");
        print(decoded);

        print("========== ERROR ==========");
        print(decoded["error"]);

        print("========== MESSAGE ==========");
        print(decoded["message"]);

      } catch (e) {

        print("JSON DECODE ERROR: $e");
      }

      // Prevent app crash if Laravel returns HTML error page
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

  // Update existing subject information
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

  // Deactivate or delete a subject
  Future deleteSubject(
    dynamic subjectId,
  ) async {

    var response = await http.delete(

      Uri.parse(
        "${Api.baseUrl}/subject/$subjectId",
      ),
    );

    // Display API status code
    print(response.statusCode);

    // Display API response body
    print(response.body);

    return {};
  }

  // Retrieve lecturer list
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