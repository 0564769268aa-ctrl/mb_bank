import 'package:material_ui/material_ui.dart';

import '../app_data.dart';
import 'notifications_screen.dart';
import 'savings_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int tab)? onSwitchTab;
  const HomeScreen({super.key, this.onSwitchTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filter = 'all'; // all | in | out
  String _query = '';

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

  List<Transaction> get _filtered {
    final q = _query.trim().toLowerCase();
    return AppData.I.transactions.where((t) {
      if (_filter == 'in' && t.type != 'in') return false;
      if (_filter == 'out' && t.type != 'out') return false;
      if (q.isEmpty) return true;
      return t.name.toLowerCase().contains(q) ||
          t.note.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = AppData.I;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MB BANK DEMO',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined),
                if (data.unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${data.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'MB BANK DEMO',
              applicationVersion: '1.0 DEMO',
              children: const [
                Text(
                  'Ứng dụng mô phỏng độc lập. Không phải ứng dụng MB Bank '
                  'chính thức. Không thực hiện giao dịch thật.',
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _balanceCard(data),
          const SizedBox(height: 16),
          _quickActions(),
          const SizedBox(height: 16),
          _warningBanner(),
          const SizedBox(height: 22),
          _transactionsHeader(data),
          const SizedBox(height: 10),
          _filterRow(),
          const SizedBox(height: 10),
          _searchField(),
          const SizedBox(height: 8),
          _transactionList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editTransaction(),
        backgroundColor: const Color(0xFF0755A4),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm giao dịch'),
      ),
    );
  }

  Widget _balanceCard(AppData data) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0755A4), Color(0xFF1386D5)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TÀI KHOẢN MẪU • DEMO', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 14),
          const Text('SỐ DƯ MÔ PHỎNG', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 5),
          Text(
            money(data.balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text('Tài khoản: ${AppData.accountNumber}',
              style: const TextStyle(color: Colors.white)),
          Text('Chủ tài khoản: ${AppData.accountHolder}',
              style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Text('Số dư khả dụng: ${money(data.availableBalance)}',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _quickActions() {
    final actions = <_QuickAction>[
      _QuickAction(
        icon: Icons.swap_horiz,
        label: 'Chuyển tiền',
        onTap: () => widget.onSwitchTab?.call(1),
      ),
      _QuickAction(
        icon: Icons.phone_iphone,
        label: 'Nạp ĐT',
        onTap: () => _demo('Nạp tiền điện thoại'),
      ),
      _QuickAction(
        icon: Icons.receipt_long,
        label: 'Thanh toán',
        onTap: () => _demo('Thanh toán hóa đơn'),
      ),
      _QuickAction(
        icon: Icons.qr_code,
        label: 'Mã QR',
        onTap: () => _demo('Thanh toán bằng mã QR'),
      ),
      _QuickAction(
        icon: Icons.savings,
        label: 'Tiết kiệm',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SavingsScreen()),
        ),
      ),
      _QuickAction(
        icon: Icons.history,
        label: 'Lịch sử',
        onTap: () => _demo('Xem lịch sử đầy đủ'),
      ),
    ];
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.82,
      children: actions
          .map((a) => InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: a.onTap,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFEAF2FB),
                      child: Icon(a.icon, color: const Color(0xFF0755A4)),
                    ),
                    const SizedBox(height: 6),
                    Text(a.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  void _demo(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature đang là tính năng demo.')),
    );
  }

  Widget _warningBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2D9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'ỨNG DỤNG DEMO – KHÔNG PHẢI NGÂN HÀNG CHÍNH THỨC. '
        'Mọi sử dụng và giao dịch đều giả lập.',
        style: TextStyle(
          color: Color(0xFF805000),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _transactionsHeader(AppData data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'LỊCH SỬ GIAO DỊCH',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text('${data.transactions.length} giao dịch'),
      ],
    );
  }

  Widget _filterRow() {
    return Wrap(
      spacing: 8,
      children: [
        _chip('Tất cả', 'all'),
        _chip('Thu', 'in'),
        _chip('Chi', 'out'),
      ],
    );
  }

  Widget _chip(String label, String value) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: const Color(0xFF0755A4),
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
    );
  }

  Widget _searchField() {
    return TextField(
      onChanged: (v) => setState(() => _query = v),
      decoration: const InputDecoration(
        hintText: 'Tìm theo tên hoặc ghi chú',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _transactionList() {
    final list = _filtered;
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Text(
            AppData.I.transactions.isEmpty
                ? 'Chưa có giao dịch. Nhấn nút + để thêm.'
                : 'Không tìm thấy giao dịch phù hợp.',
          ),
        ),
      );
    }
    return Column(
      children: list.map((item) => _tile(item)).toList(),
    );
  }

  Widget _tile(Transaction item) {
    final isIncome = item.type == 'in';
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isIncome ? const Color(0xFFE3F6EA) : const Color(0xFFFFE9E9),
          child: Icon(
            isIncome ? Icons.south_west : Icons.north_east,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${formatDate(item.date)}\n${item.note}'),
        isThreeLine: true,
        trailing: SizedBox(
          width: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${money(item.amount)}',
                style: TextStyle(
                  color: isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => _editTransaction(item),
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.edit, size: 18),
                    ),
                  ),
                  InkWell(
                    onTap: () => _deleteTransaction(item),
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.delete_outline, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editTransaction([Transaction? old]) async {
    final result = await showDialog<Transaction>(
      context: context,
      builder: (context) => _TransactionDialog(old: old),
    );
    if (result != null) {
      AppData.I.saveTransaction(result, old: old);
    }
  }

  Future<void> _deleteTransaction(Transaction item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: const Text('Bạn muốn xóa giao dịch DEMO này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm == true) AppData.I.deleteTransaction(item.id);
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});
}

/// Hộp thoại thêm/sửa giao dịch.
class _TransactionDialog extends StatefulWidget {
  final Transaction? old;
  const _TransactionDialog({this.old});

  @override
  State<_TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<_TransactionDialog> {
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late String _type;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.old?.name ?? '');
    _amount = TextEditingController(
        text: widget.old == null ? '' : widget.old!.amount.toString());
    _note = TextEditingController(text: widget.old?.note ?? '');
    _type = widget.old?.type ?? 'in';
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.old == null ? 'Thêm giao dịch DEMO' : 'Sửa giao dịch'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Tên giao dịch',
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
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Loại giao dịch',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'in',
                  child: Text('Nhận tiền giả lập'),
                ),
                DropdownMenuItem(
                  value: 'out',
                  child: Text('Chuyển tiền giả lập'),
                ),
              ],
              onChanged: (v) => setState(() => _type = v ?? 'in'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Lưu'),
        ),
      ],
    );
  }

  void _submit() {
    final name = _name.text.trim();
    final amount = int.tryParse(
      _amount.text.replaceAll('.', '').replaceAll(',', ''),
    );
    if (name.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập thông tin hợp lệ')),
      );
      return;
    }
    Navigator.pop(
      context,
      Transaction(
        id: widget.old?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        amount: amount,
        type: _type,
        note: _note.text.trim(),
        date: widget.old?.date ?? DateTime.now(),
      ),
    );
  }
}
