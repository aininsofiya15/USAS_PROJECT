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
  State<GenerateModuleAttendanceCode> createState() =>
      _GenerateModuleAttendanceCodeState();
}

class _GenerateModuleAttendanceCodeState
    extends State<GenerateModuleAttendanceCode> {
  double? _currentLat;
  double? _currentLong;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // FIX: use the same fetch method as the Attendance Records page,
      // so this screen reads from the same DB-backed module data
      // (capacity, venue, lecturer_name, date_time) instead of the
      // separate /modules/{id}/details endpoint which returns different keys.
      Provider.of<AttendanceProvider>(context, listen: false)
          .fetchAttendanceDetails(widget.module.id ?? 0);
    });
  }

  // ── Get device GPS location ─────────────────────────────────────────────
  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Please enable device Location services/GPS toggle!"),
            backgroundColor: Colors.orange,
          ));
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
        throw 'Location permissions are permanently denied.';
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          forceAndroidLocationManager: true,
          timeLimit: const Duration(seconds: 12),
        );
        if (mounted) {
          setState(() {
            _currentLat = position.latitude;
            _currentLong = position.longitude;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Highly accurate location captured!"),
            backgroundColor: Colors.green,
          ));
        }
      }
    } catch (e) {
      debugPrint("Location error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed getting location: $e"),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  // ── Submit: generate code then navigate to release page ────────────────
  void _submitForm() async {
    if (_currentLat == null || _currentLong == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fetch your location first!"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final provider = Provider.of<AttendanceProvider>(context, listen: false);

    // Split dateTime into date + time parts for the API
    String rawDateTime = widget.module.dateTime ?? "";
    String datePart = rawDateTime;
    String timePart = rawDateTime;
    if (rawDateTime.contains(' ')) {
      final parts = rawDateTime.split(' ');
      datePart = parts[0];
      timePart = parts[1];
    }

    if (!mounted) return;

    final String? responseCode = await provider.generateModuleAttendance(
      moduleId: widget.module.id ?? 0,
      lat: _currentLat!,
      lng: _currentLong!,
      date: datePart,
      time: timePart,
    );

    if (!mounted) return;
    Navigator.pop(context); // dismiss spinner

    if (responseCode == "DUPLICATE") {
      _showDuplicateWarningDialog(context);
      return;
    }

    if (responseCode != null) {
      // FIX: resolve display values from the same source the build() method
      // uses (currentModuleDetails), so values stay consistent across the flow.
      final moduleDetails = provider.currentModuleDetails ?? {};
      final int capacity =
          moduleDetails['capacity'] ?? widget.module.capacity ?? 0;
      final String lecturerName =
          moduleDetails['lecturer_name'] ?? 'Sir / Madam';
      final String venue =
          moduleDetails['venue'] ?? widget.module.venue ?? 'N/A';
      final String dateTime =
          moduleDetails['date_time'] ?? widget.module.dateTime ?? 'N/A';
      // FIX: pass the real present-student count instead of letting the
      // release page hardcode 0.
      final int presentCount = provider.presentModuleStudent.length;

      // Navigate to release page — pass all resolved values
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReleaseModuleAttendanceCodePage(
            module: widget.module,
            code: responseCode,
            capacity: capacity,
            lecturerName: lecturerName,
            venue: venue,
            dateTime: dateTime,
            presentCount: presentCount,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to process transaction. Please try again."),
        backgroundColor: Colors.red,
      ));
    }
  }

  // ── Duplicate code warning dialog ───────────────────────────────────────
  void _showDuplicateWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_rounded,
                    color: Colors.red, size: 60),
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
                    onPressed: () =>
                        Navigator.of(ctx).popUntil((r) => r.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      "Back to Dashboard",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
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

  // ── UI ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        // FIX: read from currentModuleDetails (populated by fetchAttendanceDetails),
        // which is the same source the Attendance Records page uses.
        final moduleDetails = provider.currentModuleDetails ?? {};

        // Resolve values — DB first, module object as fallback
        final int capacity =
            moduleDetails['capacity'] ?? widget.module.capacity ?? 0;
        final String venue =
            moduleDetails['venue'] ?? widget.module.venue ?? 'N/A';
        final String lecturerName =
            moduleDetails['lecturer_name'] ?? 'Sir / Madam';
        final String dateTime =
            moduleDetails['date_time'] ?? widget.module.dateTime ?? 'N/A';

        // FIX: pull the real present-student count instead of hardcoding 0,
        // using the same list the Attendance Records page reads from.
        final int presentCount = provider.presentModuleStudent.length;

        return Scaffold(
          backgroundColor: const Color(0xFFD1FFF3),
          appBar: const UsasHeader(),
          drawer: const AppSidebar(),
          bottomNavigationBar: const UsasBottomNav(),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      // ── Page Title ──────────────────────────────────
                      const Text(
                        "Module Attendance",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // ── Card 1: Module Info ─────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 20),
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
                            _infoRow("Number of Student: $presentCount / $capacity Students"),
                            _infoRow("Class Date: $dateTime"),
                            _infoRow("Venue: $venue"),
                            _infoRow("Lecturer Name: $lecturerName"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Card 2: Geolocation + Generate ─────────────
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
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Geolocation:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      "(Select on Map)",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54),
                                    ),
                                  ],
                                ),
                                TextButton.icon(
                                  onPressed: _isFetchingLocation
                                      ? null
                                      : _getCurrentLocation,
                                  icon: _isFetchingLocation
                                      ? const SizedBox(
                                          width: 15,
                                          height: 15,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Icon(Icons.my_location,
                                          size: 18),
                                  label: Text(_isFetchingLocation
                                      ? "Fetching..."
                                      : "Get Location"),
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        const Color(0xFF007BFF),
                                  ),
                                ),
                              ],
                            ),

                            // ── Captured coordinates display ──────────
                            if (_currentLat != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  "Captured: ${_currentLat!.toStringAsFixed(5)}, "
                                  "${_currentLong!.toStringAsFixed(5)}",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 8),

                            // ── Static map preview ────────────────────
                            // FIX: was DecorationImage + NetworkImage, which
                            // fails silently (blank box, no error shown) if
                            // the tile request is blocked or rejected.
                            // Image.network gives us loadingBuilder /
                            // errorBuilder so failures are visible instead
                            // of an empty rectangle.
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 180,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _buildMapPreview(),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── Generate Code button ──────────────────
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF007BFF),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "GENERATE CODE",
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
      },
    );
  }

  // ── Static map preview with visible loading/error states ───────────────
  Widget _buildMapPreview() {
    // Center on the captured GPS point once available; otherwise fall
    // back to a default location so something still renders.
    final double lat = _currentLat ?? 4.48;
    final double lng = _currentLong ?? 101.14;
    final String mapUrl =
        'https://static-maps.yandex.ru/1.x/?lang=en_US&ll=$lng,$lat&z=13&l=map&size=450,200&pt=$lng,$lat,pm2rdm';

    return Image.network(
      mapUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint("Map preview failed to load: $error");
        return Container(
          color: Colors.grey.shade100,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, color: Colors.grey.shade400, size: 32),
              const SizedBox(height: 6),
              Text(
                "Map preview unavailable",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        );
      },
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