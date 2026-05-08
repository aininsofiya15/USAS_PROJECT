import 'package:flutter/material.dart';
import 'add_section_page.dart';

class SubjectDetailsPage extends StatelessWidget {

  final Map subject;

  const SubjectDetailsPage({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF6F0D8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Subject Details",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      bottomNavigationBar: Container(

        margin: const EdgeInsets.all(20),

        padding: const EdgeInsets.symmetric(vertical: 15),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.circular(30),

        ),

        child: const Row(

          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          children: [

            Icon(Icons.home),
            Icon(Icons.notifications),
            Icon(Icons.person),

          ],
        ),
      ),

      body: SingleChildScrollView(

        child: Padding(

          padding: const EdgeInsets.all(20),

          child: Container(

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(

              color: const Color(0xFFF3EDC8),

              borderRadius: BorderRadius.circular(20),

            ),

            child: Column(

              children: [

                Text(

                  "${subject['subject_code']} - ${subject['subject_name']}",

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(

                  "Credit Hours : ${subject['credit_hours']}",

                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Row(

                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [

                    ElevatedButton(
                      onPressed: () {},
                      child: const Text("SECTION 1"),
                    ),

                    const SizedBox(width: 10),

                    ElevatedButton(
                      onPressed: () {},
                      child: const Text("SECTION 2"),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Container(

                  width: double.infinity,

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius: BorderRadius.circular(20),

                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 5,
                        color: Colors.black12,
                      )
                    ],
                  ),

                  child: Column(

                    children: [

                      TextField(

                        decoration: InputDecoration(

                          hintText: "Choose Lab",

                          prefixIcon: const Icon(Icons.search),

                          filled: true,

                          fillColor: const Color(0xFFF6F0D8),

                          border: OutlineInputBorder(

                            borderRadius: BorderRadius.circular(30),

                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(

                        "Lab 2A",

                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Capacity : 30"),
                      ),

                      const SizedBox(height: 5),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Total Student : 25"),
                      ),

                      const SizedBox(height: 5),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Cap Available : 5"),
                      ),

                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const Text(

                  "List Registered Student",

                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 20),

                buildStudentCard(
                  "1. Ainin Sofiya",
                  "CB23015",
                ),

                buildStudentCard(
                  "2. Siti Nur Hidayah",
                  "CB23020",
                ),

                buildStudentCard(
                  "3. Wahidah Syarini",
                  "CB23024",
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStudentCard(
    String name,
    String matric,
  ) {

    return Container(

      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(15),

        border: Border.all(color: Colors.black12),

      ),

      child: Row(

        children: [

          const CircleAvatar(
            child: Icon(Icons.person),
          ),

          const SizedBox(width: 10),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(name),

                Text(
                  matric,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Container(

            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),

            decoration: BoxDecoration(

              color: Colors.green,

              borderRadius: BorderRadius.circular(20),

            ),

            child: const Text(

              "Active",

              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}