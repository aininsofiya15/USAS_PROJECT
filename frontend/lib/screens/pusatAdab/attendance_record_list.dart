import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/attendance_provider.dart';

class AttendanceRecordListPage extends StatefulWidget {
  final dynamic module; 
  const AttendanceRecordListPage({super.key, required this.module});

  @override
  State<AttendanceRecordListPage> createState() => _AttendanceRecordListPageState();
}

class _AttendanceRecordListPageState extends State<AttendanceRecordListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use the ID from the modules table to fetch present students
      Provider.of<AttendanceProvider>(context, listen: false)
          .fetchPresentStudents(widget.module.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFD1FFF3),
      appBar: AppBar(title: const Text("Attendance Records")),
      body: Column(
        children: [
          // FIX 1: Pass the whole widget.module object, not just the name
          _buildHeader(widget.module), 
          
          _buildStatusToggle(),

          Expanded(
            child: provider.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildStudentList(provider.presentStudents),
          ),
        ],
      ),
    );
  }

  // FIX 2: This now correctly receives the object and accesses its properties
  Widget _buildHeader(dynamic module) {
    return Container(
      margin: const EdgeInsets.all(15),
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Uses activity_name from image_0e98f6.png
          Text(
            module.activityName.toUpperCase(), 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
          ),
          const SizedBox(height: 10),
          // Uses date_time from image_0e98f6.png
          Text("Class Date: ${module.dateTime}"),
          Text("Venue: ${module.venue ?? 'Dewan Serbaguna'}"), 
          Text("Lecturer Name: ${module.lecturerName ?? 'Staff'}"),
        ],
      ),
    );
  }

  Widget _buildStatusToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {}, 
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD1E3FF)),
            child: const Text("Present", style: TextStyle(color: Colors.black))
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: () {}, 
            style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text("Not Present", style: TextStyle(color: Colors.black))
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(List<dynamic> students) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        children: [
          const TextField(
            decoration: InputDecoration(
              hintText: "Search",
              prefixIcon: Icon(Icons.search),
              border: UnderlineInputBorder(),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: students.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final student = students[index];
                return ListTile(
                  leading: Text("${index + 1}"),
                  // Maps to student_id in image_0e9838.png
                  title: Text(
                    student['student_id'], 
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
                  ),
                  // Faculty information from image_0e9838.png
                  subtitle: Text(student['faculty'] ?? 'Faculty of Computing'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _actionBtn("Grade", Colors.green, () {
                        // Mark update logic for attendance_records table
                      }),
                      const SizedBox(width: 5),
                      _actionBtn("Edit", Colors.blue, () {}),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(60, 30),
        padding: EdgeInsets.zero,
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}