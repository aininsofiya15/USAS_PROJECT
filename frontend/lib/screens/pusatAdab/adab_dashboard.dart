import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/credit_provider.dart';
import '../../provider/module_provider.dart';
import 'module_form.dart';
import 'credit_application.dart';
import 'view_module.dart';
import 'module_attendance.dart';
import 'generate_module_attendance_code.dart';
import 'attendance_for_module.dart';
import '../../widgets/header.dart';

class PusatAdabBody extends StatefulWidget {
  final String name;
  const PusatAdabBody({super.key, required this.name});

  @override
  State<PusatAdabBody> createState() => _PusatAdabBodyState();
}

class _PusatAdabBodyState extends State<PusatAdabBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CreditProvider>(context, listen: false).fetchAllClaims('all');
      Provider.of<ModuleProvider>(context, listen: false).fetchModules();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Welcome Header ──
          Text(
            "Welcome, ${widget.name}!",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),

          // ── Search Bar ──
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.74,
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  decoration: const InputDecoration(
                    hintText: "Search",
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                    suffixIcon: Icon(Icons.search, color: Colors.black45, size: 19),
                    suffixIconConstraints: BoxConstraints(minWidth: 42, minHeight: 36),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(18, 10, 0, 10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // ── Categories Label ──
          const Text(
            "Categories",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 14),

          // ── Categories Grid ──
          Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            decoration: BoxDecoration(
              color: const Color(0xFFB9F6F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.45,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMenuCard(
                  context,
                  iconPath: "assets/icons/module.png",
                  title: "Module List",
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ViewModulesPage())),
                ),
                _buildMenuCard(
                  context,
                  iconPath: "assets/icons/claim.png",
                  title: "Credit Claim\nApplication",
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AdminCreditStatusPage())),
                ),
                _buildMenuCard(
                  context,
                  iconPath: "assets/icons/moduleattendance.png",
                  title: "Module Attendance",
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AddModuleAttendancePage())),
                ),
                _buildMenuCard(
                  context,
                  iconPath: "assets/icons/attendance.png",
                  title: "Attendance Records",
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ModuleAttendanceSelectionPage())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── Management Overview Label ──
          const Text(
            "Management Overview",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 10),

          // ── Overview Cards Row ──
          SizedBox(
            height: 210,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                // Pending Approvals
                Consumer<CreditProvider>(
                  builder: (context, creditProvider, child) {
                    final pendingCount = creditProvider.adminClaims
                        .where((c) => c.claimStatus.toLowerCase() == 'pending')
                        .length;
                    return _buildOverviewStatCard(
                      title: "Pending Approvals",
                      value: "$pendingCount",
                      subtext: "Students submitted\ncredit claim",
                      accentColor: Colors.red,
                    );
                  },
                ),

                // Capacity Alert — dynamic from most-filled module
                Consumer<ModuleProvider>(
                  builder: (context, moduleProvider, child) {
                    final published = moduleProvider.modules
                        .where((m) =>
                            m.status.toLowerCase() == 'published' &&
                            m.capacity > 0)
                        .toList();

                    if (published.isEmpty) {
                      return _buildOverviewStatCard(
                        title: "Capacity Alert",
                        value: "–",
                        subtext: "No published\nmodules yet.",
                        accentColor: Colors.blue,
                      );
                    }

                    // Sort by fill ratio descending
                    published.sort((a, b) =>
                        (b.registeredCount / b.capacity)
                            .compareTo(a.registeredCount / a.capacity));

                    final top = published.first;
                    final percent =
                        ((top.registeredCount / top.capacity) * 100).round();
                    final remaining = top.capacity - top.registeredCount;

                    return _buildOverviewStatCard(
                      title: "Capacity Alert",
                      value: "$percent%",
                      subtext:
                          "${top.activityName} is almost full.\n$remaining seat${remaining == 1 ? '' : 's'} remaining",
                      accentColor: Colors.blue,
                    );
                  },
                ),

                _buildEmptyOverviewCard(),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Menu Card ──
  Widget _buildMenuCard(
    BuildContext context, {
    required String iconPath,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 70,
              height: 70,
              errorBuilder: (_, error, ___) {
                debugPrint('Failed to load icon: $iconPath — $error');
                return const Icon(Icons.apps, size: 40, color: Color(0xFF3F51B5));
              },
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: Color.fromARGB(255, 17, 84, 160),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Overview Stat Card ──
  Widget _buildOverviewStatCard({
    required String title,
    required String value,
    required String subtext,
    required Color accentColor,
  }) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12, bottom: 4, top: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 66,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtext,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty Placeholder Card ──
  Widget _buildEmptyOverviewCard() {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12, bottom: 4, top: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.add_chart_outlined, color: Colors.black12, size: 32),
      ),
    );
  }
}