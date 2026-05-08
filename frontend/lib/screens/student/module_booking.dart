import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';
import '../../provider/module_provider.dart';
import '../../provider/user_provider.dart'; 
import '../../domain/module.dart';

class StudentActivitiesPage extends StatefulWidget {
  const StudentActivitiesPage({super.key});

  @override
  State<StudentActivitiesPage> createState() => _StudentActivitiesPageState();
}

class _StudentActivitiesPageState extends State<StudentActivitiesPage> {
  String selectedTab = 'All'; 
  
  // Track selected date slot per activity group
  final Map<String, Module> _selectedSubModules = {};

  // Track expansion state for each unique activity name
  final Map<String, bool> _isExpanded = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<ModuleProvider>(context, listen: false).fetchModules());
  }

  // 🔥 REUSABLE DIALOG: Handles both success and error states
  void showResultDialog({required BuildContext context, required String title, required bool isSuccess}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: isSuccess ? const Color(0xE8EAF6F1) : const Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: Icon(
                  isSuccess ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                  color: isSuccess ? const Color(0xFF00C853) : Colors.redAccent,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 18,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? const Color(0xFF00C853) : Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "OK", 
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final moduleProvider = Provider.of<ModuleProvider>(context);

    List<Module> filteredRawModules = moduleProvider.modules
        .where((m) => m.status.toLowerCase() == 'published')
        .toList();

    if (selectedTab == 'Available') {
      filteredRawModules = filteredRawModules
          .where((m) => m.registeredCount < m.capacity)
          .toList();
    }

    final Map<String, List<Module>> groupedModules = {};
    for (var module in filteredRawModules) {
      final nameKey = module.activityName.trim();
      if (!groupedModules.containsKey(nameKey)) {
        groupedModules[nameKey] = [];
      }
      groupedModules[nameKey]!.add(module);
    }

    final activityNames = groupedModules.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE3EFF8),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5), 
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTabButton("All"), 
                  _buildTabButton("Available"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 15), 
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 206, 229, 244), 
                borderRadius: BorderRadius.circular(40), 
              ),
              child: moduleProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: activityNames.length,
                        itemBuilder: (context, index) {
                          final activityName = activityNames[index];
                          final slots = groupedModules[activityName] ?? [];
                          return _buildStudentActivityCard(activityName, slots);
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentActivityCard(String activityName, List<Module> slots) {
    _isExpanded.putIfAbsent(activityName, () => false); 
    if (!_selectedSubModules.containsKey(activityName) && slots.isNotEmpty) {
      _selectedSubModules[activityName] = slots.first;
    }

    final currentSelectedSlot = _selectedSubModules[activityName]!;
    bool expanded = _isExpanded[activityName]!;

    int availableSlots = currentSelectedSlot.capacity - currentSelectedSlot.registeredCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FDFF), 
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded[activityName] = !expanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    activityName.toUpperCase(), 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                ),
                Icon(expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down, size: 28, color: Colors.blue.shade700),
              ],
            ),
          ),
          const Text("Currently Open", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 12),
          
          _buildInfoRow(Icons.people, "Available Slots: $availableSlots / ${currentSelectedSlot.capacity} Seats Left"),
          _buildInfoRow(Icons.access_time, "Class Time: ${currentSelectedSlot.dateTime}"),
          _buildInfoRow(Icons.location_on, "Venue: ${currentSelectedSlot.venue}"),
          _buildInfoRow(Icons.person, "Lecturer: ${currentSelectedSlot.lecturerName}"),
          
          if (expanded) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            const SizedBox(height: 15),
            const Text("Available Slots:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue)),
            const SizedBox(height: 10),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: slots.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.1,
              ),
              itemBuilder: (context, slotIndex) {
                final slot = slots[slotIndex];
                bool isFull = slot.registeredCount >= slot.capacity;
                bool isSelected = currentSelectedSlot == slot;

                String formattedDate;
                try {
                  DateTime parsedDate = DateTime.parse(slot.dateTime);
                  formattedDate = DateFormat('d MMMM').format(parsedDate);
                } catch (_) {
                  formattedDate = slot.dateTime.split(' ')[0]; 
                }

                return InkWell(
                  onTap: () => setState(() => _selectedSubModules[activityName] = slot),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.grey.shade500 
                          : (isFull ? Colors.grey.shade300 : const Color(0xFFB2FF59)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? Colors.grey.shade700 : Colors.transparent),
                    ),
                    child: Text(
                      formattedDate,
                      style: TextStyle(
                        color: isFull && !isSelected ? Colors.black38 : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
          
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: (currentSelectedSlot.registeredCount >= currentSelectedSlot.capacity) 
                  ? null 
                  : () async {
                      final moduleProvider = Provider.of<ModuleProvider>(context, listen: false);
                      int liveUserId = Provider.of<UserProvider>(context, listen: false).userId;

                      bool success = await moduleProvider.applyToModule(
                        moduleId: currentSelectedSlot.id!,
                        studentId: liveUserId.toString(),
                      );

                      if (!mounted) return;

                      if (success) {
                        showResultDialog(
                          context: context,
                          title: "Module added successfully!",
                          isSuccess: true,
                        );
                      } else {
                        // Shows "Already registered" or other backend error messages
                        showResultDialog(
                          context: context,
                          title: moduleProvider.errorMessage ?? "Registration failed",
                          isSuccess: false,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                elevation: 0,
              ),
              child: Text(
                currentSelectedSlot.registeredCount >= currentSelectedSlot.capacity ? "Fully Booked" : "Apply", 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label) {
    bool isSelected = selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent, 
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}