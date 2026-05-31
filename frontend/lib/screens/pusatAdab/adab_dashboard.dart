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
  @override
  void initState() {
    super.initState();
    // Pre-fetch admin claims database metrics automatically when dashboard mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CreditProvider>(context, listen: false).fetchAdminClaims('all');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Welcome Header ──
          Text(
            "Welcome, ${widget.name}!",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 22),

          // ── Categories Label ──
          const Text(
            "Categories",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // ── Categories Grid ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFB8FFF2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.92, 
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
                  title: "Module Attendance\nRecords",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ModuleAttendanceSelectionPage()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Management Overview Label ──
          const Text(
            "Management Overview",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // ── Overview Cards Row (🎯 Added Third Empty Card) ──
          SizedBox(
            height: 195, 
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                // CARD 1: Live Pending Approvals Counter Connected to Provider
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
                
                // CARD 2: Capacity Alert Module
                _buildOverviewStatCard(
                  title: "Capacity Alert",
                  value: "95%",
                  subtext: "Memanah module is almost full.\n2 Seats remaining",
                  accentColor: Colors.blue,
                ),

                // 🎯 CARD 3: Clean Empty Placeholder Box
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
  //  MENU CARD
  // ─────────────────────────────────────────
  Widget _buildMenuCard(
    BuildContext context, {
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 70, height: 70, child: icon),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF1A237E),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  📦 OVERVIEW CARD BUILDER
  // ─────────────────────────────────────────
  Widget _buildOverviewStatCard({
    required String title,
    required String value,
    required String subtext,
    required Color accentColor,
  }) {
    return Container(
      width: 160, 
      margin: const EdgeInsets.only(right: 14, bottom: 8, top: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
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
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 46, 
                    fontWeight: FontWeight.w800, 
                    color: accentColor, 
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtext,
                  style: const TextStyle(
                    fontSize: 10, 
                    color: Colors.black54, 
                    fontWeight: FontWeight.w500, 
                    height: 1.2,
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
  //  📦 EMPTY PLACEHOLDER CARD BUILDER
  // ─────────────────────────────────────────
  Widget _buildEmptyOverviewCard() {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 14, bottom: 8, top: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      // Left explicitly clean and unpopulated for your future metric expansion elements
      child: const Center(
        child: Icon(
          Icons.add_chart_outlined, 
          color: Colors.black12, 
          size: 28,
        ),
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
          width: 52,
          height: 60,
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
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF9C4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit, size: 13, color: Color(0xFFF9A825)),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, size: 13, color: Color(0xFF1565C0)),
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
          width: 52,
          height: 60,
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
                  fontSize: 9,
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
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFF66BB6A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 13, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _smallDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _moduleAttendanceIcon() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 56,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFCC80), width: 1.2),
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7043),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 4),
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

  Widget _calDot(Color color) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
    );
  }

  Widget _attendanceRecordsIcon() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 52,
          height: 60,
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
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFFFF7043),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit, size: 13, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _checkRow(Color dotColor) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Container(
            height: 3.5,
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