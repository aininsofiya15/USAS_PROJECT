import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/attendance_provider.dart';
import '../../provider/user_provider.dart';
import 'class_attendance.dart';
import 'view_attendance_records.dart';

class LecturerBody extends StatefulWidget {
  final String name;
  const LecturerBody({super.key, required this.name});

  @override
  State<LecturerBody> createState() => _LecturerBodyState();
}

class _LecturerBodyState extends State<LecturerBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      debugPrint('=== LECTURER ID FOR INSIGHTS: $userId ===');
      Provider.of<AttendanceProvider>(context, listen: false)
          .fetchAttendanceInsights(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome Title ──────────────────────────────────────────
            Text(
              "Welcome, ${widget.name}!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),

            // ── Search Bar ─────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFCBAAAA), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: SizedBox(),
                  suffixIcon: Icon(Icons.search, color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // ── Categories Title ───────────────────────────────────────
            const Text(
              "Categories",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),

            // ── Category Cards ─────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFDEC3C3),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFCBAAAA), width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildFigmaCategoryCard(
                      context,
                      imageAsset: 'assets/student_attendance_icon.png',
                      fallbackIcon: Icons.calendar_month,
                      title: "Student Attendance",
                      iconColor: Colors.orange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddAttendancePage()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildFigmaCategoryCard(
                      context,
                      imageAsset: 'assets/attendance_records_icon.png',
                      fallbackIcon: Icons.assignment_turned_in_outlined,
                      title: "Attendance Records",
                      iconColor: Colors.purple,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ViewAttendanceRecords()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ── Attendance Insights Title ──────────────────────────────
            const Text(
              "Attendance Insights",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),

            // ── Insights Chart Card ────────────────────────────────────
            // ✅ Use Selector to ONLY rebuild when attendanceInsights or
            //    isLoadingInsights changes — not when other loading states fire
            Selector<AttendanceProvider,
                Tuple2<List<dynamic>, bool>>(
              selector: (_, p) =>
                  Tuple2(p.attendanceInsights, p.isLoadingInsights),
              builder: (context, data, _) {
                final insights = data.item1;
                final isLoading = data.item2;

                debugPrint(
                    '=== CHART REBUILD: loading=$isLoading count=${insights.length} ===');

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: const Color(0xFFCBAAAA), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Chart header ─────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Student Attendance Rate",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "% Present",
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFFE57373),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Present rate by date",
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      // ── Chart body ────────────────────────────────
                      isLoading
                          ? const Center(
                              child: Padding(
                                padding:
                                    EdgeInsets.symmetric(vertical: 30),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : insights.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 30),
                                    child: Column(
                                      children: [
                                        Icon(Icons.bar_chart,
                                            size: 48,
                                            color: Colors.grey[300]),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "No attendance data yet.",
                                          style: TextStyle(
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : _buildLineChart(insights),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Line Chart Builder ───────────────────────────────────────────────────
  Widget _buildLineChart(List<dynamic> data) {
    final List<Map<String, dynamic>> points = data.map((d) {
      final total = num.tryParse(d['total_count']?.toString() ?? '0') ?? 0;
      final present =
          num.tryParse(d['present_count']?.toString() ?? '0') ?? 0;
      final rate = total > 0 ? (present / total * 100) : 0.0;
      final dateStr = d['date']?.toString() ?? '';
      String label = dateStr;
      try {
        final parts = dateStr.split('-');
        if (parts.length == 3) label = '${parts[2]}/${parts[1]}';
      } catch (_) {}
      return {'label': label, 'rate': rate.toDouble()};
    }).toList();

    const double chartHeight = 160.0;

    return Column(
      children: [
        SizedBox(
          height: chartHeight + 30,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Y axis labels ────────────────────────────────────
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['100', '75', '50', '25', '0']
                    .map((v) => Text(v,
                        style: const TextStyle(
                            fontSize: 9, color: Colors.grey)))
                    .toList(),
              ),
              const SizedBox(width: 6),

              // ── Chart + X labels ─────────────────────────────────
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: chartHeight,
                      child: CustomPaint(
                        size: const Size(double.infinity, chartHeight),
                        painter: _LineChartPainter(points: points),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: points
                          .map((p) => Text(
                                p['label'],
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.grey),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Legend ──────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFFE57373),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              "Present Rate (%)",
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }

  // ── Category Card ────────────────────────────────────────────────────────
  Widget _buildFigmaCategoryCard(
    BuildContext context, {
    required String imageAsset,
    required IconData fallbackIcon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imageAsset,
              height: 55,
              width: 55,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(fallbackIcon, size: 42, color: iconColor),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tuple helper (no extra package needed) ───────────────────────────────────
class Tuple2<A, B> {
  final A item1;
  final B item2;
  const Tuple2(this.item1, this.item2);
}

// ── Custom Line Chart Painter ────────────────────────────────────────────────
class _LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> points;
  const _LineChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    // ── Grid lines ──────────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 1;

    for (final pct in [0.0, 0.25, 0.5, 0.75, 1.0]) {
      final y = size.height - (pct * size.height);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // ── Compute offsets ─────────────────────────────────────────────
    final n = points.length;
    final stepX = n > 1 ? size.width / (n - 1) : size.width / 2;

    final List<Offset> offsets = [];
    for (int i = 0; i < n; i++) {
      final rate = (points[i]['rate'] as double).clamp(0.0, 100.0);
      offsets.add(Offset(
        i * stepX,
        size.height - (rate / 100.0 * size.height),
      ));
    }

    // ── Fill under line ─────────────────────────────────────────────
    final fillPath = Path()..moveTo(offsets.first.dx, size.height);
    for (final o in offsets) {
      fillPath.lineTo(o.dx, o.dy);
    }
    fillPath.lineTo(offsets.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..color = const Color(0xFFE57373).withOpacity(0.10)
        ..style = PaintingStyle.fill,
    );

    // ── Line ────────────────────────────────────────────────────────
    final linePath = Path()..moveTo(offsets[0].dx, offsets[0].dy);
    for (int i = 1; i < offsets.length; i++) {
      linePath.lineTo(offsets[i].dx, offsets[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xFFE57373)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // ── Dots ────────────────────────────────────────────────────────
    for (final o in offsets) {
      canvas.drawCircle(o, 4.5, Paint()..color = const Color(0xFFE57373));
      canvas.drawCircle(o, 2.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}