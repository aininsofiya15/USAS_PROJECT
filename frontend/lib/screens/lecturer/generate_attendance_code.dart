import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../widgets/header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/navigation_bar.dart';
import '../../provider/attendance_provider.dart';
import 'release_attendance.dart';
import 'lecturer_dashboard.dart';

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
  String? _selectedLab;
  
  // Coordinates variables
  double? _currentLat;
  double? _currentLong;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AttendanceProvider>(context, listen: false)
          .fetchLabsForSection(widget.sectionId);
    });
  }

  // --- LOGIC: Fetch Current GPS (Accurate & Forced Update) ---
  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enable device Location services/GPS toggle!"), backgroundColor: Colors.orange),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied, cannot request permissions.';
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best, 
          forceAndroidLocationManager: true,       
          timeLimit: const Duration(seconds: 12),  
        );

        if (mounted) {
          setState(() {
            _currentLat = position.latitude;
            _currentLong = position.longitude;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Highly accurate location captured!"), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      debugPrint("Location error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed getting location accuracy: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
    }
  }

  // --- FORM SUBMISSION HANDLING WITH DUPLICATE CHECK MANAGEMENT ---
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_currentLat == null || _currentLong == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fetch your location first!"), backgroundColor: Colors.red),
        );
        return;
      }

      // 1. Show loading overlay while checking backend validation rules
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final provider = Provider.of<AttendanceProvider>(context, listen: false);

      final String? responseCode = await provider.generateAttendance(
        sectionId: widget.sectionId,
        labName: _selectedLab,
        lat: _currentLat!, 
        lng: _currentLong!, 
        date: _dateController.text,
        time: _timeController.text,
      );

      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading overlay spinner

      // 2. INTERCEPT DUPLICATE: Show warning modal instantly on this page!
      if (responseCode == "DUPLICATE") {
        _showDuplicateWarningDialog(context);
      } 
      
      // 3. SUCCESS: Proceed to release page only if code is unique
      else if (responseCode != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReleaseAttendanceCodePage(
              subjectName: widget.subjectName,
              sectionNo: widget.sectionNo,
              date: _dateController.text,
              time: _timeController.text,
              code: responseCode,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to process transaction. Please try again."), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showDuplicateWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 15),
                const Text(
                  "An attendance code for this class session has already been released.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Return to the first route in the stack, typically the dashboard
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Back to Dashboard",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
        child: Column(
          children: [
            const Text("Attendance", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow("Subject:", widget.subjectName),
                    _buildInfoRow("Section:", widget.sectionNo),
                    
                    const SizedBox(height: 20),
                    _buildLabel("Lecture/Lab:"),
                    _buildLabDropdown(),

                    _buildLabel("Date:"),
                    _buildInputField(controller: _dateController, hint: "Select Date", icon: Icons.calendar_month, onTap: _pickDate),

                    _buildLabel("Time:"),
                    _buildInputField(controller: _timeController, hint: "Select Time", icon: Icons.access_time, onTap: _pickTime),

                    // --- GEOLOCATION SECTION ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel("Geolocation:"),
                        TextButton.icon(
                          onPressed: _isFetchingLocation ? null : _getCurrentLocation,
                          icon: _isFetchingLocation 
                            ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.my_location, size: 18),
                          label: Text(_isFetchingLocation ? "Fetching..." : "Get Location"),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF3F51B5)),
                        ),
                      ],
                    ),
                    
                    if (_currentLat != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          "Captured: ${_currentLat!.toStringAsFixed(5)}, ${_currentLong!.toStringAsFixed(5)}",
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),

                    // Map Placeholder (Static Image)
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                        image: const DecorationImage(
                          image: NetworkImage('https://static-maps.yandex.ru/1.x/?lang=en_US&ll=101.14,4.48&z=13&l=map&size=450,200'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007BFF),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("GENERATE CODE", 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildLabDropdown() {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        List<DropdownMenuItem<String>> menuItems = [
          const DropdownMenuItem(value: "Lecture", child: Text("Lecture")),
        ];
        menuItems.addAll(provider.availableLabs.map((lab) {
          return DropdownMenuItem(value: lab.labName, child: Text(lab.labName));
        }).toList());

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: _selectedLab,
              hint: const Text("Select Type"),
              items: menuItems,
              onChanged: (val) => setState(() => _selectedLab = val),
              decoration: const InputDecoration(border: InputBorder.none),
              validator: (v) => v == null ? "Required" : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(flex: 2, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        Expanded(flex: 3, child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    ),
  );

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 5),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget _buildInputField({required TextEditingController controller, required String hint, required IconData icon, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(8)),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: Icon(icon, color: Colors.black54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2027));
    if (picked != null) setState(() => _dateController.text = picked.toString().split(' ')[0]);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _timeController.text = picked.format(context));
  }
}