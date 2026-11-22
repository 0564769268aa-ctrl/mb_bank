import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../app_data.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final Set<String> _revealed = {};

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

  void _addDemoCard() {
    final rnd = Random();
    final number = '9704${rnd.nextInt(90000000) + 10000000}${rnd.nextInt(9000) + 1000}';
    final month = (rnd.nextInt(12) + 1).toString().padLeft(2, '0');
    final year = (rnd.nextInt(6) + 28).toString();
    AppData.I.addCard(DemoCard(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      holder: AppData.accountHolder,
      number: number,
      expiry: '$month/$year',
      type: rnd.nextBool() ? 'DEBIT' : 'CREDIT',
      color: [0xFF0755A4, 0xFF1386D5, 0xFF1B8A5A, 0xFF6A1B9A][rnd.nextInt(4)],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thẻ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...AppData.I.cards.map(_card),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addDemoCard,
            icon: const Icon(Icons.credit_card),
            label: const Text('Thêm thẻ demo'),
          ),
          const SizedBox(height: 16),
          const Text(
            'DEMO: các thẻ đều là số liệu mô phỏng, không thể dùng để thanh toán thật.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _card(DemoCard c) {
    final show = _revealed.contains(c.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(c.color), Color(c.color).withValues(alpha: 0.75)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('MB BANK',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(c.type, style: const TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text(
            show ? _group(c.number) : c.masked,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chủ thẻ', style: TextStyle(color: Colors.white60, fontSize: 10)),
                  Text(c.holder, style: const TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Hết hạn', style: TextStyle(color: Colors.white60, fontSize: 10)),
                  Text(c.expiry, style: const TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
              IconButton(
                icon: Icon(show ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                onPressed: () => setState(() {
                  if (show) {
                    _revealed.remove(c.id);
                  } else {
                    _revealed.add(c.id);
                  }
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _group(String number) {
    return number.replaceAllMapped(RegExp(r'.{4}'), (m) => '${m[0]} ').trim();
  }
}
