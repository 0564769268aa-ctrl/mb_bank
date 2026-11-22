import 'package:material_ui/material_ui.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0755A4),
        foregroundColor: Colors.white,
        title: const Text('Ưu đãi', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _banner('Hoàn tiền 10%', 'Thanh toán qua MB Pay', Icons.percent, const Color(0xFF0755A4)),
          _banner('Miễn phí chuyển tiền', 'Chuyển tiền 24/7 không phí', Icons.swap_horiz, Colors.green),
          _banner('Lãi suất ưu đãi', 'Gửi tiết kiệm online 7.2%/năm', Icons.savings, Colors.orange),
          _banner('Vay nhanh 0%', 'Lãi suất 0% tháng đầu tiên', Icons.account_balance, Colors.purple),
        ],
      ),
    );
  }

  Widget _banner(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}
