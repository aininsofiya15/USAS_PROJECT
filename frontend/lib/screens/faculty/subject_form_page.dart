import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SubjectFormPage extends StatefulWidget {
  const SubjectFormPage({super.key});

  @override
  State<SubjectFormPage> createState() => _SubjectFormPageState();
}

class _SubjectFormPageState extends State<SubjectFormPage> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController creditController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController labController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0D8),

      appBar: AppBar(
        title: const Text("Subject Registration"),
        backgroundColor: Colors.white,
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black12,
                )
              ],
            ),

            child: Column(
              children: [

                const Text(
                  "Subject Registration Form",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Subject Name",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: "Subject Code",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: creditController,
                  decoration: const InputDecoration(
                    labelText: "Credit Hours",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: sectionController,
                  decoration: const InputDecoration(
                    labelText: "Total Section",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: labController,
                  decoration: const InputDecoration(
                    labelText: "Total Lab",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                  onPressed: () async {

  var url = Uri.parse(
    "http://10.0.2.2:8000/api/register-subject"
  );

  var response = await http.post(
    url,
    body: {

      "subject_name": nameController.text,
      "subject_code": codeController.text,
      "credit_hours": creditController.text,
      "total_section": sectionController.text,
      "total_lab": labController.text,

    },
  );

  print(response.body);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Subject Registered Successfully"), ), ); 
       nameController.clear();
  codeController.clear();
  creditController.clear();
  sectionController.clear();
  labController.clear();

},
                    child: const Text("Register Subject"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}