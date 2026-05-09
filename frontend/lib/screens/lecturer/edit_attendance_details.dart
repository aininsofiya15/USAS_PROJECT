import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../widgets/header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/navigation_bar.dart';
import '../../provider/attendance_provider.dart';

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
  double? _lat;
  double? _lng;
  bool _isFetchingLocation = false;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    
    // 1. Fetch Labs first
    await provider.fetchLabsForSection(widget.sectionId);
    
    // 2. Fetch record
    final data = await provider.fetchSingleAttendance(widget.attendanceId);
    
    if (data != null && mounted) {
      setState(() {
        // Safe mapping
        String? dbLab = data['class_type']?.toString();
        
        // Safety Check: Only set _selectedLab if it's "Lecture" or exists in fetched labs
        bool existsInLabs = provider.availableLabs.any((l) => l.labName == dbLab);
        if (dbLab == "Lecture" || existsInLabs) {
          _selectedLab = dbLab;
        } else {
          _selectedLab = "Lecture"; // Fallback to Lecture if DB value is weird
        }

        _dateController.text = data['date']?.toString() ?? '';
        _timeController.text = data['time']?.toString() ?? '';
        _selectedLab = data['class_type']?.toString();
        _lat = double.tryParse(data['geo_lat']?.toString() ?? '0.0') ?? 0.0;
        _lng = double.tryParse(data['geo_long']?.toString() ?? '0.0') ?? 0.0;
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
      });
    } catch (e) {
      debugPrint("Location Error: $e");
    } finally {
      setState(() => _isFetchingLocation = false);
    }
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AttendanceProvider>(context, listen: false);
      
      bool success = await provider.updateAttendanceDetails(
        attendanceId: widget.attendanceId,
        labName: _selectedLab ?? 'Lecture',
        date: _dateController.text,
        time: _timeController.text,
        lat: _lat ?? 0.0,
        lng: _lng ?? 0.0,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Attendance Updated Successfully!")),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3D8DA),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Edit Attendance", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow("Subject:", widget.subjectName),
                    _buildRow("Section:", widget.sectionNo),
                    
                    const SizedBox(height: 20),
                    const Text("Lecture/Lab:", style: TextStyle(fontWeight: FontWeight.bold)),
                    _buildLabDropdown(),

                    const Text("Date:", style: TextStyle(fontWeight: FontWeight.bold)),
                    _buildInputField(_dateController, Icons.calendar_month, _pickDate),

                    const Text("Time:", style: TextStyle(fontWeight: FontWeight.bold)),
                    _buildInputField(_timeController, Icons.access_time, _pickTime),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Geolocation:", style: TextStyle(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: _isFetchingLocation ? null : _getCurrentLocation, 
                          child: Text(_isFetchingLocation ? "Fetching..." : "Update GPS")
                        ),
                      ],
                    ),
                    if (_lat != null) 
                       Text("GPS: ${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}", 
                       style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007BFF), 
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        child: const Text("SAVE CHANGES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: _selectedLab,
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

  Widget _buildRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    ),
  );

  Widget _buildInputField(TextEditingController controller, IconData icon, VoidCallback onTap) => Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(8)),
    child: TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(suffixIcon: Icon(icon), border: InputBorder.none, contentPadding: const EdgeInsets.all(15)),
    ),
  );

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2027));
    if (picked != null) setState(() => _dateController.text = picked.toString().split(' ')[0]);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _timeController.text = picked.format(context));
  }
}