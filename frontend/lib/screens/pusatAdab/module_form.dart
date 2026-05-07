import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';
import '../../provider/module_provider.dart';
import '../../domain/module.dart'; 

class ModuleFormPage extends StatefulWidget {
  final Module? existingModuleData;

   ModuleFormPage({super.key, this.existingModuleData});

  @override
  State<ModuleFormPage> createState() => ModuleFormPageState();
}

class ModuleFormPageState extends State<ModuleFormPage> {
  final nameController = TextEditingController();
  final dateController = TextEditingController();
  final capacityController = TextEditingController();
  final venueController = TextEditingController();
  final lecturerController = TextEditingController();
  final descController = TextEditingController();
  final linkController = TextEditingController();

  bool get isEditMode => widget.existingModuleData != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final data = widget.existingModuleData!;
      nameController.text = data.activityName;
      dateController.text = data.dateTime;
      capacityController.text = data.capacity.toString();
      venueController.text = data.venue;
      lecturerController.text = data.lecturerName;
      descController.text = data.description ?? ''; 
      linkController.text = data.whatsappLink ?? '';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    dateController.dispose();
    capacityController.dispose();
    venueController.dispose();
    lecturerController.dispose();
    descController.dispose();
    linkController.dispose();
    super.dispose();
  }

  Future<void> selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          String datePart = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
          String timePart = "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
          dateController.text = "$datePart $timePart";
        });
      }
    }
  }

  Future<void> handleSave(BuildContext context, String status) async {
    final moduleProvider = Provider.of<ModuleProvider>(context, listen: false);

    if (nameController.text.isEmpty || capacityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in Activity Name and Capacity!")),
      );
      return;
    }

    bool success = false;

    if (isEditMode) {
      success = await moduleProvider.updateModule(
        id: widget.existingModuleData!.id.toString(), 
        activityName: nameController.text,
        dateTime: dateController.text,
        capacity: int.tryParse(capacityController.text) ?? 0,
        venue: venueController.text,
        lecturerName: lecturerController.text,
        description: descController.text,
        whatsappLink: linkController.text,
        status: status,
      );
    } else {
      success = await moduleProvider.createModule(
        activityName: nameController.text,
        dateTime: dateController.text,
        capacity: int.tryParse(capacityController.text) ?? 0,
        venue: venueController.text,
        lecturerName: lecturerController.text,
        description: descController.text,
        whatsappLink: linkController.text,
        status: status,
      );
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Successfully saved as $status!")),
      );
      
      // Pops screen back to ViewModulesPage after successful save
      if (mounted) Navigator.pop(context);
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Check Laravel CORS or Server status.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5FFF7), 
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              isEditMode ? "Edit Module" : "Add Module", 
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Default Fields", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 15),
                  _buildInput(Icons.edit_note, "Activity Name*", nameController),
                  GestureDetector(
                    onTap: () => selectDateTime(context),
                    child: AbsorbPointer(
                      child: _buildInput(Icons.calendar_today, "Select Date & Time*", dateController),
                    ),
                  ),
                  _buildInput(Icons.people_outline, "Capacity*", capacityController, isNumber: true),
                  _buildInput(Icons.location_on_outlined, "Venue*", venueController),
                  _buildInput(Icons.person_outline, "Lecturer's Name*", lecturerController),
                  const SizedBox(height: 20),
                  const Text("Additional Fields", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 15),
                  _buildInput(Icons.description_outlined, "Add Description", descController),
                  _buildInput(Icons.link, "WhatsApp Group Link", linkController),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => handleSave(context, 'draft'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blue),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Save as Draft"),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => handleSave(context, 'published'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Publish", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(IconData icon, String hint, TextEditingController? controller, {bool isNumber = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.black45),
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}