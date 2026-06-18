import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../widgets/header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/navigation_bar.dart';
import '../../provider/attendance_provider.dart';
import '../../domain/module.dart';

class EditModuleAttendancePage extends StatefulWidget {
  final Module module;

  const EditModuleAttendancePage({
    super.key,
    required this.module,
  });

  @override
  State<EditModuleAttendancePage> createState() => _EditModuleAttendancePageState();
}

class _EditModuleAttendancePageState extends State<EditModuleAttendancePage> {
  double? _updatedLat;
  double? _updatedLong;
  bool _isFetchingLocation = false;
  bool _isUpdating = false;
  bool _hasInitializedCoords = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<AttendanceProvider>(context, listen: false);
      // FIX: use the same fetch method as the Generate Code page, so this
      // screen reads real DB data (capacity, lecturer_name, geo_lat, geo_long)
      // instead of the separate /modules/{id}/details endpoint.
      await provider.fetchAttendanceDetails(widget.module.id ?? 0);
      
      // Pull current active coordinates safely from the provider dictionary store
      final moduleDetails = provider.currentModuleDetails ?? {};
      if (mounted && moduleDetails.isNotEmpty) {
        setState(() {
          _updatedLat = double.tryParse(moduleDetails['geo_lat']?.toString() ?? '');
          _updatedLong = double.tryParse(moduleDetails['geo_long']?.toString() ?? '');
          _hasInitializedCoords = true;
        });
      }
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
            const SnackBar(
              content: Text("Please enable device Location services/GPS toggle!"), 
              backgroundColor: Colors.orange
            ),
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
            _updatedLat = position.latitude;
            _updatedLong = position.longitude;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Highly accurate location updated!"), 
              backgroundColor: Colors.green
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Location error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed getting location accuracy: $e"), 
            backgroundColor: Colors.red
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
    }
  }

  // --- SAVE ACTION: Calls your Controller/Provider Method ---
  void _saveUpdatedLocation() async {
  if (_updatedLat == null || _updatedLong == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please fetch an updated location first!"), 
        backgroundColor: Colors.red
      ),
    );
    return;
  }

  setState(() => _isUpdating = true);

  final provider = Provider.of<AttendanceProvider>(context, listen: false);
  final moduleDetails = provider.currentModuleDetails ?? {};

  // Get the actual attendance ID (fallback to module ID if not found)
  final int targetAttendanceId = moduleDetails['id'] ?? (widget.module.id ?? 0);

  bool isSuccess = await provider.updateModuleAttendanceDetails(
    moduleId: targetAttendanceId, // This now correctly passes 40 instead of the module id!
    lat: _updatedLat!,
    lng: _updatedLong!,
  );

  if (!mounted) return;
  setState(() => _isUpdating = false);

  if (isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Geolocation details saved successfully!"), 
        backgroundColor: Colors.green
      ),
    );
    Navigator.pop(context, true); 
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Failed to update details. Please check your network connection."), 
        backgroundColor: Colors.red
      ),
    );
  }
}

  // ── UI ──────────────────────────────────────────────────────────────────
  // NOTE: Restyled to visually match GenerateModuleAttendanceCode (two cards,
  // centered info rows, same shadow/radius/color values). No fetch logic,
  // state variables, or button actions were changed — only the widget tree
  // below this point.
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    // FIX: read from currentModuleDetails (populated by fetchAttendanceDetails),
    // the same source the Generate Code page uses.
    final moduleDetails = provider.currentModuleDetails ?? {};

    // Sync fallback once when network details come alive, if not touched yet
    if (!_hasInitializedCoords && moduleDetails.isNotEmpty) {
      _updatedLat = double.tryParse(moduleDetails['geo_lat']?.toString() ?? '');
      _updatedLong = double.tryParse(moduleDetails['geo_long']?.toString() ?? '');
      _hasInitializedCoords = true;
    }

    // Resolve values — DB first, module object as fallback (same pattern
    // as GenerateModuleAttendanceCode)
    final int presentCount = provider.presentModuleStudent.length;
    final int capacity = moduleDetails['capacity'] ?? widget.module.capacity ?? 0;
    final String venue = moduleDetails['venue'] ?? widget.module.venue ?? 'N/A';
    final String lecturerName = moduleDetails['lecturer_name'] ?? 'Sir / Madam';
    final String dateTime = moduleDetails['date_time'] ?? widget.module.dateTime ?? 'N/A';

    return Scaffold(
      backgroundColor: const Color(0xFFD1FFF3),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // ── Page Title ──────────────────────────────────
            const Text(
              "Edit Module Attendance",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ── Card 1: Module Info ─────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    (widget.module.activityName ?? "").toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _infoRow(
                    "Adaptive Students: $presentCount / $capacity",
                  ),
                  _infoRow("Class Date: $dateTime"),
                  _infoRow("Venue: $venue"),
                  _infoRow("Lecturer Name: $lecturerName"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Card 2: Geolocation + Update ─────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Geolocation row ───────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Update Geolocation:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "(Tap to refresh)",
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: _isFetchingLocation ? null : _getCurrentLocation,
                        icon: _isFetchingLocation
                            ? const SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location, size: 18),
                        label: Text(_isFetchingLocation ? "Fetching..." : "Refresh GPS"),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF007BFF),
                        ),
                      ),
                    ],
                  ),

                  // ── Captured coordinates display ──────────
                  if (_updatedLat != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        "Current Coordinates: ${_updatedLat!.toStringAsFixed(5)}, "
                        "${_updatedLong!.toStringAsFixed(5)}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // ── Static map preview ────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://static-maps.yandex.ru/1.x/?lang=en_US&ll=101.14,4.48&z=13&l=map&size=450,200',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Update button ──────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : _saveUpdatedLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: _isUpdating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              "SAVE CHANGES",
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
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }
}