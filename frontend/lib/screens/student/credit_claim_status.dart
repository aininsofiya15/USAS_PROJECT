import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/credit_provider.dart';
import '../../provider/user_provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';

class CreditClaimStatusPage extends StatefulWidget {
  const CreditClaimStatusPage({super.key});

  @override
  State<CreditClaimStatusPage> createState() => _CreditClaimStatusPageState();
}

class _CreditClaimStatusPageState extends State<CreditClaimStatusPage> {
  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  // 🔄 Automated Refresh Pipeline Execution Context
  Future<void> _refreshStatus() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      Provider.of<CreditProvider>(context, listen: false)
          .fetchLiveClaimStatus(userId.toString());
    });
  }

  Color _getBadgeColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF4CAF50); // Deep premium green
      case 'rejected':
        return const Color(0xFFE53935); // Sharp ruby red
      case 'pending':
      default:
        return const Color(0xFFFF1744); // High contrast vibrant red
    }
  }

  String _getActionMessage(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Wait for Pusat Adab Approval';
      case 'approved':
        return 'Credit successfully applied to your profile transcript.';
      case 'rejected':
        return 'Claim rejected. Please contact Pusat Adab.';
      default:
        return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final creditProvider = Provider.of<CreditProvider>(context);
    final claim = creditProvider.activeClaim;

    return Scaffold(
      backgroundColor: const Color(0xFFE3EFF8),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      // 🎯 INTERACTIVE LAYER 1: Pull-to-Refresh Gesture Recognition
      body: RefreshIndicator(
        onRefresh: _refreshStatus,
        color: const Color(0xFF004D73),
        backgroundColor: Colors.white,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(), // Ensures swipe gesture always registers
          children: [
            const SizedBox(height: 30),
            const Center(
              child: Text(
                "Credit Claim Status",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002233),
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 25),
            
            // Dynamic State Resolver Tree Branch
            creditProvider.isLoading
                ? _buildShimmerSkeletonLoader() // 🎯 INTERACTIVE LAYER 2
                : !creditProvider.hasClaim || claim == null
                    ? _buildNoClaimFallback() // 🎯 INTERACTIVE LAYER 3
                    : _buildStatusCard(claim),
          ],
        ),
      ),
    );
  }

  // ── 🎯 RENDER: ACTIVE DATA CARD LAYER ──
  Widget _buildStatusCard(dynamic claim) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoLine("Subject Code", claim.subjectCode),
            const Divider(height: 24, color: Color(0xFFECEFF1)),
            _buildInfoLine("Subject Name", claim.subjectName),
            const Divider(height: 24, color: Color(0xFFECEFF1)),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Status: ",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(width: 8),
                // Smooth scaling status pill badge layout shell
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getBadgeColor(claim.status),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    claim.status.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
            
            const Divider(height: 24, color: Color(0xFFECEFF1)),
            _buildInfoLine("Action", _getActionMessage(claim.status)),
          ],
        ),
      ),
    );
  }

  // ── 🎯 INTERACTIVE LAYER 2: SHIMMER SKELETON FEEDBACK ──
  Widget _buildShimmerSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 140, height: 16, color: Colors.grey[200]),
            const SizedBox(height: 24),
            Container(width: 220, height: 16, color: Colors.grey[200]),
            const SizedBox(height: 24),
            Container(width: 90, height: 24, color: Colors.grey[200]),
          ],
        ),
      ),
    );
  }

  // ── 🎯 INTERACTIVE LAYER 3: CLEAN INTERACTIVE EMPTY ACTION FALLBACK ──
  Widget _buildNoClaimFallback() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
        child: Column(
          children: [
            Icon(Icons.assignment_late_outlined, size: 64, color: Colors.blueGrey[300]),
            const SizedBox(height: 16),
            const Text(
              "No Active Claims Found",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF002233)),
            ),
            const SizedBox(height: 8),
            const Text(
              "You haven't submitted any credit hour claims for your Co-Curriculum subject yet. Swipe down to refresh if you recently submitted.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoLine(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black, height: 1.4),
        children: [
          TextSpan(text: "$label\n", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey[400], height: 1.8)),
          TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }
}