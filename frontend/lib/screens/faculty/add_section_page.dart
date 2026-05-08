import 'package:flutter/material.dart';

class AddSectionPage extends StatefulWidget {

  const AddSectionPage({super.key});

  @override
  State<AddSectionPage> createState() => _AddSectionPageState();
}

class _AddSectionPageState extends State<AddSectionPage> {

  final sectionController = TextEditingController();

  final capacityController = TextEditingController();

  final dayController = TextEditingController();

  final timeController = TextEditingController();

  final List<String> labs = [];

  final labController = TextEditingController();

  String? selectedLecturer;

  final List<String> lecturers = [

    "Dr Kirahman",
    "Dr Amin",
    "Dr Sarah",

  ];

  void addLab() {

    if (labController.text.isNotEmpty) {

      setState(() {

        labs.add(labController.text);

      });

      labController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF6F0D8),

      appBar: AppBar(

        title: const Text("Add Section"),

        backgroundColor: Colors.white,
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

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const Text(

                  "Section Information",

                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                TextField(

                  controller: sectionController,

                  decoration: InputDecoration(

                    labelText: "Section Number",

                    filled: true,

                    fillColor: Colors.white,

                    border: OutlineInputBorder(

                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                DropdownButtonFormField<String>(

                  value: selectedLecturer,

                  items: lecturers.map((lecturer) {

                    return DropdownMenuItem(

                      value: lecturer,

                      child: Text(lecturer),
                    );

                  }).toList(),

                  onChanged: (value) {

                    setState(() {

                      selectedLecturer = value;

                    });
                  },

                  decoration: InputDecoration(

                    labelText: "Select Lecturer",

                    filled: true,

                    fillColor: Colors.white,

                    border: OutlineInputBorder(

                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(

                  controller: capacityController,

                  keyboardType: TextInputType.number,

                  decoration: InputDecoration(

                    labelText: "Capacity",

                    filled: true,

                    fillColor: Colors.white,

                    border: OutlineInputBorder(

                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(

                  controller: dayController,

                  decoration: InputDecoration(

                    labelText: "Schedule Day",

                    filled: true,

                    fillColor: Colors.white,

                    border: OutlineInputBorder(

                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(

                  controller: timeController,

                  decoration: InputDecoration(

                    labelText: "Schedule Time",

                    filled: true,

                    fillColor: Colors.white,

                    border: OutlineInputBorder(

                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(

                  "Labs",

                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Row(

                  children: [

                    Expanded(

                      child: TextField(

                        controller: labController,

                        decoration: InputDecoration(

                          labelText: "Lab Name",

                          filled: true,

                          fillColor: Colors.white,

                          border: OutlineInputBorder(

                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    ElevatedButton(

                      onPressed: addLab,

                      child: const Text("Add"),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                ...labs.map((lab) {

                  return Container(

                    margin: const EdgeInsets.only(bottom: 10),

                    padding: const EdgeInsets.all(15),

                    decoration: BoxDecoration(

                      color: Colors.white,

                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: Row(

                      children: [

                        const Icon(Icons.computer),

                        const SizedBox(width: 10),

                        Text(lab),
                      ],
                    ),
                  );

                }),

                const SizedBox(height: 30),

                SizedBox(

                  width: double.infinity,

                  height: 50,

                  child: ElevatedButton(

                    onPressed: () {},

                    child: const Text("Save Section"),
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