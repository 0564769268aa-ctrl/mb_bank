import 'package:material_ui/material_ui.dart';

import 'app_data.dart';
import 'screens/account_screen.dart';
import 'screens/cards_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/transfer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppData.I.load();
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MB BANK DEMO',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0755A4),
        scaffoldBackgroundColor: const Color(0xFFF3F6FA),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0755A4),
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
      ),
      home: const _RootGate(),
    );
  }
}

/// Chuyển giữa màn đăng nhập và app chính tuỳ theo trạng thái đăng nhập.
class _RootGate extends StatefulWidget {
  const _RootGate();

  @override
  State<_RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<_RootGate> {
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
    return AppData.I.loggedIn
        ? const MainShell()
        : const LoginScreen();
  }
}

/// Khung ứng dụng với thanh điều hướng dưới (4 tab).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _index = 0;

  void switchTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      HomeScreen(onSwitchTab: switchTo),
      const TransferScreen(),
      const CardsScreen(),
      const AccountScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: switchTo,
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Chuyển tiền',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card),
            label: 'Thẻ',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
