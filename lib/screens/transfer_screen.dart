import 'package:material_ui/material_ui.dart';

import '../app_data.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _name = TextEditingController();
  final _account = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    AppData.I.addListener(_onChange);
  }

  @override
  void dispose() {
    AppData.I.removeListener(_onChange);
    _name.dispose();
    _account.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  void _submit() {
    final name = _name.text.trim();
    final account = _account.text.trim();
    final amount = int.tryParse(
      _amount.text.replaceAll('.', '').replaceAll(',', ''),
    );
    if (name.isEmpty) {
      _toast('Vui lòng nhập tên người nhận');
      return;
    }
    if (account.isEmpty) {
      _toast('Vui lòng nhập số tài khoản người nhận');
      return;
    }
    if (amount == null || amount <= 0) {
      _toast('Số tiền không hợp lệ');
      return;
    }
    if (amount > AppData.I.availableBalance) {
      _toast('Số dư khả dụng không đủ');
      return;
    }

    setState(() => _sending = true);
    AppData.I.transfer(
      recipientName: name,
      recipientAccount: account,
      amount: amount,
      note: _note.text.trim(),
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _sending = false);
      _showSuccess(name, account, amount);
      _name.clear();
      _account.clear();
      _amount.clear();
      _note.clear();
    });
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showSuccess(String name, String account, int amount) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Chuyển tiền thành công'),
        content: Text(
          'Đã chuyển ${money(amount)} đến $name\n(STK $account).\n'
          'Đây là giao dịch mô phỏng, không thật.',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chuyển tiền')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0755A4), Color(0xFF1386D5)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Số dư khả dụng',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                Text(
                  money(AppData.I.availableBalance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Người nhận',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Tên người nhận',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _account,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Số tài khoản người nhận',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_balance_outlined),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Số tiền', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Số tiền (VNĐ)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            decoration: const InputDecoration(
              labelText: 'Lời nhắn',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.chat_bubble_outline),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _sending ? null : _submit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
            label: const Text('Xác nhận chuyển tiền', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 14),
          const Text(
            'DEMO: giao dịch chỉ ghi vào lịch sử trên máy, không chuyển tiền thật.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
