import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/user_provider.dart';
import '../../widgets/header.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/app_sidebar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api.dart';

class NotificationModel {
  final String notificationId;
  final int userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime timestamp;
  final String? receiptNo;
  final String? amount;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.timestamp,
    this.receiptNo,
    this.amount,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id']?.toString() ?? '',
      userId: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      timestamp: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      receiptNo: json['reference_id'],
      amount: json['amount']?.toString(),
    );
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String _selectedTab = 'All';
  List<NotificationModel> _allNotifications = [];
  List<NotificationModel> _displayNotifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3EFF8),
      appBar: const UsasHeader(),
      drawer: const AppSidebar(),
      bottomNavigationBar: const UsasBottomNav(),
      body: Column(
        children: [
          // Header with title only - Background #E3EFF8
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            color: const Color(0xFFE3EFF8),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                // ✅ Removed the "X unread" container
              ],
            ),
          ),

          // Tab Bar - All | Unread - Background #E3EFF8 (same as body)
          Container(
            color: const Color(0xFFE3EFF8),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTab('All'),
                  const SizedBox(width: 8),
                  _buildTab('Unread'),
                ],
              ),
            ),
          ),

          // Notification List - Background #E3EFF8
          Expanded(
            child: Container(
              color: const Color(0xFFE3EFF8),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _displayNotifications.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _displayNotifications.length,
                          itemBuilder: (context, index) {
                            return _buildNotificationCard(_displayNotifications[index]);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab Builder - Small with border radius
  Widget _buildTab(String title) {
    final isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
        _filterNotifications();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC1DBFF) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? const Color(0xFF004D73) : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  // Fetch Notifications from API
  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId;

      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('${Api.baseUrl}/notifications/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> notificationsData = data['notifications'] ?? [];
        
        setState(() {
          _allNotifications = notificationsData
              .map((json) => NotificationModel.fromJson(json))
              .toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          _unreadCount = _allNotifications.where((n) => !n.isRead).length;
          _filterNotifications();
        });
      } else {
        setState(() {
          _allNotifications = [];
          _displayNotifications = [];
          _unreadCount = 0;
        });
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() {
        _allNotifications = [];
        _displayNotifications = [];
        _unreadCount = 0;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Filter Notifications Based on Selected Tab
  void _filterNotifications() {
    setState(() {
      if (_selectedTab == 'All') {
        _displayNotifications = List.from(_allNotifications);
      } else if (_selectedTab == 'Unread') {
        _displayNotifications = _allNotifications.where((n) => !n.isRead).toList();
      }
    });
  }

  // Mark a Single Notification as Read
  Future<void> _markAsRead(String notificationId) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId;

      if (userId == null) return;

      final response = await http.post(
        Uri.parse('${Api.baseUrl}/notifications/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          final allIndex = _allNotifications.indexWhere((n) => n.notificationId == notificationId);
          if (allIndex != -1) {
            _allNotifications[allIndex] = NotificationModel(
              notificationId: _allNotifications[allIndex].notificationId,
              userId: _allNotifications[allIndex].userId,
              title: _allNotifications[allIndex].title,
              message: _allNotifications[allIndex].message,
              type: _allNotifications[allIndex].type,
              isRead: true,
              timestamp: _allNotifications[allIndex].timestamp,
              receiptNo: _allNotifications[allIndex].receiptNo,
              amount: _allNotifications[allIndex].amount,
            );
            _unreadCount = _allNotifications.where((n) => !n.isRead).length;
            _filterNotifications();
          }
        });
      }
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  // Build Individual Notification Card
  Widget _buildNotificationCard(NotificationModel notification) {
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: () {
        if (isUnread) {
          _markAsRead(notification.notificationId);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with color #076EFF
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 8, right: 10),
                  decoration: BoxDecoration(
                    color: isUnread ? const Color(0xFFFF0000) : const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF076EFF),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            
            // Message
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                notification.message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
            
            // Receipt number if available
            if (notification.receiptNo != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'Receipt: ${notification.receiptNo}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Build Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedTab == 'All' ? 'No notifications' : 'No unread notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your notifications will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}