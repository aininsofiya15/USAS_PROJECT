import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../widgets/header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/navigation_bar.dart';
import '../../provider/attendance_provider.dart';
import '../../provider/user_provider.dart';
import 'view_attendance_records.dart';

class EditAttendanceDetails extends StatefulWidget {
  final int attendanceId;
  final String subjectName;
  final String sectionNo;
  final int sectionId;

  const EditAttendanceDetails({
    super.key,
    required this.attendanceId,
    required this.subjectName,
    required this.sectionNo,
    required this.sectionId,
  });

  @override
  State<EditAttendanceDetails> createState() => _EditAttendanceDetailsState();
}

class _EditAttendanceDetailsState extends State<EditAttendanceDetails> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  
  String? _selectedLab; 
  double? _currentLat;
  double? _currentLong;
  
  // Local variables to hold the display names
  late String _displaySubjectName;
  late String _displaySectionNo;

  bool _isFetchingLocation = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize with widget values to prevent null errors before DB loads
    _displaySubjectName = widget.subjectName;
    _displaySectionNo = widget.sectionNo;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AttendanceProvider>(context, listen: false)
          .fetchLabsForSection(widget.sectionId);
      
      _loadExistingData();
    });
  }

  // --- LOGIC: Fetch Existing Data ---
  Future<void> _loadExistingData() async {
    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    try {
      final data = await provider.fetchSingleAttendance(widget.attendanceId);
      
      if (data != null && mounted) {
        setState(() {
          // Update Subject and Section if DB returns them, otherwise keep defaults
          _displaySubjectName = data['subject_name']?.toString() ?? _displaySubjectName;
          _displaySectionNo = data['section_no']?.toString() ?? _displaySectionNo;

          // Safely map other DB fields
          _dateController.text = data['date']?.toString() ?? "";
          String rawTime = data['time']?.toString() ?? '';
          _timeController.text = rawTime.length >= 5 ? rawTime.substring(0, 5) : rawTime;
          
          _currentLat = double.tryParse(data['geo_lat']?.toString() ?? '');
          _currentLong = double.tryParse(data['geo_long']?.toString() ?? '');
          
          _selectedLab = data['class_type']?.toString();
        });
      } else {
        debugPrint("No data found for Attendance ID: ${widget.attendanceId}");
      }
    } catch (e) {
      debugPrint("Database Load Error: $e");
    } finally {
      // Ensure loading spinner stops regardless of success or failure
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- POPUP DIALOG ROUTINE ROUTING TO VIEW ATTENDANCE RECORDS ---
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 5,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Circular check icon layout
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 32,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 18),
                // Dialog descriptive text block
                const Text(
                  "Attendance details updated successfully!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                // Styled Green OK Button routing to ViewAttendanceRecords
                SizedBox(
                  width: 110,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      // 1. Dismiss the dialog box first
                      Navigator.pop(context); 
                      
                      // 2. Navigate to ViewAttendanceRecords page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ViewAttendanceRecords(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981), // Vivid Emerald Green
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.5,
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

  // --- LOGIC: Fetch Current GPS ---
  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
        );
        setState(() {
          _currentLat = position.latitude;
          _currentLong = position.longitude;
        });
        
        // Triggers the custom popup alert upon successful tracking retrieval
        if (mounted) {
          _showSuccessDialog();
        }
      }
    } catch (e) {
      debugPrint("Location error: $e");
    } finally {
      setState(() => _isFetchingLocation = false);
    }
  }

  // --- LOGIC: Save Changes ---
  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      if (_currentLat == null || _currentLong == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location coordinates are missing!"), backgroundColor: Colors.red),
        );
        return;
      }

      final provider = Provider.of<AttendanceProvider>(context, listen: false);
      
      bool success = await provider.updateAttendanceDetails(
        attendanceId: widget.attendanceId,
        date: _dateController.text,
        time: _timeController.text,
        classType: _selectedLab ?? "Lecture",
        lat: _currentLat!, 
        lng: _currentLong!,
      );
      
      if (success && mounted) {
        final userId = Provider.of<UserProvider>(context, listen: false).userId;
        provider.fetchAttendanceHistory(userId);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Changes Saved permanently!"), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F2), // Matches GenerateAttendanceCode view background
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEC3C3), 
                      borderRadius: BorderRadius.circular(24),
                      border: null, 
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Edit Attendance", 
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 20),

                        // White Form container sheet card wrapper
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow("Subject:", _displaySubjectName),
                                _buildInfoRow("Section:", _displaySectionNo),
                                
                                const SizedBox(height: 10),
                                
                                // Lecture/Lab Inline Row layout setup
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        flex: 4,
                                        child: Text("Lecture/Lab:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: _buildLabDropdown(),
                                      ),
                                    ],
                                  ),
                                ),

                                // Date Inline Row structure
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        flex: 4,
                                        child: Text("Date:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: _buildInputField(controller: _dateController, hint: "Select Date", icon: Icons.calendar_month, onTap: _pickDate),
                                      ),
                                    ],
                                  ),
                                ),

                                // Time Inline Row structure
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        flex: 4,
                                        child: Text("Time:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: _buildInputField(controller: _timeController, hint: "Select Time", icon: Icons.access_time, onTap: _pickTime),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // --- GEOLOCATION SECTION WITH DUAL OVERVIEW ---
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Geolocation:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                                        const Text("(Select on Map)", style: TextStyle(fontSize: 12, color: Colors.black54)),
                                      ],
                                    ),
                                    TextButton.icon(
                                      onPressed: _isFetchingLocation ? null : _getCurrentLocation,
                                      icon: _isFetchingLocation 
                                        ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2))
                                        : const Icon(Icons.my_location, size: 18),
                                      label: Text(_isFetchingLocation ? "Fetching..." : "Update Location"),
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFF3F51B5),
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 10),
                                
                                if (_currentLat != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      "Recorded: ${_currentLat!.toStringAsFixed(5)}, ${_currentLong!.toStringAsFixed(5)}",
                                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),

                                // Map Placeholder (Static Image Widget Box)
                                Container(
                                  height: 130,
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
                                    onPressed: _saveChanges,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF007BFF),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 1,
                                    ),
                                    child: const Text(
                                      "SAVE CHANGES", 
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

        bool exists = _selectedLab == null || menuItems.any((item) => item.value == _selectedLab);
        if (!exists) {
          menuItems.add(DropdownMenuItem(value: _selectedLab, child: Text("$_selectedLab (Current)")));
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedLab ?? "Lecture",
              hint: const Text("Select Type"),
              items: menuItems,
              onChanged: (val) => setState(() => _selectedLab = val),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 10)),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 4, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black))),
        Expanded(flex: 5, child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87))),
      ],
    ),
  );

  Widget _buildInputField({required TextEditingController controller, required String hint, required IconData icon, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(8)),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: Icon(icon, color: Colors.black54, size: 20),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (picked != null) setState(() => _dateController.text = picked.toString().split(' ')[0]);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _timeController.text = picked.format(context));
  }
}