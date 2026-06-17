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
  final String notificationId; // Changed from 'id' to 'notificationId'
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
  List<NotificationModel> _notifications = [];
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
          // Blue background header area (matches prototype)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            color: const Color(0xFFC1DBFF),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (_unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF004D73),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_unreadCount unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Tab Bar - All | Unread (Centered with border radius) - White background
          Container(
            color: Colors.white,
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

          // Divider
          Divider(height: 1, color: Colors.grey.shade300),

          // Notification List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationCard(_notifications[index]);
                        },
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
          _notifications = notificationsData
              .map((json) => NotificationModel.fromJson(json))
              .toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          _unreadCount = _notifications.where((n) => !n.isRead).length;
          _filterNotifications();
        });
      } else {
        setState(() {
          _notifications = [];
          _unreadCount = 0;
        });
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() {
        _notifications = [];
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
        // Show all notifications - don't filter
      } else if (_selectedTab == 'Unread') {
        _notifications = _notifications.where((n) => !n.isRead).toList();
      }
    });
  }

  // ✅ Mark a Single Notification as Read - Called when user clicks/taps a notification
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
          // Update the notification in the list
          final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
          if (index != -1) {
            _notifications[index] = NotificationModel(
              notificationId: _notifications[index].notificationId,
              userId: _notifications[index].userId,
              title: _notifications[index].title,
              message: _notifications[index].message,
              type: _notifications[index].type,
              isRead: true,
              timestamp: _notifications[index].timestamp,
              receiptNo: _notifications[index].receiptNo,
              amount: _notifications[index].amount,
            );
            _unreadCount = _notifications.where((n) => !n.isRead).length;
          }
        });
      }
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  // ✅ Build Individual Notification Card - Clickable to mark as read
  Widget _buildNotificationCard(NotificationModel notification) {
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: () {
        // ✅ When user taps on notification, mark it as read if unread
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
            // Title with bullet point and color
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
            
            // Message with indentation
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