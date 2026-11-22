import 'package:material_ui/material_ui.dart';

import '../app_data.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _accountController = TextEditingController(text: AppData.accountNumber);
  final _pinController = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _accountController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _login() {
    final pin = _pinController.text.trim();
    if (_accountController.text.trim().isEmpty) {
      setState(() => _error = 'Vui lòng nhập số tài khoản');
      return;
    }
    if (pin.length != 6 || int.tryParse(pin) == null) {
      setState(() => _error = 'Mã PIN phải gồm 6 chữ số');
      return;
    }
    setState(() => _error = null);
    AppData.I.login();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Container(
                width: 84,
                height: 84,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFF0755A4),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  'MB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'MB BANK DEMO',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ứng dụng mô phỏng · không phải ngân hàng thật',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 36),
              TextField(
                controller: _accountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số tài khoản',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: _obscure,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Mã PIN (6 chữ số)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _login,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Đăng nhập', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2D9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'DEMO: nhập số tài khoản bất kỳ và 6 chữ số bất kỳ để vào app. '
                  'Dữ liệu lưu trên máy, không thực hiện giao dịch thật.',
                  style: TextStyle(color: Color(0xFF805000), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
