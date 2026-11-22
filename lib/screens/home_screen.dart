import 'package:material_ui/material_ui.dart';

import '../app_data.dart';
import 'notifications_screen.dart';
import 'savings_screen.dart';
import 'transfer_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int tab)? onSwitchTab;
  const HomeScreen({super.key, this.onSwitchTab});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _balanceVisible = false;

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
      backgroundColor: const Color(0xFFF3F6FA),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _header()),
          SliverToBoxAdapter(child: _quickActions()),
          SliverToBoxAdapter(child: _transactionSection()),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0755A4), Color(0xFF1386D5), Color(0xFF38C0F0)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text('MB',
                          style: TextStyle(
                            color: Color(0xFF0755A4),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          )),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('MB',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {},
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined,
                            color: Colors.white),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const NotificationsScreen()),
                        ),
                      ),
                      if (AppData.I.unreadCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${AppData.I.unreadCount}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 9),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Balance card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white24,
                    child: Text(
                      AppData.accountHolder.substring(0, 1),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Tổng số dư VND',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 13)),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios,
                                color: Colors.white70, size: 12),
                            const Spacer(),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _balanceVisible = !_balanceVisible),
                              child: Icon(
                                _balanceVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white70,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _balanceVisible
                              ? money(AppData.I.balance)
                              : '*** *** VND',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'BẠN ĐƯỢC CẤP ĐỂ CHI TIÊU',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick actions row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _headerAction(Icons.swap_horiz, 'Chuyển tiền',
                      () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const TransferScreen()))),
                  _headerAction(Icons.phone_android, 'Nạp tiền\nđiện thoại', () {}),
                  _headerAction(Icons.savings, 'Tiền gửi',
                      () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SavingsScreen()))),
                  _headerAction(Icons.account_balance, 'Vay nhanh', () {}),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _headerAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF0755A4), size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _quickActions() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mua sắm · Giải trí · Đầu tư',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.85,
            children: [
              _gridAction(Icons.confirmation_number, 'Vé xổ số', () {}),
              _gridAction(Icons.sms, 'Vé Vietlott', () {}),
              _gridAction(Icons.wifi, 'Data 4G\nNạp tiền', () {}),
              _gridAction(Icons.flight, 'Vé Máy Bay\nSố', () {}),
              _gridAction(Icons.flight_takeoff, 'Du lịch', () {}),
              _gridAction(Icons.phone_android, '4G', () {}),
              _gridAction(Icons.self_improvement, 'Sức khỏe', () {}),
              _gridAction(Icons.qr_code, 'Quét QR', () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gridAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF0755A4), size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _transactionSection() {
    final txns = AppData.I.transactions;
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Lịch sử giao dịch',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              GestureDetector(
                onTap: () {},
                child: const Text('Xem tất cả',
                    style: TextStyle(color: Color(0xFF0755A4), fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (txns.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Chưa có giao dịch nào.',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...txns.take(10).map((t) => _txnTile(t)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransferScreen()),
              ),
              icon: const Icon(Icons.add, color: Color(0xFF0755A4)),
              label: const Text('Thêm giao dịch',
                  style: TextStyle(color: Color(0xFF0755A4))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0755A4)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _txnTile(Transaction t) {
    final isIn = t.type == 'in';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: isIn
            ? const Color(0xFFE3F6EA)
            : const Color(0xFFFFE9E9),
        child: Icon(
          isIn ? Icons.south_west : Icons.north_east,
          color: isIn ? Colors.green : Colors.red,
          size: 20,
        ),
      ),
      title: Text(t.name,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: Text(formatDate(t.date),
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Text(
        '${isIn ? '+' : '-'}${money(t.amount)}',
        style: TextStyle(
          color: isIn ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
