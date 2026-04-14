import 'package:flutter/widgets.dart';

import '../data/models/contract.dart';
import '../data/services/contracts_service.dart';
import '../services/auth_service.dart';

class ContractsStore extends ChangeNotifier with WidgetsBindingObserver {
  ContractsStore._() {
    WidgetsBinding.instance.addObserver(this);
    _load();
    _subscribe();
  }
  static final instance = ContractsStore._();

  List<Contract> items = const [];
  bool loading = true;
  String? error;

  List<Contract> byCustomer(String customerId) =>
      items.where((c) => c.customerId == customerId).toList();

  Future<void> reload() => _load();

  Future<void> _load() async {
    loading = true; error = null; notifyListeners();
    try {
      items = await ContractsService.instance.fetchAll();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false; notifyListeners();
    }
  }

  void _subscribe() {
    AuthService.instance.pb
        .collection('contracts')
        .subscribe('*', (_) => _load());
  }

  void _unsubscribe() {
    try {
      AuthService.instance.pb.collection('contracts').unsubscribe();
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
