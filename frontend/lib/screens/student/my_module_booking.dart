import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/module_provider.dart';
import '../../provider/user_provider.dart';
import '../../provider/credit_provider.dart'; // 🌟 Linked new state provider
import '../../domain/module.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  final Map<int, bool> _isExpanded = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshBookings();
    });
  }

  void _refreshBookings() {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    Provider.of<ModuleProvider>(context, listen: false).fetchStudentBookings(userId.toString());
    // 🌟 Sync live data row on initialization to see if user already applied
    Provider.of<CreditProvider>(context, listen: false).fetchLiveClaimStatus(userId.toString());
  }

  // ── 🎯 MASTER CLAIM CREDIT CONTROLLER (INTEGRATED LIVE LARAVEL ROUTE) ──
  void _processFinalCreditSubmission() async {
    final moduleProvider = Provider.of<ModuleProvider>(context, listen: false);
    final bookedActivities = moduleProvider.bookedModules;

    int totalClaimedModules = bookedActivities.where((m) => m.isClaimed == 1).length;
    const int totalRequired = 4;

    // 1. Guard check: Stop if modules are insufficient
    if (totalClaimedModules < totalRequired) {
      _showErrorDialog();
      return;
    }

    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    final creditProvider = Provider.of<CreditProvider>(context, listen: false);

    // 2. Dispatch network thread payload to database
    String result = await creditProvider.submitFinalCredit(studentId: userId.toString());

    if (!mounted) return;

    if (result == "success") {
      _showSuccessDialog();
    } else if (result == "duplicate") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Submission Blocked: Claim record already exists in database!"),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to submit claim request. Check backend configurations."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── 🎯 INDIVIDUAL MODULE CLAIM PROCESSOR ──
  void _processModuleClaim(int? bookingId) async {
    if (bookingId == null || bookingId == 0) return;

    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    final moduleProvider = Provider.of<ModuleProvider>(context, listen: false);

    if (moduleProvider.bookedModules.length < 4) {
      _showErrorDialog();
      return;
    }

    bool isSuccess = await moduleProvider.claimModule(
      bookingId: bookingId,
      studentId: userId.toString(),
    );

    if (isSuccess && mounted) {
      final updatedActivities = moduleProvider.bookedModules;
      int realClaimedCount = updatedActivities.where((m) => m.isClaimed == 1).length;
      const int totalRequired = 4;

      if (realClaimedCount < totalRequired) {
        _showProgressDialog(realClaimedCount, totalRequired);
      } else {
        _showSuccessDialog();
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not sync claim state with the database. Check connection."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🔵 DIALOG 1: PROGRESS TRACKER (Pure White Variant)
  void _showProgressDialog(int claimed, int total) {
    double percentage = claimed / total;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                  ),
                ),
                Text(
                  "${(percentage * 100).toInt()}%",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF003366)),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Text(
              "$claimed/$total Required Module has been\nsubmitted",
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔴 DIALOG 2: INSUFFICIENT ERROR (Pure White Variant)
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 75),
            const SizedBox(height: 15),
            const Text(
              "Not Eligible to Claim\n(Insufficient Module)",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Back", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🟢 DIALOG 3: SUCCESS SUBMISSION (Pure White Variant)
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black87, width: 2),
              ),
              child: const Icon(Icons.done_all, color: Colors.black87, size: 45),
            ),
            const SizedBox(height: 20),
            const Text(
              "Credit Claim Successfully\nSubmitted!",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moduleProvider = Provider.of<ModuleProvider>(context);
    final creditProvider = Provider.of<CreditProvider>(context); // 🌟 Subscribed to Claim Monitor
    final bookedActivities = moduleProvider.bookedModules;

    return Scaffold(
      backgroundColor: const Color(0xFFE3EFF8),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Column(
        children: [
          const SizedBox(height: 25),
          const Text(
            "My Curriculum Booking",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF003366),
            ),
          ),
          const SizedBox(height: 15),
          
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(15, 0, 15, 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFCDE5F4),
                borderRadius: BorderRadius.circular(35),
              ),
              child: moduleProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : bookedActivities.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: bookedActivities.length,
                                itemBuilder: (context, index) {
                                  final booking = bookedActivities[index];
                                  return _buildBookingCard(index + 1, booking);
                                },
                              ),
                            ),
                            const SizedBox(height: 15),
                            // 🌟 Pass live constraint boolean into button constructor
                            _buildClaimCreditButton(creditProvider.hasClaim),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(int displayIndex, Module booking) {
    final int trackingId = booking.bookingId ?? displayIndex;
    _isExpanded.putIfAbsent(trackingId, () => false);
    bool expanded = _isExpanded[trackingId]!;

    String currentAttendance = booking.attendanceStatus ?? "-";
    
    String currentMarks = "-";
    if (booking.totalMarks != null) {
      currentMarks = booking.totalMarks! % 1 == 0 
          ? "${booking.totalMarks!.toInt()}%" 
          : "${booking.totalMarks}%";
    }
    
    bool isPresent = currentAttendance.toLowerCase() == "present";
    bool hasMarks = booking.totalMarks != null;
    bool isModuleClaimed = booking.isClaimed == 1; 

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          onExpansionChanged: (bool value) {
            setState(() {
              _isExpanded[trackingId] = value;
            });
          },
          title: Text(
            "$displayIndex. ${booking.activityName.toUpperCase()}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          trailing: Icon(
            expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: Colors.black,
            size: 28,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Class Date", booking.dateTime),
                  _buildDetailRow("Venue", booking.venue),
                  _buildDetailRow("Campus", "Pekan"), 
                  _buildDetailRow("Total Marks", currentMarks),
                  _buildAttendanceRow("Attendance", currentAttendance, isPresent),
                  const SizedBox(height: 15),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isModuleClaimed) ...[
                        const Text(
                          "Module Claimed ✓",
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ] else if (currentAttendance.toLowerCase() == "absent") ...[
                        ElevatedButton(
                          onPressed: null, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            elevation: 0,
                          ),
                          child: const Text(
                            "Claim Module",
                            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ] else if (isPresent && !hasMarks) ...[
                        _buildActionButton("Attendance Verified", const Color(0xFF007AFF), () {}),
                      ] else if (isPresent && hasMarks) ...[
                        _buildActionButton(
                          "Claim Module", 
                          const Color(0xFF00C853), 
                          () => _processModuleClaim(booking.bookingId),
                        ),
                      ] else ...[
                        _buildActionButton("Drop", Colors.red, () => _confirmDrop(booking)),
                        const SizedBox(width: 10),
                        _buildActionButton("Attendance", const Color(0xFF007AFF), () {}),
                      ],
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _confirmDrop(Module booking) async {
    if (booking.bookingId == null || booking.bookingId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Booking reference ID not found.")),
      );
      return;
    }

    bool? confirm = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 80),
            const SizedBox(height: 20),
            const Text(
              "Are you sure to remove this activity?",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 115, 
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Back", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(
                  width: 115, 
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text("Confirm", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirm == true && mounted) {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      final provider = Provider.of<ModuleProvider>(context, listen: false);

      bool success = await provider.dropModule(
        bookingId: booking.bookingId!, 
        studentId: userId.toString(),
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Module dropped successfully!"), backgroundColor: Colors.green),
        );
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 13),
          children: [
            TextSpan(text: "$label : ", style: const TextStyle(fontWeight: FontWeight.w500)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRow(String label, String value, bool isPresent) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13),
        children: [
          TextSpan(text: "$label : ", style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
          TextSpan(
            text: value,
            style: TextStyle(
              color: isPresent ? Colors.green : (value.toLowerCase() == "absent" ? Colors.red : Colors.black87), 
              fontWeight: (isPresent || value.toLowerCase() == "absent") ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: 0,
      ),
      onPressed: onTap,
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  // 🌟 UPDATED BUTTON VIEW MAPPING LAYER
  Widget _buildClaimCreditButton(bool hasAlreadyClaimed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: hasAlreadyClaimed ? Colors.grey.shade400 : const Color(0xFF00C853),
          disabledBackgroundColor: Colors.grey.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        // If claimed, set onPressed to null to completely disable user clicks
        onPressed: hasAlreadyClaimed ? null : _processFinalCreditSubmission, 
        child: Text(
          hasAlreadyClaimed ? "Credit Claimed (Pending Approval)" : "Claim Credit",
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "No booked curriculum modules found.",
        style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}