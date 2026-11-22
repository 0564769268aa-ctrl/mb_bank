import 'package:material_ui/material_ui.dart';

import '../app_data.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  int _months = 6;

  @override
  void initState() {
    super.initState();
    AppData.I.addListener(_onChange);
  }

  @override
  void dispose() {
    AppData.I.removeListener(_onChange);
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  double get _rate => AppData.rateFor(_months);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tiền gửi tiết kiệm')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _summary(),
          const SizedBox(height: 16),
          _form(),
          const SizedBox(height: 18),
          const Text('Khoản gửi hiện có',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...AppData.I.savings.map(_deposit),
          if (AppData.I.savings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('Chưa có khoản gửi nào.')),
            ),
          const SizedBox(height: 12),
          const Text(
            'DEMO: tiền gửi chỉ mô phỏng trên máy, không tính lãi thật.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _summary() {
    return Container(
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
          const Text('Số dư khả dụng', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(
            money(AppData.I.availableBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('Đang gửi tiết kiệm: ${money(AppData.I.savings.fold<int>(0, (s, d) => s + d.amount))}',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _form() {
    final amount = int.tryParse(
      _amount.text.replaceAll('.', '').replaceAll(',', ''),
    );
    final interest = (amount == null || amount <= 0)
        ? 0.0
        : amount * _rate * _months / 12 / 100;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Gửi tiết kiệm mới',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Tên khoản gửi',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Số tiền (VNĐ)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _months,
            decoration: const InputDecoration(
              labelText: 'Kỳ hạn',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 tháng')),
              DropdownMenuItem(value: 3, child: Text('3 tháng')),
              DropdownMenuItem(value: 6, child: Text('6 tháng')),
              DropdownMenuItem(value: 12, child: Text('12 tháng')),
            ],
            onChanged: (v) => setState(() => _months = v ?? 6),
          ),
          const SizedBox(height: 10),
          Text('Lãi suất: ${_rate.toStringAsFixed(1)}%/năm · Dự kiến lãi: ${money(interest.round())}',
              style: const TextStyle(color: Colors.black54, fontSize: 13)),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Gửi tiết kiệm'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final name = _name.text.trim().isEmpty ? 'Tiết kiệm ${AppData.termLabel(_months)}' : _name.text.trim();
    final amount = int.tryParse(
      _amount.text.replaceAll('.', '').replaceAll(',', ''),
    );
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')));
      return;
    }
    if (amount > AppData.I.availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Số dư khả dụng không đủ')));
      return;
    }
    AppData.I.addSavings(name: name, amount: amount, months: _months);
    _name.clear();
    _amount.clear();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi tiết kiệm thành công')));
  }

  Widget _deposit(SavingsDeposit d) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE3F6EA),
          child: Icon(Icons.savings, color: Color(0xFF0755A4)),
        ),
        title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${money(d.amount)} · ${AppData.termLabel(d.months)} · '
          'lãi ${d.rate.toStringAsFixed(1)}%/năm\n'
          'Dự kiến nhận: ${money((d.amount + d.interest).round())} · ${formatDate(d.date)}',
        ),
        isThreeLine: true,
        trailing: TextButton(
          onPressed: () => _confirmClose(d),
          child: const Text('Tất toán'),
        ),
      ),
    );
  }

  Future<void> _confirmClose(SavingsDeposit d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tất toán tiết kiệm?'),
        content: Text('Trả lại ${money(d.amount)} vào tài khoản?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Tất toán')),
        ],
      ),
    );
    if (ok == true) {
      AppData.I.closeSavings(d.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã tất toán và hoàn tiền')));
      }
    }
  }
}
