import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/credit_provider.dart';
import '../../domain/credit.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';

class AdminCreditStatusPage extends StatefulWidget {
  const AdminCreditStatusPage({super.key});

  @override
  State<AdminCreditStatusPage> createState() => _AdminCreditStatusPageState();
}

class _AdminCreditStatusPageState extends State<AdminCreditStatusPage> {
  String _activeTab = 'all';
  // Tracks which claim IDs are currently expanded (supports multiple open)
  final Set<int> _expandedClaimIds = {};
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CreditProvider>(context, listen: false)
          .fetchAdminClaims(_activeTab);
    });
  }

  /// Status text color — matches Figma exactly
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF43A047); // Green
      case 'rejected':
        return const Color(0xFFE53935); // Red
      case 'pending':
      default:
        return const Color(0xFFFF9800); // Amber/Orange
    }
  }

  @override
  Widget build(BuildContext context) {
    final creditProvider = Provider.of<CreditProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFD1FFF3),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: BoxDecoration(
            color: const Color(0xFFB9F6F0),
            borderRadius: BorderRadius.circular(34),
          ),
          child: Column(
            children: [

          // ── PAGE TITLE ──
          const Text(
            'Credit Claim Application',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 16),

          // ── TOGGLE PILL TABS ──
          _buildToggleTabs(),
          const SizedBox(height: 16),

          // ── CLAIMS LIST ──
          Expanded(
            child: creditProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF004D73)),
                  )
                : creditProvider.adminClaims.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: creditProvider.adminClaims.length,
                        itemBuilder: (context, index) {
                          final claim = creditProvider.adminClaims[index];
                          return _buildApplicationCard(
                            claim,
                            index + 1,
                            creditProvider,
                          );
                        },
                      ),
          ),

          // ── PAGINATION ──
          _buildPaginationFooter(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  TOGGLE TABS
  // ─────────────────────────────────────────
  Widget _buildToggleTabs() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFCFE2F3),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabButton('all', 'All'),
          _buildTabButton('pending', 'Pending'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String filterType, String label) {
    final isSelected = _activeTab == filterType;
    final isPending = filterType == 'pending';

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = filterType;
          _expandedClaimIds.clear();
        });
        _fetchData();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? (isPending ? const Color(0xFFE53935) : Colors.black87)
                : Colors.black54,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  APPLICATION CARD
  // ─────────────────────────────────────────
  Widget _buildApplicationCard(
    AdminCreditClaim claim,
    int displayIndex,
    CreditProvider provider,
  ) {
    final isExpanded = _expandedClaimIds.contains(claim.claimId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ROW (tap to expand/collapse) ──
            InkWell(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedClaimIds.remove(claim.claimId);
                  } else {
                    _expandedClaimIds.add(claim.claimId);
                  }
                });
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$displayIndex. ${claim.studentName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.black54,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),

            // ── EXPANDABLE DETAILS ──
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpandedContent(claim, provider),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 220),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(
    AdminCreditClaim claim,
    CreditProvider provider,
  ) {
    final statusLabel =
        claim.claimStatus.substring(0, 1).toUpperCase() +
        claim.claimStatus.substring(1).toLowerCase();

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Matric ID ──
          Text(
            'Matric ID: ${claim.matricId}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),

          // ── Completed Modules: label + list side by side ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Completed Module: ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: claim.completedModules.asMap().entries.map((entry) {
                    return Text(
                      '${entry.key + 1}. ${entry.value}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black87),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Status ──
          Row(
            children: [
              const Text(
                'Status: ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _getStatusColor(claim.claimStatus),
                ),
              ),
            ],
          ),

          // ── Action Buttons (pending only) ──
          if (claim.claimStatus.toLowerCase() == 'pending') ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ── REJECT — red pill ──
                ElevatedButton(
                  onPressed: () =>
                      provider.rejectStudentApplication(claim.claimId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // full pill
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    minimumSize: const Size(0, 38),
                  ),
                  child: const Text(
                    'Reject Application',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                // ── APPROVE — green pill ──
                ElevatedButton(
                  onPressed: () =>
                      provider.approveStudentApplication(claim.claimId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43A047), // green
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // full pill
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    minimumSize: const Size(0, 38),
                  ),
                  child: const Text(
                    'Approve Credit',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  PAGINATION FOOTER
  // ─────────────────────────────────────────
  Widget _buildPaginationFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFCFE2F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [1, 2, 3].map((page) {
          final isActive = page == _currentPage;
          return GestureDetector(
            onTap: () {
              setState(() => _currentPage = page);
              // TODO: implement page-based data fetch
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 28,
              height: 28,
              decoration: isActive
                  ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    )
                  : null,
              alignment: Alignment.center,
              child: Text(
                '$page',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.black87 : Colors.black45,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  EMPTY STATE
  // ─────────────────────────────────────────
  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No claims found for this filter.',
        style: TextStyle(
          color: Colors.black45,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
