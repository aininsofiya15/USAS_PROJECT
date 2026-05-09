import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/attendance_provider.dart';
import '../../domain/module.dart'; // Import your Module domain
import '../../widgets/header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/navigation_bar.dart';

class AttendanceRecordListPage extends StatefulWidget {
  final Module module; 
  final int bookingId; 

  const AttendanceRecordListPage({
    super.key, 
    required this.bookingId, 
    required this.module
  });

  @override
  State<AttendanceRecordListPage> createState() => _AttendanceRecordListPageState();
}

class _AttendanceRecordListPageState extends State<AttendanceRecordListPage> {
  bool showPresent = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch Pusat ADAB records immediately using the bookingId
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().fetchAttendanceDetails(widget.bookingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        final students = provider.studentRecords; 
        
        return Scaffold(
          backgroundColor: const Color(0xFFD1FFF3),
          appBar: const UsasHeader(),
          drawer: const AppSidebar(),
          bottomNavigationBar: const UsasBottomNav(),
          body: Column(
            children: [
              // Uses widget.module directly for initial load
              _buildHeader(widget.module),
              const SizedBox(height: 10),
              _buildStatusToggle(),
              const SizedBox(height: 10),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildStudentList(students),
              ),
            ],
          ),
        );
      },
    );
  }

  // Changed dynamic to Module to ensure type safety
  Widget _buildHeader(Module module) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Text(
            module.activityName.toUpperCase(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text("Class Date: ${module.dateTime}"),
          Text("Venue: ${module.venue}"),
          Text("Lecturer: ${module.lecturerName}"),
        ],
      ),
    );
  }

  Widget _buildStatusToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _toggleItem("Present", showPresent, () => setState(() => showPresent = true)),
          _toggleItem("Not Present", !showPresent, () => setState(() => showPresent = false)),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD1E3FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue[900] : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList(List<dynamic> students) {
    final filtered = students.where((s) {
      bool statusMatch = showPresent 
          ? s.status.toLowerCase() == 'present' 
          : s.status.toLowerCase() != 'present';
      
      bool searchMatch = _searchController.text.isEmpty || 
          s.studentName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          s.studentId.contains(_searchController.text);
          
      return statusMatch && searchMatch;
    }).toList();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search student...",
              prefixIcon: const Icon(Icons.search),
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
            ),
            onChanged: (val) => setState(() {}),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filtered.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off_outlined, size: 50, color: Colors.grey[400]),
                      const SizedBox(height: 10),
                      Text(
                        "No student data found for this module.",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final student = filtered[index];
                    return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: Text("${index + 1}", style: const TextStyle(fontSize: 12)),
                        ),
                        title: Text(
                          student.studentId, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: Text(student.studentName),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _actionBtn("Grade", Colors.greenAccent[400]!, () => _showGradeDialog(student)),
                            const SizedBox(width: 4),
                            _actionBtn("Edit", Colors.blueAccent, () {}),
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
    return SizedBox(
      height: 28,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ),
    );
  }

  void _showGradeDialog(dynamic student) {
    final TextEditingController gradeController = 
        TextEditingController(text: student.marks?.toString() ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Grade ${student.studentName}"),
        content: TextField(
          controller: gradeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Enter Marks (0-100)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final double? marks = double.tryParse(gradeController.text);
              if (marks != null) {
                String category = marks >= 50 ? "Pass" : "Fail";
                await context.read<AttendanceProvider>().updateStudentGrade(
                  student.id, 
                  marks, 
                  category, 
                );
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}