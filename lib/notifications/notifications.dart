import 'package:flutter/material.dart';
import '../globals.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';

class UserNotificationsPage extends StatefulWidget {
  const UserNotificationsPage({super.key});

  @override
  State<UserNotificationsPage> createState() => _UserNotificationsPageState();
}

class _UserNotificationsPageState extends State<UserNotificationsPage>
    with TickerProviderStateMixin {
  late AnimationController _listController;
  List<UserNotification> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    fetchNotifications();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  // ------------------- Fetch Notifications -------------------
  Future<void> fetchNotifications() async {
    setState(() => isLoading = true);
    try {
      notifications = await NotificationService.fetchNotifications();
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
    if (mounted) {
      setState(() => isLoading = false);
      _listController.forward(from: 0.0);
    }
  }

  // ------------------- Mark as Read -------------------
  Future<void> markAsRead(UserNotification notification) async {
    if (notification.status == 'read') return;

    try {
      await NotificationService.markAsRead(notification.notificationid);
      setState(() {
        notification.status = 'read';
      });
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to mark notification as read")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _buildNotificationList(),
          ),
          const SizedBox(height: 20),
          const AppLogo(size: 80), // replace with your logo widget
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ------------------- Top Bar -------------------
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "NOTIFICATIONS",
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Updates",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1C1E),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: electricCyan,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
          )
        ],
      ),
    );
  }

  // ------------------- Notification List -------------------
  Widget _buildNotificationList() {
    if (notifications.isEmpty) {
      return const Center(child: Text("No notifications found."));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final n = notifications[index];
        return AnimatedBuilder(
          animation: _listController,
          builder: (context, child) {
            final slide =
            Curves.easeOutCubic.transform((_listController.value - (index * 0.1)).clamp(0.0, 1.0));
            return Opacity(
              opacity: slide,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - slide)),
                child: child,
              ),
            );
          },
          child: _buildNotificationCard(n),
        );
      },
    );
  }

  // ------------------- Notification Card -------------------
  Widget _buildNotificationCard(UserNotification n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: n.status == 'unread' ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: InkWell(
        onTap: () => markAsRead(n),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                n.status == 'unread'
                    ? Icons.notifications_active
                    : Icons.notifications_none,
                color: n.status == 'unread' ? electricCyan : Colors.grey,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.message,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      n.sentAt,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (n.status == 'unread')
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: electricCyan,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
