import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/manage_fees_provider.dart';
import 'stud_tuition_overview.dart';
import 'auto_block_config.dart';
import '../../provider/user_provider.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';

class FeesManagementPage extends StatefulWidget {
  const FeesManagementPage({super.key});

  @override
  State<FeesManagementPage> createState() => _FeesManagementPageState();
}

class _FeesManagementPageState extends State<FeesManagementPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeesManagementProvider>(context, listen: false)
          .fetchStudentsFeeStatus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchStudents() {
    Provider.of<FeesManagementProvider>(context, listen: false)
        .searchStudents(_searchController.text);
  }

  // --- HELPER: PAGE ARROWS ---
  Widget _buildPageArrow(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        icon,
        size: 18,
        color: onTap == null ? Colors.grey.shade300 : Colors.blue,
      ),
    );
  }

  // --- HELPER: PAGE NUMBERS ---
  List<Widget> _buildPageNumbers(FeesManagementProvider provider) {
    List<Widget> numbers = [];
    for (int i = 1; i <= provider.totalPages; i++) {
      // Logic to show current, first, last, and neighboring pages
      if (i == 1 ||
          i == provider.totalPages ||
          (i >= provider.currentPage - 1 && i <= provider.currentPage + 1)) {
        numbers.add(
          InkWell(
            onTap: () => provider.goToPage(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                "$i",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: provider.currentPage == i
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: provider.currentPage == i ? Colors.blue : Colors.black,
                ),
              ),
            ),
          ),
        );
      } else if (i == provider.currentPage - 2 || i == provider.currentPage + 2) {
        numbers.add(const Text("...", style: TextStyle(fontSize: 12)));
      }
    }
    return numbers;
  }

  // --- STUDENT ROW ---
  Widget _buildStudentRow(StudentFeeStatus student) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(student.matricId, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            flex: 4,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StudentTuitionOverviewPage(userId: student.userId),
                  ),
                );
              },
              child: Text(
                student.name,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text("RM ${student.outstandingAmount.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            flex: 3,
            child: _buildStatusOval(student.status),
          ),
          Expanded(
            flex: 2,
            child: Icon(
              student.isBlocked ? Icons.block : Icons.do_not_disturb_on_outlined,
              color: student.isBlocked ? Colors.red : Colors.grey,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOval(String status) {
    bool isPaid = status.toLowerCase() == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Consumer<FeesManagementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.students.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(provider),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          "Student Fee Status",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: const Icon(Icons.filter_list),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _searchStudents(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: const [
                            Expanded(
                                flex: 3,
                                child: Text("Matric ID",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12))),
                            Expanded(
                                flex: 4,
                                child: Text("Name",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12))),
                            Expanded(
                                flex: 3,
                                child: Text("Outstanding",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12))),
                            Expanded(
                                flex: 3,
                                child: Text("Status",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12))),
                            Expanded(
                                flex: 2,
                                child: Text("Actions",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12))),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      provider.students.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: Text("No students found")),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              // The provider.students list will now only contain 10 items because of the API change
                              itemCount: provider.students.length, 
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                return _buildStudentRow(provider.students[index]);
                              },
                            ),

                      // --- PAGINATION ROW ---
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Showing ${provider.students.length} of ${provider.totalStudents} students",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            Row(
                              children: [
                                const Text("[ ",
                                    style: TextStyle(color: Colors.grey)),
                                _buildPageArrow(
                                    Icons.chevron_left,
                                    provider.currentPage > 1
                                        ? () => provider.goToPage(
                                            provider.currentPage - 1)
                                        : null),
                                ..._buildPageNumbers(provider),
                                _buildPageArrow(
                                    Icons.chevron_right,
                                    provider.currentPage < provider.totalPages
                                        ? () => provider.goToPage(
                                            provider.currentPage + 1)
                                        : null),
                                const Text(" ]",
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(FeesManagementProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Current Status",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("Paid", provider.summary['paid'].toString(),
                    Colors.green),
                _buildStatItem("Unpaid", provider.summary['unpaid'].toString(),
                    Colors.red),
                _buildStatItem("Blocked", provider.summary['blocked'].toString(),
                    Colors.black),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AutoBlockConfigPage()));
                },
                child: const Text("Block Settings",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}