import 'package:flutter/material.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'Welcome to the App!',
      'message': 'Your account has been successfully set up and configured.',
      'time': 'Just now',
      'unread': true,
      'icon': Icons.celebration,
      'color': Colors.purple,
    },
    {
      'id': 2,
      'title': 'Security Alert',
      'message': 'New sign-in detected on device at 23:12.',
      'time': '10 mins ago',
      'unread': true,
      'icon': Icons.security,
      'color': Colors.red,
    },
    {
      'id': 3,
      'title': 'System Maintenance',
      'message': 'Scheduled backup completed successfully without interruptions.',
      'time': '2 hours ago',
      'unread': false,
      'icon': Icons.build_circle,
      'color': Colors.blue,
    },
    {
      'id': 4,
      'title': 'Monthly Report Ready',
      'message': 'Your financial report for this month is ready for download.',
      'time': 'Yesterday',
      'unread': false,
      'icon': Icons.description,
      'color': Colors.green,
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var item in _notifications) {
        item['unread'] = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Text('No notifications yet'),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final item = _notifications[index];
                final isUnread = item['unread'] as bool;

                return Dismissible(
                  key: Key(item['id'].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      _notifications.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item['title']} dismissed')),
                    );
                  },
                  child: Container(
                    color: isUnread
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
                        : Colors.transparent,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: (item['color'] as Color).withValues(alpha: 0.15),
                        child: Icon(item['icon'] as IconData, color: item['color'] as Color),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['title'] as String,
                              style: TextStyle(
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(item['message'] as String),
                          const SizedBox(height: 4),
                          Text(
                            item['time'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          item['unread'] = false;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
