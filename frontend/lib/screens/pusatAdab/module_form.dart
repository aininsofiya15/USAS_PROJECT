import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';
import '../../provider/module_provider.dart';
import '../../domain/module.dart';

class ModuleFormPage extends StatefulWidget {
  final Module? existingModuleData;

  const ModuleFormPage({super.key, this.existingModuleData});

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
  final picController = TextEditingController();

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
    picController.dispose();
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
          String datePart =
              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
          String timePart =
              "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
          dateController.text = "$datePart $timePart";
        });
      }
    }
  }

  Future<void> handleSave(BuildContext context, String status) async {
    final moduleProvider = Provider.of<ModuleProvider>(context, listen: false);

    if (nameController.text.isEmpty || capacityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in Activity Name and Capacity!"),
        ),
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

      if (mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Check Laravel CORS or Server status."),
        ),
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
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          children: [
            Text(
              isEditMode ? "Edit Module" : "Add Module",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.14),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Default Fields",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInput(Icons.card_travel, "Activity Name*", nameController),
                  GestureDetector(
                    onTap: () => selectDateTime(context),
                    child: AbsorbPointer(
                      child: _buildInput(
                        Icons.calendar_month,
                        "Date & Time*",
                        dateController,
                        trailingIcon: Icons.calendar_month,
                      ),
                    ),
                  ),
                  _buildInput(
                    Icons.groups,
                    "Capacity*",
                    capacityController,
                    isNumber: true,
                  ),
                  _buildInput(Icons.location_on_outlined, "Venue*", venueController),
                  _buildInput(
                    Icons.person_outline,
                    "Lecturer's Name*",
                    lecturerController,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Additional Fields",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildInput(
                    Icons.description_outlined,
                    "Add Description",
                    descController,
                  ),
                  _buildInput(Icons.link, "Whatsapp Link", linkController),
                  _buildInput(
                    Icons.badge_outlined,
                    "PIC Contact",
                    picController,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => handleSave(context, 'draft'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 38),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Save as Draft",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => handleSave(context, 'published'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 38),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Publish",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
    IconData icon,
    String hint,
    TextEditingController controller, {
    bool isNumber = false,
    IconData trailingIcon = Icons.edit_square,
  }) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(3),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.black87, size: 19),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 38,
            minHeight: 40,
          ),
          suffixIcon: Icon(trailingIcon, color: Colors.black87, size: 15),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 40,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
