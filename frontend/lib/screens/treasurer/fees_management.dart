import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/manage_fees_provider.dart';
import '../../widgets/stud_list_card.dart';
import '../../widgets/filter_chip_row.dart';
import 'stud_tuition_overview.dart';

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
      appBar: AppBar(
        title: const Text('Tuition Fees'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or matric...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchStudents();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _searchStudents(),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          Consumer<FeesManagementProvider>(
            builder: (context, provider, child) {
              return FilterChipRow(
                currentFilter: provider.currentFilter,
                onFilterChanged: (filter) {
                  provider.setFilter(filter);
                },
              );
            },
          ),
          // Student List
          Expanded(
            child: Consumer<FeesManagementProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.students.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(provider.errorMessage),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.fetchStudentsFeeStatus(refresh: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No students found',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: provider.students.length + (provider.isLoadMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.students.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final student = provider.students[index];
                    return StudentListCard(
                      student: student,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentFeeDetailPage(
                              studentId: student.studentId,
                              studentName: student.name,
                            ),
                          ),
                        ).then((_) => provider.fetchStudentsFeeStatus(refresh: true));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}