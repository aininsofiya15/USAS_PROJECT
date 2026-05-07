import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../widgets/header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/navigation_bar.dart';
import 'release_attendance.dart';

class GenerateAttendanceCode extends StatefulWidget {
  final String subjectName;
  final String sectionNo;
  final int sectionId;

  const GenerateAttendanceCode({
    super.key,
    required this.subjectName,
    required this.sectionNo,
    required this.sectionId,
  });

  @override
  State<GenerateAttendanceCode> createState() => _GenerateAttendanceCodeState();
}

class _GenerateAttendanceCodeState extends State<GenerateAttendanceCode> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();

  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3D8DA), // Consistency: Pink background
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Generate Attendance",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // The White Card (Module Form Style)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow("Subject:", widget.subjectName),
                    _buildInfoRow("Section:", widget.sectionNo.split('-').last),
                    const Divider(height: 30),

                    _buildLabel("Attendance Details"),
                    _buildInputField(
                      controller: _dateController,
                      hint: "Select Date",
                      icon: Icons.calendar_today,
                      readOnly: true,
                      onTap: _pickDate,
                    ),
                    _buildInputField(
                      controller: _timeController,
                      hint: "Select Time",
                      icon: Icons.access_time,
                      readOnly: true,
                      onTap: _pickTime,
                    ),

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel("Geo Location"),
                        TextButton.icon(
                          onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                          icon: const Icon(Icons.my_location, size: 16),
                          label: Text(_isLoadingLocation ? "Fetching..." : "Use Current"),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF3F51B5)),
                        ),
                      ],
                    ),
                    _buildInputField(
                      controller: _latController,
                      hint: "Latitude",
                      icon: Icons.location_on,
                      isNumber: true,
                    ),
                    _buildInputField(
                      controller: _longController,
                      hint: "Longitude",
                      icon: Icons.location_on,
                      isNumber: true,
                    ),
                    _buildInputField(
                      controller: _radiusController,
                      hint: "Radius (meters)",
                      icon: Icons.radar,
                      isNumber: true,
                    ),

                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007BFF),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("GENERATE CODE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Helpers (Module Form Style) ---

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
  );

  Widget _buildInfoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    bool isNumber = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.black45, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
    );
  }
  void _showSnackbar(String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating, // Optional: makes it look modern
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

  // --- Logic Methods (Date, Time, Location) ---

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _dateController.text = picked.toString().split(' ')[0]);
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _timeController.text = picked.format(context));
  }

  Future<void> _getCurrentLocation() async {
  setState(() => _isLoadingLocation = true);
  try {
    // 1. Check permissions first
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // 2. Add a TIMEOUT (This prevents the "Not Responding" error)
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 5), // If it takes > 5s, it will move to 'catch'
    );

    setState(() {
      _latController.text = position.latitude.toStringAsFixed(6);
      _longController.text = position.longitude.toStringAsFixed(6);
    });
    _showSnackbar('Location fetched!');
    
  } catch (e) {
    // If it times out or fails, use a fallback so the user isn't stuck
    _showSnackbar('Location timed out. Please enter manually or check Emulator GPS.', isError: true);
    print("Error: $e");
  } finally {
    setState(() => _isLoadingLocation = false);
  }
}

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      // Simulate API call/Logic
      Future.delayed(const Duration(seconds: 1), () {
        setState(() => _isSubmitting = false);
        
        // Randomly generated code for the student
        String generatedCode = "XJ92KL"; 

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReleaseAttendanceCodePage(
              subjectName: widget.subjectName,
              sectionNo: widget.sectionNo,
              date: _dateController.text,
              time: _timeController.text,
              code: generatedCode,
            ),
          ),
        );
      });
    }
  }
}
