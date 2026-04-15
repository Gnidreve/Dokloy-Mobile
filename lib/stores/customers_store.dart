import 'package:flutter/widgets.dart';
import 'package:pocketbase/pocketbase.dart';

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
        .where(
          (c) =>
              c.name.toLowerCase().contains(low) ||
              c.street.toLowerCase().contains(low) ||
              c.town.toLowerCase().contains(low),
        )
        .toList();
  }

  Future<void> reload() => _load();

  Future<void> _load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await CustomersService.instance.fetchAll();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Patcht die In-Memory-Liste ohne Netzwerk-Request.
  /// Nur bei echten Fehlern oder initialem Laden wird _load() gerufen.
  void _applyEvent(RecordSubscriptionEvent e) {
    if (e.record == null) return;
    final list = List<Customer>.of(items);
    switch (e.action) {
      case 'create':
        // Alphabetisch einsortieren (passend zum Server-Sort 'name')
        final newItem = Customer.fromRecord(e.record!);
        final idx = list.indexWhere(
          (c) =>
              c.name.toLowerCase().compareTo(newItem.name.toLowerCase()) > 0,
        );
        if (idx >= 0) {
          list.insert(idx, newItem);
        } else {
          list.add(newItem);
        }
      case 'update':
        final idx = list.indexWhere((c) => c.id == e.record!.id);
        if (idx >= 0) list[idx] = Customer.fromRecord(e.record!);
      case 'delete':
        list.removeWhere((c) => c.id == e.record!.id);
    }
    items = list;
    notifyListeners();
  }

  void _subscribe() {
    AuthService.instance.pb.collection('customers').subscribe('*', _applyEvent);
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
      _load(); // einmalig synchronisieren nach Hintergrund
    } else if (state == AppLifecycleState.paused) {
      _unsubscribe();
    }
  }
}
