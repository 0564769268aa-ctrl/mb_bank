import 'package:material_ui/material_ui.dart';

import '../app_data.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    AppData.I.addListener(_onChange);
  }

  @override
  void dispose() {
    AppData.I.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final list = AppData.I.notifications;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          if (AppData.I.unreadCount > 0)
            TextButton(
              onPressed: AppData.I.markAllNotificationsRead,
              child: const Text('Đánh dấu đã đọc',
                  style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: list.isEmpty
          ? const Center(child: Text('Chưa có thông báo nào.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final n = list[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: n.read
                        ? Colors.grey.shade200
                        : const Color(0xFFEAF2FB),
                    child: Icon(
                      n.read ? Icons.notifications_none : Icons.notifications_active,
                      color: const Color(0xFF0755A4),
                    ),
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: n.read ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('${n.body}\n${formatDate(n.date)}'),
                  isThreeLine: true,
                  onTap: AppData.I.markAllNotificationsRead,
                );
              },
            ),
    );
  }
}
