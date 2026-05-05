import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';
import '../../provider/module_provider.dart';
import '../../domain/module.dart'; 
import 'add_module.dart';

class ViewModulesPage extends StatefulWidget {
   ViewModulesPage({super.key});

  @override
  State<ViewModulesPage> createState() => _ViewModulesPageState();
}

class _ViewModulesPageState extends State<ViewModulesPage> {
  String selectedTab = 'Published';

  @override
  void initState() {
    super.initState();
    // Use microtask to fetch modules once the page initializes
    Future.microtask(() => Provider.of<ModuleProvider>(context, listen: false).fetchModules());
  }

  @override
  Widget build(BuildContext context) {
    final moduleProvider = Provider.of<ModuleProvider>(context);
    
    // Filter logic using the 'status' property from the Module object
    final filteredModules = moduleProvider.modules
        .where((m) => m.status.toLowerCase() == selectedTab.toLowerCase())
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFD5FFF7),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search module",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), 
                  borderSide: BorderSide.none
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFB9F6F0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5), 
                          borderRadius: BorderRadius.circular(30)
                        ),
                        child: Row(children: [
                          _buildTabButton("Published"), 
                          _buildTabButton("Draft")
                        ]),
                      ),
                      
                      const Spacer(flex: 1),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) =>  AddModulePage())
                            ),
                            icon: const Icon(Icons.add_circle_outline, size: 32),
                          ),
                          const Text("Add Module", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: moduleProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: filteredModules.length,
                            // Passing the Module object directly
                            itemBuilder: (context, index) => _buildModuleCard(filteredModules[index]),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Accepts 'Module' object and uses dot notation to access properties
  Widget _buildModuleCard(Module module) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 5)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(module.activityName.toUpperCase(), 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            selectedTab == 'Published' ? "Currently Open" : "Unpublished",
            style: TextStyle(
              color: selectedTab == 'Published' ? Colors.greenAccent.shade700 : Colors.red, 
              fontWeight: FontWeight.bold, 
              fontSize: 13
            ),
          ),
          const SizedBox(height: 12),
          // Correctly displaying current_registration from the database
          Text("Registration: ${module.registeredCount} / ${module.capacity} Students"),
          Text("Class Date: ${module.dateTime}"),
          Text("Venue: ${module.venue}"),
          Text("Lecturer Name: ${module.lecturerName}"),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _cardButton("Edit", const Color(0xFF8ED46C)),
              const SizedBox(width: 10),
              _cardButton("View student", const Color(0xFF1E88E5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardButton(String label, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTabButton(String label) {
    bool isSelected = selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F2F1) : Colors.transparent, 
          borderRadius: BorderRadius.circular(20)
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.black : Colors.black45, fontWeight: FontWeight.bold)),
      ),
    );
  }
}