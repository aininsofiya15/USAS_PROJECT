import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../widgets/header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/navigation_bar.dart';
import '../../provider/attendance_provider.dart';
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

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }

  // --- Logic: Fetch Location ---
  Future<void> _handleLocationFetch() async {
    setState(() => _isLoadingLocationInside = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      setState(() {
        _latController.text = position.latitude.toStringAsFixed(6);
        _longController.text = position.longitude.toStringAsFixed(6);
      });
      _showSnackbar("Location fetched successfully!");
    } catch (e) {
      _showSnackbar("Location timeout. Enter manually or check Emulator GPS.", isError: true);
    } finally {
      setState(() => _isLoadingLocationInside = false);
    }
  }

  bool _isLoadingLocationInside = false;

  // --- Logic: Submit to Provider ---
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AttendanceProvider>(context, listen: false);

      final String? generatedCode = await provider.generateAttendance(
        sectionId: widget.sectionId,
        lat: double.parse(_latController.text),
        lng: double.parse(_longController.text),
        date: _dateController.text,
        time: _timeController.text,
      );

      if (generatedCode != null && mounted) {
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
      } else {
        _showSnackbar("Failed to generate code. Check server connection.", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3D8DA),
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
                    _buildInfoRow("Radius:", "500m (Fixed)"),
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
                          onPressed: _isLoadingLocationInside ? null : _handleLocationFetch,
                          icon: _isLoadingLocationInside 
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.my_location, size: 16),
                          label: Text(_isLoadingLocationInside ? "Fetching..." : "Use Current"),
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

                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: Consumer<AttendanceProvider>(
                        builder: (context, provider, _) => ElevatedButton(
                          onPressed: provider.isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007BFF),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 20, 
                                  width: 20, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                )
                              : const Text("GENERATE CODE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
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

  // --- UI Helper Methods ---

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

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

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
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
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
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
}