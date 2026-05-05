import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';
import '../../provider/module_provider.dart';
import '../../domain/module.dart';

class StudentActivitiesPage extends StatefulWidget {
  const StudentActivitiesPage({super.key});

  @override
  State<StudentActivitiesPage> createState() => _StudentActivitiesPageState();
}

class _StudentActivitiesPageState extends State<StudentActivitiesPage> {
  String selectedTab = 'All'; // Filter toggle state: All vs Available
  
  // Track selected date slot per activity group
  final Map<String, Module> _selectedSubModules = {};

  // Track expansion state for each unique activity name
  final Map<String, bool> _isExpanded = {};

  @override
  void initState() {
    super.initState();
    // Fetch fresh module data created by Pusat ADAB staff from MySQL database
    Future.microtask(() => Provider.of<ModuleProvider>(context, listen: false).fetchModules());
  }

  @override
  Widget build(BuildContext context) {
    final moduleProvider = Provider.of<ModuleProvider>(context);

    // 1. Filter: Students should only see 'Published' items
    List<Module> filteredRawModules = moduleProvider.modules
        .where((m) => m.status.toLowerCase() == 'published')
        .toList();

    // 2. Secondary Filter: If 'Available' is clicked, hide fully booked items
    if (selectedTab == 'Available') {
      filteredRawModules = filteredRawModules
          .where((m) => m.registeredCount < m.capacity)
          .toList();
    }

    // 3. Grouping Array: Collapse rows matching the same activity name
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
          // Filter Switch Panel (All vs Available)
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
          // Outer List Container Panel
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 15), // Added bottom margin to prevent clipping
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 206, 229, 244), 
                // FIXED: Gives the overall panel perfectly rounded corners on ALL sides
                borderRadius: BorderRadius.circular(40), 
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: const Offset(0, -2),
                  )
                ]
              ),
              child: moduleProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ClipRRect(
                      // Clip the list view area so cards don't bleed past the rounded panel edges
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
    // Put default values if this is the first time rendering the activity card row
    _isExpanded.putIfAbsent(activityName, () => false);
    if (!_selectedSubModules.containsKey(activityName) && slots.isNotEmpty) {
      _selectedSubModules[activityName] = slots.first;
    }

    final currentSelectedSlot = _selectedSubModules[activityName]!;
    bool expanded = _isExpanded[activityName]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FDFF), // Light blue tint matching mockup
        // FIXED: Explicitly rounds all 4 corners of individual modules cards
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
          // Clickable Title Row Header
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded[activityName] = !expanded; // Toggle open state
              });
            },
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
                Icon(
                  expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down, 
                  size: 28, 
                  color: Colors.blue.shade700,
                ),
              ],
            ),
          ),
          const Text("Currently Open", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 12),
          
          // Information Fields Section (Bound dynamically to selected sub-slot chip below)
          _buildInfoRow(Icons.people, "Registration: ${currentSelectedSlot.registeredCount} / ${currentSelectedSlot.capacity} Students"),
          _buildInfoRow(Icons.access_time, "Class Time: ${currentSelectedSlot.dateTime}"),
          _buildInfoRow(Icons.location_on, "Venue: ${currentSelectedSlot.venue}"),
          _buildInfoRow(Icons.person, "Lecturer: ${currentSelectedSlot.lecturerName}"),
          
          // Expandable Child Grid Array (Only builds when expanded variable is true)
          if (expanded) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            const SizedBox(height: 15),
            const Text("Available Slots:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue)),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: slots.map((slot) {
                bool isFull = slot.registeredCount >= slot.capacity;
                bool isSelected = currentSelectedSlot == slot;

                // Format "2026-05-29 08:00:00" to readable "29 May"
                String formattedDate;
                try {
                  DateTime parsedDate = DateTime.parse(slot.dateTime);
                  formattedDate = DateFormat('d MMMM').format(parsedDate);
                } catch (_) {
                  formattedDate = slot.dateTime.split(' ')[0]; // Fallback string split
                }

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedSubModules[activityName] = slot;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.blue.shade400 
                          : (isFull ? Colors.grey.shade300 : const Color(0xFFB2FF59)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.blue.shade700 : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      formattedDate,
                      style: TextStyle(
                        color: isFull && !isSelected ? Colors.black38 : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          
          const SizedBox(height: 15),
          // Action Execution Line
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: (currentSelectedSlot.registeredCount >= currentSelectedSlot.capacity) 
                  ? null 
                  : () {
                      // Connection target slot logic point
                      print("Applying for module database row ID: ${currentSelectedSlot.activityName}");
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
            child: Text(
              text, 
              style: const TextStyle(
                fontSize: 13,  
                color: Colors.blue,
              ),
            ),
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
          color: isSelected ? const Color.fromARGB(255, 255, 255, 255) : Colors.transparent, 
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}