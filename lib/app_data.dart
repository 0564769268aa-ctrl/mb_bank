import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Một giao dịch (thu/chi) trong ứng dụng demo.
class Transaction {
  final String id;
  final String name;
  final int amount;
  final String type; // 'in' (thu) | 'out' (chi)
  final String note;
  final DateTime date;

  const Transaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'type': type,
        'note': note,
        'date': date.toIso8601String(),
      };

  factory Transaction.fromJson(Map<String, dynamic> j) => Transaction(
        id: j['id'] as String,
        name: j['name'] as String,
        amount: (j['amount'] as num).toInt(),
        type: j['type'] as String,
        note: j['note'] as String,
        date: DateTime.parse(j['date'] as String),
      );
}

/// Một thẻ ngân hàng demo.
class DemoCard {
  final String id;
  final String holder;
  final String number; // 16 chữ số
  final String expiry; // MM/YY
  final String type; // 'DEBIT' | 'CREDIT'
  final int color; // mã màu gradient

  const DemoCard({
    required this.id,
    required this.holder,
    required this.number,
    required this.expiry,
    required this.type,
    required this.color,
  });

  String get masked => '•••• •••• •••• ${number.substring(number.length - 4)}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'holder': holder,
        'number': number,
        'expiry': expiry,
        'type': type,
        'color': color,
      };

  factory DemoCard.fromJson(Map<String, dynamic> j) => DemoCard(
        id: j['id'] as String,
        holder: j['holder'] as String,
        number: j['number'] as String,
        expiry: j['expiry'] as String,
        type: j['type'] as String,
        color: (j['color'] as num).toInt(),
      );
}

/// Một thông báo trong ứng dụng demo.
class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final bool read;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.read,
  });

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        title: title,
        body: body,
        date: date,
        read: read ?? this.read,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'date': date.toIso8601String(),
        'read': read,
      };

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        date: DateTime.parse(j['date'] as String),
        read: j['read'] as bool,
      );
}

/// Một khoản tiền gửi tiết kiệm demo.
class SavingsDeposit {
  final String id;
  final String name;
  final int amount;
  final int months;
  final double rate; // lãi suất năm (%)
  final DateTime date;

  const SavingsDeposit({
    required this.id,
    required this.name,
    required this.amount,
    required this.months,
    required this.rate,
    required this.date,
  });

  double get interest => amount * rate * months / 12 / 100;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'months': months,
        'rate': rate,
        'date': date.toIso8601String(),
      };

  factory SavingsDeposit.fromJson(Map<String, dynamic> j) => SavingsDeposit(
        id: j['id'] as String,
        name: j['name'] as String,
        amount: (j['amount'] as num).toInt(),
        months: (j['months'] as num).toInt(),
        rate: (j['rate'] as num).toDouble(),
        date: DateTime.parse(j['date'] as String),
      );
}

/// Nguồn dữ liệu chung của app demo.
/// Dùng ChangeNotifier để các màn hình tự vẽ lại khi dữ liệu thay đổi.
class AppData extends ChangeNotifier {
  AppData._();
  static final AppData I = AppData._();

  static const int openingBalance = 10000000;
  static const String accountNumber = '0000000000';
  static const String accountHolder = 'NGUYEN VAN DEMO';

  List<Transaction> transactions = [];
  List<DemoCard> cards = [];
  List<AppNotification> notifications = [];
  List<SavingsDeposit> savings = [];
  bool loggedIn = false;

  int get balance => openingBalance +
      transactions.fold<int>(0, (s, t) => s + (t.type == 'in' ? t.amount : -t.amount));

  /// Số dư khả dụng = số dư - tiền đang gửi tiết kiệm.
  int get availableBalance =>
      balance - savings.fold<int>(0, (s, d) => s + d.amount);

  int get unreadCount => notifications.where((n) => !n.read).length;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();

    final tj = p.getString('demo_transactions');
    if (tj != null) {
      transactions = (jsonDecode(tj) as List)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final cj = p.getString('demo_cards');
    if (cj != null) {
      cards = (jsonDecode(cj) as List)
          .map((e) => DemoCard.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (cards.isEmpty) cards = _defaultCards();

    final nj = p.getString('demo_notifications');
    if (nj != null) {
      notifications = (jsonDecode(nj) as List)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (notifications.isEmpty) notifications = _defaultNotifications();

    final sj = p.getString('demo_savings');
    if (sj != null) {
      savings = (jsonDecode(sj) as List)
          .map((e) => SavingsDeposit.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _saveTransactions() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      'demo_transactions',
      jsonEncode(transactions.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _saveCards() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      'demo_cards',
      jsonEncode(cards.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _saveNotifications() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      'demo_notifications',
      jsonEncode(notifications.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _saveSavings() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      'demo_savings',
      jsonEncode(savings.map((e) => e.toJson()).toList()),
    );
  }

  void login() {
    loggedIn = true;
    notifyListeners();
  }

  void logout() {
    loggedIn = false;
    notifyListeners();
  }

  /// Thêm mới hoặc cập nhật giao dịch.
  void saveTransaction(Transaction t, {Transaction? old}) {
    if (old == null) {
      transactions.insert(0, t);
    } else {
      final i = transactions.indexWhere((e) => e.id == old.id);
      if (i != -1) transactions[i] = t;
    }
    _saveTransactions();
    notifyListeners();
  }

  void deleteTransaction(String id) {
    transactions.removeWhere((e) => e.id == id);
    _saveTransactions();
    notifyListeners();
  }

  /// Chuyển tiền đến người nhận. Trả về true nếu thành công.
  bool transfer({
    required String recipientName,
    required String recipientAccount,
    required int amount,
    String note = '',
  }) {
    if (amount <= 0 || amount > availableBalance) return false;
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();
    final message = note.isEmpty
        ? 'Đến STK $recipientAccount'
        : '$note · Đến STK $recipientAccount';
    transactions.insert(
      0,
      Transaction(
        id: id,
        name: 'Chuyển tiền đến $recipientName',
        amount: amount,
        type: 'out',
        note: message,
        date: now,
      ),
    );
    notifications.insert(
      0,
      AppNotification(
        id: id,
        title: 'Chuyển tiền thành công',
        body:
            'Đã chuyển ${money(amount)} đến $recipientName (STK $recipientAccount).',
        date: now,
        read: false,
      ),
    );
    _saveTransactions();
    _saveNotifications();
    notifyListeners();
    return true;
  }

  /// Nhận tiền giả lập (thu).
  void receiveMoney({required String from, required int amount, String note = ''}) {
    if (amount <= 0) return;
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();
    transactions.insert(
      0,
      Transaction(
        id: id,
        name: 'Nhận tiền từ $from',
        amount: amount,
        type: 'in',
        note: note,
        date: now,
      ),
    );
    notifications.insert(
      0,
      AppNotification(
        id: id,
        title: 'Nhận tiền thành công',
        body: '$from đã chuyển đến bạn ${money(amount)}.',
        date: now,
        read: false,
      ),
    );
    _saveTransactions();
    _saveNotifications();
    notifyListeners();
  }

  void addCard(DemoCard c) {
    cards.insert(0, c);
    _saveCards();
    notifyListeners();
  }

  void markAllNotificationsRead() {
    notifications = notifications.map((e) => e.copyWith(read: true)).toList();
    _saveNotifications();
    notifyListeners();
  }

  void addSavings({
    required String name,
    required int amount,
    required int months,
  }) {
    if (amount <= 0 || amount > availableBalance) return;
    final rate = rateFor(months);
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();
    savings.insert(
      0,
      SavingsDeposit(
        id: id,
        name: name,
        amount: amount,
        months: months,
        rate: rate,
        date: now,
      ),
    );
    notifications.insert(
      0,
      AppNotification(
        id: id,
        title: 'Gửi tiết kiệm thành công',
        body: 'Đã gửi ${money(amount)} kỳ hạn ${termLabel(months)}, lãi ${rate.toStringAsFixed(1)}%/năm.',
        date: now,
        read: false,
      ),
    );
    _saveSavings();
    _saveNotifications();
    notifyListeners();
  }

  void closeSavings(String id) {
    final dep = savings.firstWhere((e) => e.id == id);
    savings.removeWhere((e) => e.id == id);
    notifications.insert(
      0,
      AppNotification(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: 'Tất toán tiết kiệm',
        body: 'Đã tất toán "${dep.name}", trả lại ${money(dep.amount)} vào tài khoản.',
        date: DateTime.now(),
        read: false,
      ),
    );
    _saveSavings();
    _saveNotifications();
    notifyListeners();
  }

  static double rateFor(int months) {
    switch (months) {
      case 1:
        return 3.0;
      case 3:
        return 4.0;
      case 6:
        return 5.5;
      case 12:
        return 7.0;
      default:
        return 4.0;
    }
  }

  static String termLabel(int months) {
    switch (months) {
      case 1:
        return '1 tháng';
      case 3:
        return '3 tháng';
      case 6:
        return '6 tháng';
      case 12:
        return '12 tháng';
      default:
        return '$months tháng';
    }
  }

  List<DemoCard> _defaultCards() => [
        DemoCard(
          id: 'card1',
          holder: accountHolder,
          number: '9704000000000001',
          expiry: '12/29',
          type: 'DEBIT',
          color: 0xFF0755A4,
        ),
        DemoCard(
          id: 'card2',
          holder: accountHolder,
          number: '9704000000000002',
          expiry: '06/28',
          type: 'CREDIT',
          color: 0xFF1386D5,
        ),
      ];

  List<AppNotification> _defaultNotifications() => [
        AppNotification(
          id: 'welcome',
          title: 'Chào mừng đến MB BANK DEMO',
          body: 'Đây là ứng dụng mô phỏng. Mọi giao dịch đều giả lập.',
          date: DateTime.now(),
          read: false,
        ),
      ];
}

/// Định dạng số tiền theo kiểu Việt Nam: 10000000 -> "10.000.000 đ".
String money(int value) {
  final digits = value.abs().toString();
  final formatted = digits.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return '${value < 0 ? '-' : ''}$formatted đ';
}

/// Định dạng ngày: 05/08/2025 14:30.
String formatDate(DateTime d) {
  String p(int v) => v.toString().padLeft(2, '0');
  return '${p(d.day)}/${p(d.month)}/${d.year} ${p(d.hour)}:${p(d.minute)}';
}
