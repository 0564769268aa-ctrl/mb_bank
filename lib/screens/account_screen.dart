import 'package:material_ui/material_ui.dart';

import '../app_data.dart';
import 'notifications_screen.dart';
import 'savings_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _profile(),
          const SizedBox(height: 16),
          _menu(),
          const SizedBox(height: 16),
          const Text(
            'ỨNG DỤNG DEMO – KHÔNG PHẢI NGÂN HÀNG CHÍNH THỨC. '
            'Mọi sử dụng và giao dịch đều giả lập.',
            style: TextStyle(color: Color(0xFF805000), fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _profile() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFF0755A4),
            child: Text('ND', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppData.accountHolder,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text('STK: ${AppData.accountNumber}',
                    style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 2),
                Text('Số dư: ${money(AppData.I.balance)}',
                    style: const TextStyle(color: Color(0xFF0755A4), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menu() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _tile(Icons.history, 'Lịch sử giao dịch',
              () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xem ở mục Trang chủ')))),
          _divider(),
          _tile(Icons.notifications_outlined, 'Thông báo', () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
          _divider(),
          _tile(Icons.savings_outlined, 'Tiền gửi tiết kiệm',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsScreen()))),
          _divider(),
          _tile(Icons.settings_outlined, 'Cài đặt',
              () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cài đặt đang là tính năng demo')))),
          _divider(),
          _tile(Icons.info_outline, 'Giới thiệu', () => showAboutDialog(
                context: context,
                applicationName: 'MB BANK DEMO',
                applicationVersion: '1.0 DEMO',
                children: const [
                  Text('Ứng dụng mô phỏng độc lập. Không phải ứng dụng MB Bank chính thức. '
                      'Không thực hiện giao dịch thật.'),
                ],
              )),
          _divider(),
          _tile(Icons.logout, 'Đăng xuất', _confirmLogout, color: Colors.red),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right, color: Colors.black38),
      onTap: onTap,
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 16, endIndent: 16);

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn muốn đăng xuất khỏi MB BANK DEMO?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Đăng xuất')),
        ],
      ),
    );
    if (ok == true) AppData.I.logout();
  }
}
