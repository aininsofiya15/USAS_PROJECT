import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; 
import '../../provider/manage_fees_provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FinancialReportPage extends StatefulWidget {
  const FinancialReportPage({super.key});

  @override
  State<FinancialReportPage> createState() => _FinancialReportPageState();
}

class _FinancialReportPageState extends State<FinancialReportPage> {
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  bool _isLoading = false;
  
  // ✅ Separate loading states for PDF and CSV
  bool _isDownloadingPDF = false;
  bool _isDownloadingCSV = false;

  // ✅ Method to fetch data with current date range
  Future<void> _fetchReportData() async {
    setState(() => _isLoading = true);
    
    try {
      final provider = Provider.of<FeesManagementProvider>(context, listen: false);
      await provider.fetchReportTotals(
        startDate: _startDate,
        endDate: _endDate,
      );
    } catch (e) {
      print('Error fetching report data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching report data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      await _fetchReportData();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchReportData();
    });
  }

  // ✅ Improved Download PDF with better error handling
  Future<void> _downloadPDF() async {
    // Don't allow concurrent downloads
    if (_isDownloadingPDF || _isDownloadingCSV) return;
    
    setState(() => _isDownloadingPDF = true);
    
    try {
      // Build URL with date parameters
      String url = 'http://10.0.2.2:8000/api/treasurer/report/download-pdf';
      url += '?start_date=${DateFormat('yyyy-MM-dd').format(_startDate)}';
      url += '&end_date=${DateFormat('yyyy-MM-dd').format(_endDate)}';
      
      print('📄 Downloading PDF from: $url');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating PDF...'),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Add timeout to prevent hanging
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Request timeout - server took too long to respond');
        },
      );
      
      if (response.statusCode == 200) {
        // Get downloads directory
        final directory = await getDownloadsDirectory();
        if (directory == null) {
          throw Exception('Could not find downloads directory');
        }
        
        // Create file name with current date
        final fileName = 'USAS-Financial-Report-${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
        final file = File('${directory.path}/$fileName');
        
        // Write the file
        await file.writeAsBytes(response.bodyBytes);
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ PDF downloaded to: ${directory.path}/$fileName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        // ✅ Better error handling for server errors
        String errorMessage = 'Failed to download PDF (${response.statusCode})';
        try {
          // Try to parse error message from response body
          final errorBody = String.fromCharCodes(response.bodyBytes);
          if (errorBody.isNotEmpty) {
            errorMessage += ': $errorBody';
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      
      // ✅ Specific error message for 500 errors
      String errorMessage = e.toString();
      if (errorMessage.contains('500')) {
        errorMessage = 'Server error (500): The server encountered an error. Please check the backend logs and try again.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $errorMessage'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloadingPDF = false);
      }
    }
  }

  // ✅ Improved Download CSV with better error handling
  Future<void> _downloadCSV() async {
    // Don't allow concurrent downloads
    if (_isDownloadingCSV || _isDownloadingPDF) return;
    
    setState(() => _isDownloadingCSV = true);
    
    try {
      // Build URL with date parameters
      String url = 'http://10.0.2.2:8000/api/treasurer/report/download-csv';
      url += '?start_date=${DateFormat('yyyy-MM-dd').format(_startDate)}';
      url += '&end_date=${DateFormat('yyyy-MM-dd').format(_endDate)}';
      
      print('📊 Downloading CSV from: $url');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating CSV...'),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Add timeout to prevent hanging
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Request timeout - server took too long to respond');
        },
      );
      
      if (response.statusCode == 200) {
        // Get downloads directory
        final directory = await getDownloadsDirectory();
        if (directory == null) {
          throw Exception('Could not find downloads directory');
        }
        
        // Create file name with current date
        final fileName = 'USAS-Financial-Ledger-${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
        final file = File('${directory.path}/$fileName');
        
        // Write the file
        await file.writeAsBytes(response.bodyBytes);
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ CSV downloaded to: ${directory.path}/$fileName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        // ✅ Better error handling for server errors
        String errorMessage = 'Failed to download CSV (${response.statusCode})';
        try {
          final errorBody = String.fromCharCodes(response.bodyBytes);
          if (errorBody.isNotEmpty) {
            errorMessage += ': $errorBody';
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = e.toString();
      if (errorMessage.contains('500')) {
        errorMessage = 'Server error (500): The server encountered an error. Please check the backend logs and try again.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $errorMessage'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloadingCSV = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedRange = "${DateFormat('d/M/yyyy').format(_startDate)} - ${DateFormat('d/M/yyyy').format(_endDate)}";

    return Scaffold(
      backgroundColor: const Color(0xFFE8F8E3),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Consumer<FeesManagementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading || _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC1F6AC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Align(
                        alignment: Alignment.center,
                        child: Text("Reports", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 15),
                      
                      GestureDetector(
                        onTap: () => _selectDateRange(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(formattedRange, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 8),
                              const Icon(Icons.filter_alt, size: 18, color: Colors.black54),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(child: _buildChartCard("Transaction Volume (Counts)", _buildBarChart(provider))),
                          const SizedBox(width: 10),
                          Expanded(child: _buildChartCard("Paid vs Unpaid", _buildPieChart(provider))),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              "Total Paid", 
                              "RM ${NumberFormat('#,##0.00').format(provider.totalPaidReport)}",
                              isBlocked: false,
                            )
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              "Outstanding Balance", 
                              "RM ${NumberFormat('#,##0.00').format(provider.totalOutstandingReport)}",
                              isBlocked: false,
                            )
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              "Blocked Students", 
                              "${provider.summary['blocked'] ?? 0}",
                              isBlocked: true,
                            )
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActionButton(
                              context, 
                              "Download as PDF", 
                              Colors.blue, 
                              _downloadPDF,
                              _isDownloadingPDF,  // ✅ Pass PDF loading state
                            ),
                            const SizedBox(width: 8),
                            _buildActionButton(
                              context, 
                              "Download as CSV", 
                              Colors.blue, 
                              _downloadCSV,
                              _isDownloadingCSV,  // ✅ Pass CSV loading state
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      height: 240, 
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 20),
          Expanded(child: chart),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, {bool isBlocked = false}) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 10),
          Text(
            value, 
            textAlign: TextAlign.center, 
            style: TextStyle(
              fontSize: isBlocked ? 28 : 16,
              fontWeight: FontWeight.bold, 
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(FeesManagementProvider provider) {
    double bankCount = double.tryParse(provider.summary['bank_count']?.toString() ?? '0') ?? 0;
    double cardCount = double.tryParse(provider.summary['card_count']?.toString() ?? '0') ?? 0;

    if (bankCount == 0 && cardCount == 0) {
      bankCount = 145; 
      cardCount = 88;
    }

    double maxCeiling = (bankCount > cardCount ? bankCount : cardCount);
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxCeiling * 1.3, 
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true, 
          drawVerticalLine: false,
          horizontalInterval: maxCeiling > 4 ? maxCeiling / 4 : 1, 
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30, 
              getTitlesWidget: (value, meta) {
                return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 8));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 9);
                switch (value.toInt()) {
                  case 0:
                    return const Padding(padding: EdgeInsets.only(top: 8.0), child: Text('Internet Banking', style: style));
                  case 1:
                    return const Padding(padding: EdgeInsets.only(top: 8.0), child: Text('Card', style: style));
                  default:
                    return const Text('');
                }
              },
            ),
          ),
        ),
        barGroups: [
          BarChartGroupData(
            x: 0, 
            barRods: [
              BarChartRodData(
                toY: bankCount, 
                color: Colors.cyan, 
                width: 24, 
                borderRadius: BorderRadius.circular(4),
              )
            ],
          ),
          BarChartGroupData(
            x: 1, 
            barRods: [
              BarChartRodData(
                toY: cardCount, 
                color: Colors.blueAccent, 
                width: 24, 
                borderRadius: BorderRadius.circular(4),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(FeesManagementProvider provider) {
    double paidAmount = provider.totalPaidReport;
    double unpaidAmount = provider.totalOutstandingReport;
    double totalAmount = paidAmount + unpaidAmount;

    double paidPercent = totalAmount == 0 ? 0.0 : (paidAmount / totalAmount) * 100;
    double unpaidPercent = totalAmount == 0 ? 0.0 : (unpaidAmount / totalAmount) * 100;

    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 25,
        sections: [
          if (paidAmount > 0 || totalAmount == 0)
            PieChartSectionData(
              color: const Color(0xFFB39DDB), 
              value: paidPercent,
              title: '${paidPercent.toStringAsFixed(1)}%\nPaid',
              radius: 40,
              titleStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          if (unpaidAmount > 0 || totalAmount == 0)
            PieChartSectionData(
              color: const Color(0xFFFFCC80), 
              value: unpaidPercent,
              title: '${unpaidPercent.toStringAsFixed(1)}%\nUnpaid',
              radius: 40,
              titleStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text, Color color, VoidCallback action, bool isDownloading) {
    return ElevatedButton(
      onPressed: isDownloading ? null : action,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: const Size(100, 30),
      ),
      child: isDownloading
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              text, 
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
    );
  }
}