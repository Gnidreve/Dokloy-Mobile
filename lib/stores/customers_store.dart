import 'package:flutter/widgets.dart';

import '../data/models/customer.dart';
import '../data/services/customers_service.dart';
import '../services/auth_service.dart';

class CustomersStore extends ChangeNotifier with WidgetsBindingObserver {
  CustomersStore._() {
    WidgetsBinding.instance.addObserver(this);
    _load();
    _subscribe();
  }
  static final instance = CustomersStore._();

  List<Customer> items = const [];
  bool loading = true;
  String? error;

  List<Customer> forQuery(String q) {
    if (q.trim().isEmpty) return items;
    final low = q.trim().toLowerCase();
    return items
        .where((c) =>
            c.name.toLowerCase().contains(low) ||
            c.street.toLowerCase().contains(low) ||
            c.town.toLowerCase().contains(low))
        .toList();
  }

  Future<void> reload() => _load();

  Future<void> _load() async {
    loading = true; error = null; notifyListeners();
    try {
      items = await CustomersService.instance.fetchAll();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false; notifyListeners();
    }
  }

  void _subscribe() {
    AuthService.instance.pb
        .collection('customers')
        .subscribe('*', (_) => _load());
  }

  void _unsubscribe() {
    try {
      AuthService.instance.pb.collection('customers').unsubscribe();
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _unsubscribe();
      _subscribe();
    } else if (state == AppLifecycleState.paused) {
      _unsubscribe();
    }
  }
}
