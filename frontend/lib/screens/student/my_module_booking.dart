import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/module_provider.dart';
import '../../provider/user_provider.dart';
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
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      Provider.of<ModuleProvider>(context, listen: false).fetchStudentBookings(userId.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final moduleProvider = Provider.of<ModuleProvider>(context);
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
                            _buildClaimCreditButton(),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(int displayIndex, Module booking) {
    _isExpanded.putIfAbsent(booking.id ?? displayIndex, () => false);
    bool expanded = _isExpanded[booking.id ?? displayIndex]!;

    String currentAttendance = booking.attendance ?? "-";
    String currentMarks = booking.total_marks ?? "-";
    
    bool isPresent = currentAttendance.toLowerCase() == "present";
    bool hasMarks = currentMarks != "-" && currentMarks.trim().isNotEmpty;
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
              _isExpanded[booking.id ?? displayIndex] = value;
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
                          "Module Claimed",
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ] else if (isPresent && hasMarks) ...[
                        _buildActionButton("Claim Module", const Color(0xFF00C853), () {}),
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
    bool? confirm = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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
                // Back Button
                SizedBox(
                  width: 115, // Increased width to prevent text wrap
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
                // Confirm Button
                SizedBox(
                  width: 115, // Increased width to prevent text wrap
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

    if (confirm == true && booking.id != null) {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      final provider = Provider.of<ModuleProvider>(context, listen: false);

      bool success = await provider.dropModule(
        bookingId: booking.id!, 
        studentId: userId.toString(),
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Module dropped successfully!")),
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
              color: isPresent ? Colors.green : Colors.black87, 
              fontWeight: isPresent ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildClaimCreditButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C853),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        onPressed: () {},
        child: const Text(
          "Claim Credit",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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