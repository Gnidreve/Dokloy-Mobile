import 'package:flutter/widgets.dart';

import '../data/models/invoice.dart';
import '../data/services/invoices_service.dart';
import '../services/auth_service.dart';

class InvoicesStore extends ChangeNotifier with WidgetsBindingObserver {
  InvoicesStore._() {
    WidgetsBinding.instance.addObserver(this);
    _load();
    _subscribe();
  }
  static final instance = InvoicesStore._();

  List<Invoice> items = const [];
  bool loading = true;
  String? error;

  List<Invoice> byCustomer(String customerId) =>
      items.where((i) => i.customerId == customerId).toList();

  List<Invoice> forQuery(String q) {
    if (q.trim().isEmpty) return items;
    final low = q.trim().toLowerCase();
    return items.where((i) => i.title.toLowerCase().contains(low)).toList();
  }

  Future<void> reload() => _load();

  Future<void> _load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await InvoicesService.instance.fetchAll();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _subscribe() {
    AuthService.instance.pb
        .collection('invoices')
        .subscribe('*', (_) => _load());
  }

  void _unsubscribe() {
    try {
      AuthService.instance.pb.collection('invoices').unsubscribe();
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
