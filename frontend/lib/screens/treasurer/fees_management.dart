import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/manage_fees_provider.dart';
import '../../widgets/stud_list_card.dart';
import '../../widgets/filter_chip_row.dart';
import 'stud_tuition_overview.dart';
import 'auto_block_config.dart';

class FeesManagementPage extends StatefulWidget {
  const FeesManagementPage({Key? key}) : super(key: key);

  @override
  State<FeesManagementPage> createState() => _FeesManagementPageState();
}

class _FeesManagementPageState extends State<FeesManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeesManagementProvider>(context, listen: false)
          .fetchStudentsFeeStatus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      Provider.of<FeesManagementProvider>(context, listen: false)
          .loadMore();
    }
  }

  void _searchStudents() {
    Provider.of<FeesManagementProvider>(context, listen: false)
        .searchStudents(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), 
      appBar: AppBar(
        title: const Text('Tuition Fees'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blue.shade700,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or matric...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                // FIX: If BorderRadius still shows red, ensure you are using 'const' 
                // and that the closing parentheses are correct.
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _searchStudents(),
            ),
          ),

          Expanded(
            child: Consumer<FeesManagementProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.students.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(provider),
                      
                      const SizedBox(height: 20),
                      const Text(
                        "Student Fee Status",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.students.length,
                          itemBuilder: (context, index) {
                            final student = provider.students[index];
                            // FIX: Added the missing 'onTap' parameter required by StudentListCard
                            return StudentListCard(
                              student: student,
                              onTap: () {
                                // Add your navigation or logic here
                                print("Tapped on ${student.name}");
                              },
                            );
                          },
                        ),
                      ),
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

  Widget _buildSummaryCard(FeesManagementProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Current Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("Paid", provider.summary['paid'].toString(), Colors.green),
                _buildStatItem("Unpaid", provider.summary['unpaid'].toString(), Colors.red),
                _buildStatItem("Blocked", provider.summary['blocked'].toString(), Colors.black),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const AutoBlockConfigPage()));
              },
              child: const Text("Block Settings", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}