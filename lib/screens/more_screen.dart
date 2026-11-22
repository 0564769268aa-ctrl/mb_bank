import 'package:material_ui/material_ui.dart';

import '../app_data.dart';
import 'notifications_screen.dart';
import 'savings_screen.dart';
import 'transfer_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0755A4),
        foregroundColor: Colors.white,
        title: const Text('Thêm', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0755A4), Color(0xFF1386D5)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Text(
                    AppData.accountHolder.substring(0, 1),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppData.accountHolder,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('STK: ${AppData.accountNumber}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Menu
          _section('Tài chính', [
            _item(context, Icons.swap_horiz, 'Chuyển tiền', const Color(0xFF0755A4),
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen()))),
            _item(context, Icons.savings, 'Tiền gửi tiết kiệm', Colors.green,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsScreen()))),
            _item(context, Icons.account_balance, 'Vay vốn', Colors.orange, () {}),
          ]),
          const SizedBox(height: 12),
          _section('Tiện ích', [
            _item(context, Icons.notifications_outlined, 'Thông báo', Colors.blue,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
            _item(context, Icons.qr_code, 'Mã QR của tôi', Colors.purple, () {}),
            _item(context, Icons.settings_outlined, 'Cài đặt', Colors.grey, () {}),
          ]),
          const SizedBox(height: 12),
          _section('Tài khoản', [
            _item(context, Icons.logout, 'Đăng xuất', Colors.red, () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Đăng xuất?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                    FilledButton(onPressed: () { Navigator.pop(context); AppData.I.logout(); }, child: const Text('Đăng xuất')),
                  ],
                ),
              );
            }),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}
