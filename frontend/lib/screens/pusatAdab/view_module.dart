import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';
import '../../provider/module_provider.dart';
import '../../domain/module.dart'; 
import 'module_form.dart'; 
import 'module_student_list.dart';

class ViewModulesPage extends StatefulWidget {
   const ViewModulesPage({super.key});

  @override
  State<ViewModulesPage> createState() => _ViewModulesPageState();
}

class _ViewModulesPageState extends State<ViewModulesPage> {
  String selectedTab = 'Published';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    Future.microtask(() => Provider.of<ModuleProvider>(context, listen: false).fetchModules());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moduleProvider = Provider.of<ModuleProvider>(context);
    
    final filteredModules = moduleProvider.modules.where((m) {
      bool matchesTab = m.status.toLowerCase() == selectedTab.toLowerCase();
      bool matchesSearch = m.activityName.toLowerCase().contains(_searchQuery);
      return matchesTab && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFD5FFF7),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Column(
        children: [
          const SizedBox(height: 15),
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.88,
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  decoration: const InputDecoration(
                    hintText: "Search module",
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                    suffixIcon: Icon(Icons.search, color: Colors.black87, size: 22),
                    suffixIconConstraints: BoxConstraints(minWidth: 44, minHeight: 36),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(24, 10, 0, 10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
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
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) =>  ModuleFormPage())
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black87, width: 3),
                              ),
                              child: const Icon(Icons.add, color: Colors.black87, size: 22),
                            ),
                            const SizedBox(height: 4),
                            const Text("Add Module", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: moduleProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredModules.isEmpty
                            ? const Center(child: Text("No modules found", style: TextStyle(color: Colors.black45)))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: filteredModules.length,
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

  Widget _buildModuleCard(Module module) {
    bool isDraft = selectedTab == 'Draft';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25), 
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            module.activityName.toUpperCase(), 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)
          ),
          const SizedBox(height: 4),
          Text(
            isDraft ? "Unpublished" : "Currently Open",
            style: TextStyle(color: isDraft ? Colors.redAccent : Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Text("Registration: ${isDraft ? '-' : '${module.registeredCount} / ${module.capacity} Students'}", style: const TextStyle(fontSize: 13, color: Colors.black54)),
          Text("Class Date: ${module.dateTime}", style: const TextStyle(fontSize: 13, color: Colors.black54)),
          Text("Venue: ${module.venue.isEmpty ? '-' : module.venue}", style: const TextStyle(fontSize: 13, color: Colors.black54)),
          Text("Lecturer Name: ${module.lecturerName.isEmpty ? '-' : module.lecturerName}", style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ModuleFormPage(existingModuleData: module),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDraft ? const Color(0xFF2196F3) : const Color(0xFF8BC34A),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  elevation: 0,
                ),
                child: Text(isDraft ? "Continue Edit →" : "Edit", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              if (!isDraft) ...[
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentListPage(module: module),
                      ),
                    );
                    if (context.mounted) {
                      context.read<ModuleProvider>().fetchModules();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    elevation: 0,
                  ),
                  child: const Text("View student", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
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
