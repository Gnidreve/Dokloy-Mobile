import 'package:flutter/widgets.dart';
import 'package:pocketbase/pocketbase.dart';

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

  void _applyEvent(RecordSubscriptionEvent e) {
    if (e.record == null) return;
    final list = List<Invoice>.of(items);
    switch (e.action) {
      case 'create':
        list.insert(0, Invoice.fromRecord(e.record!)); // neueste zuerst (-created)
      case 'update':
        final idx = list.indexWhere((i) => i.id == e.record!.id);
        if (idx >= 0) list[idx] = Invoice.fromRecord(e.record!);
      case 'delete':
        list.removeWhere((i) => i.id == e.record!.id);
    }
    items = list;
    notifyListeners();
  }

  void _subscribe() {
    AuthService.instance.pb.collection('invoices').subscribe('*', _applyEvent);
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
      _load();
    } else if (state == AppLifecycleState.paused) {
      _unsubscribe();
    }
  }
}
