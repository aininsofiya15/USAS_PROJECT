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

  // Stores end time separately for UI display only
  String _endTime = '';

  bool get isEditMode => widget.existingModuleData != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final data = widget.existingModuleData!;
      nameController.text = data.activityName;
      capacityController.text = data.capacity.toString();
      venueController.text = data.venue;
      lecturerController.text = data.lecturerName;
      linkController.text = data.whatsappLink ?? '';

      // Parse stored description: separate real desc from [end_time:XX:XX]
      final raw = data.description ?? '';
      final endTimeMatch = RegExp(r'\[end_time:(\d{2}:\d{2})\]').firstMatch(raw);
      if (endTimeMatch != null) {
        _endTime = endTimeMatch.group(1)!;
        descController.text = raw.replaceAll(endTimeMatch.group(0)!, '').trim();
      } else {
        descController.text = raw;
      }

      // Rebuild dateController to show "YYYY-MM-DD HH:MM-HH:MM" in edit mode
      final startRaw = data.dateTime; // "2026-06-17 08:00:00"
      if (_endTime.isNotEmpty && startRaw.length >= 16) {
        final datePart = startRaw.substring(0, 10);
        final startTimePart = startRaw.substring(11, 16);
        dateController.text = "$datePart $startTimePart-$_endTime";
      } else {
        dateController.text = startRaw;
      }
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
      final TimeOfDay? startTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        helpText: 'Select Start Time',
      );

      if (startTime != null) {
        if (!mounted) return;
        final TimeOfDay? endTime = await showTimePicker(
          context: context,
          initialTime: startTime,
          helpText: 'Select End Time',
        );

        if (endTime != null) {
          setState(() {
            String datePart =
                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
            String startPart =
                "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
            String endPart =
                "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";
            _endTime = endPart;
            // Display both times in the field
            dateController.text = "$datePart $startPart-$endPart";
          });
        }
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

    // Parse "2026-06-17 08:00-17:00" → send only start datetime to DB
    final rawDate = dateController.text;
    String startDateTime = rawDate;

    if (_endTime.isNotEmpty && rawDate.contains('-', 11)) {
      final parts = rawDate.split(' ');
      if (parts.length == 2) {
        final timePart = parts[1].split('-').first; // "08:00"
        startDateTime = "${parts[0]} $timePart:00"; // "2026-06-17 08:00:00"
      }
    }

    // Pack end time into description invisibly
    final finalDesc = _endTime.isNotEmpty
        ? '${descController.text.trim()}[end_time:$_endTime]'
        : descController.text.trim();

    bool success = false;

    if (isEditMode) {
      success = await moduleProvider.updateModule(
        id: widget.existingModuleData!.id.toString(),
        activityName: nameController.text,
        dateTime: startDateTime,
        capacity: int.tryParse(capacityController.text) ?? 0,
        venue: venueController.text,
        lecturerName: lecturerController.text,
        description: finalDesc,
        whatsappLink: linkController.text,
        picContact: picController.text,
        status: status,
      );
    } else {
      success = await moduleProvider.createModule(
        activityName: nameController.text,
        dateTime: startDateTime,
        capacity: int.tryParse(capacityController.text) ?? 0,
        venue: venueController.text,
        lecturerName: lecturerController.text,
        description: finalDesc,
        whatsappLink: linkController.text,
        picContact: picController.text,
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
        SnackBar(
          content: Text(
            moduleProvider.errorMessage ??
                "Error: Check Laravel CORS or Server status.",
          ),
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
                        "Date & Time (Start - End)*",
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