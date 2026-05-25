import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../widgets/header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/navigation_bar.dart';
import '../../provider/attendance_provider.dart';
import '../../domain/module.dart';
import 'release_module_attendance.dart';

class GenerateModuleAttendanceCode extends StatefulWidget {
  final Module module;

  const GenerateModuleAttendanceCode({
    super.key,
    required this.module,
  });

  @override
  State<GenerateModuleAttendanceCode> createState() => _GenerateModuleAttendanceCodeState();
}

class _GenerateModuleAttendanceCodeState extends State<GenerateModuleAttendanceCode> {
  // Coordinates variables
  double? _currentLat;
  double? _currentLong;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AttendanceProvider>(context, listen: false)
          .fetchModuleDetails(widget.module.id ?? 0);
    });
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location captured!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Location error: $e");
    } finally {
      setState(() => _isFetchingLocation = false);
    }
  }

void _submitForm() async {
  if (_currentLat == null || _currentLong == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fetch your location first!"), backgroundColor: Colors.red),
    );
    return;
  }

  final provider = Provider.of<AttendanceProvider>(context, listen: false);

  final String? generatedCode = await provider.generateModuleAttendance(
    moduleId: widget.module.id ?? 0,
    lat: _currentLat!,
    lng: _currentLong!,
  );

  if (generatedCode != null && mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReleaseModuleAttendanceCodePage(
          module: widget.module,
          code: generatedCode, // No red line now because the other file only wants these 2!
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to generate code."), backgroundColor: Colors.red),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final moduleDetails = provider.moduleDetails ?? {}; 

    return Scaffold(
      backgroundColor: const Color(0xFFD1FFF3), // Mint Theme
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Module Attendance", 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 20),

            // Single Main Card - Matching Lecturer UI style
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05), 
                    blurRadius: 10, 
                    offset: const Offset(0, 4)
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Module Info Section using standard InfoRow
                  _buildInfoRow("Activity:", widget.module.activityName),
                  _buildInfoRow(
                    "Students:", 
                    "${moduleDetails['currentStudents'] ?? '0'} / ${moduleDetails['totalStudents'] ?? '0'}"
                  ),
                  _buildInfoRow("Date:", widget.module.dateTime),
                  _buildInfoRow("Venue:", widget.module.venue),
                  _buildInfoRow("Lecturer:", moduleDetails['lecturerName'] ?? 'Sir / Madam'),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                  ),

                  // Geolocation Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Geolocation:", 
                        style: TextStyle(fontWeight: FontWeight.bold)
                      ),
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

                  // Map Placeholder
                  GestureDetector(
                    onTap: _isFetchingLocation ? null : _getCurrentLocation,
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                        image: const DecorationImage(
                          image: NetworkImage('https://static-maps.yandex.ru/1.x/?lang=en_US&ll=101.14,4.48&z=13&l=map&size=450,200'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: _isFetchingLocation 
                        ? Container(color: Colors.white54, child: const Center(child: CircularProgressIndicator()))
                        : null,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Generate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF), // Standard Blue
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "GENERATE CODE", 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
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

  // --- UI HELPER METHOD ---
  Widget _buildInfoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2, 
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))
        ),
        Expanded(
          flex: 3, 
          child: Text(
            value, 
            textAlign: TextAlign.right, 
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3F51B5))
          )
        ),
      ],
    ),
  );
}