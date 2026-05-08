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
  // Track open/collapsed state for each list item row card
  final Map<int, bool> _isExpanded = {};

  @override
  void initState() {
    super.initState();
    // Fetch live dashboard rows from MySQL using the authenticated session ID
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

    // Extract dynamic string properties from database
    String currentAttendance = booking.attendance ?? "-";
    String currentMarks = booking.total_marks ?? "-";
    
    // Evaluate logic boundaries for responsive layout switches
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
          // 🔥 COLLAPSED FIX: Set to false so the accordion panels load closed initially
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
                        _buildActionButton("Claim Module", const Color(0xFF00C853), () {
                          // Action trigger for single module claim operation
                        }),
                      ] else ...[
                        _buildActionButton("Drop", Colors.red, () async {
                          final provider = Provider.of<ModuleProvider>(context, listen: false);
                          final user = Provider.of<UserProvider>(context, listen: false);

                          if (booking.id != null) {
                            bool success = await provider.dropModule(
                              bookingId: booking.id!, 
                              studentId: user.userId.toString(),
                            );
                            
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Module dropped successfully!")),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Failed to drop module."), backgroundColor: Colors.red),
                              );
                            }
                          }
                        }),
                        const SizedBox(width: 10),
                        _buildActionButton("Attendance", const Color(0xFF007AFF), () {
                          // Trigger QR camera scan screen route execution
                        }),
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
        onPressed: () {
          // Final 8-hour total requirement processing path block
        },
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