import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/credit_provider.dart';
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
      Provider.of<CreditProvider>(context, listen: false).fetchAdminClaims('all');
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Welcome Header ──
          Text(
            "Welcome, ${widget.name}!",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),

          // ── Search Bar ──
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                suffixIcon: const Icon(Icons.search, color: Colors.black45, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Categories Label ──
          const Text(
            "Categories",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // ── Categories Grid ──
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.05,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMenuCard(
                context,
                icon: _moduleListIcon(),
                title: "Module List",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ViewModulesPage()),
                ),
              ),
              _buildMenuCard(
                context,
                icon: _creditClaimIcon(),
                title: "Credit Claim\nApplication",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminCreditStatusPage()),
                ),
              ),
              _buildMenuCard(
                context,
                icon: _moduleAttendanceIcon(),
                title: "Module Attendance",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddModuleAttendancePage()),
                ),
              ),
              _buildMenuCard(
                context,
                icon: _attendanceRecordsIcon(),
                title: "Attendance Records",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ModuleAttendanceSelectionPage()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Management Overview Label ──
          const Text(
            "Management Overview",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // ── Overview Cards Row ──
          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                // CARD 1: Live Pending Approvals
                Consumer<CreditProvider>(
                  builder: (context, creditProvider, child) {
                    final pendingCount = creditProvider.adminClaims
                        .where((claim) => claim.claimStatus.toLowerCase() == 'pending')
                        .length;
                    return _buildOverviewStatCard(
                      title: "Pending Approvals",
                      value: "$pendingCount",
                      subtext: "Students submitted\ncredit claim",
                      accentColor: Colors.red,
                    );
                  },
                ),

                // CARD 2: Capacity Alert
                _buildOverviewStatCard(
                  title: "Capacity Alert",
                  value: "95%",
                  subtext: "Memanah module is almost full.\n2 Seats remaining",
                  accentColor: Colors.blue,
                ),

                // CARD 3: Placeholder
                _buildEmptyOverviewCard(),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  MENU CARD — compact, square, white bg
  // ─────────────────────────────────────────
  Widget _buildMenuCard(
    BuildContext context, {
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 64, height: 64, child: icon),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Color(0xFF1A237E),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  OVERVIEW STAT CARD — bold large number
  // ─────────────────────────────────────────
  Widget _buildOverviewStatCard({
    required String title,
    required String value,
    required String subtext,
    required Color accentColor,
  }) {
    return Container(
      width: 155,
      margin: const EdgeInsets.only(right: 12, bottom: 4, top: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accent top bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                // Large bold number
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtext,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  EMPTY PLACEHOLDER CARD
  // ─────────────────────────────────────────
  Widget _buildEmptyOverviewCard() {
    return Container(
      width: 155,
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
        child: Icon(Icons.add_chart_outlined, color: Colors.black12, size: 28),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  ILLUSTRATED ICONS
  // ─────────────────────────────────────────
  Widget _moduleListIcon() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 50,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBDBDBD), width: 1.2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              4,
              (_) => Container(
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF9E9E9E),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF9C4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit, size: 12, color: Color(0xFFF9A825)),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, size: 12, color: Color(0xFF1565C0)),
          ),
        ),
      ],
    );
  }

  Widget _creditClaimIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 50,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFFFCE4EC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEF9A9A), width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "CLAIM",
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC62828),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _smallDot(const Color(0xFF66BB6A)),
                  const SizedBox(width: 3),
                  _smallDot(const Color(0xFFFFA726)),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFF66BB6A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 12, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _smallDot(Color color) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _moduleAttendanceIcon() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 54,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFCC80), width: 1.2),
          ),
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              Container(
                height: 9,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7043),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 3),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _calDot(const Color(0xFF66BB6A)),
                    _calDot(const Color(0xFF66BB6A)),
                    _calDot(const Color(0xFFEF5350)),
                    _calDot(const Color(0xFF66BB6A)),
                    _calDot(const Color(0xFF66BB6A)),
                    _calDot(const Color(0xFF66BB6A)),
                    _calDot(const Color(0xFFEF5350)),
                    _calDot(const Color(0xFF66BB6A)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Color(0xFF66BB6A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 11, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _calDot(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _attendanceRecordsIcon() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 50,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EAF6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF9FA8DA), width: 1.2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _checkRow(const Color(0xFF66BB6A)),
              _checkRow(const Color(0xFF66BB6A)),
              _checkRow(const Color(0xFFEF5350)),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFFFF7043),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit, size: 12, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _checkRow(Color dotColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFFBDBDBD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}