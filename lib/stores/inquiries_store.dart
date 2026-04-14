import 'package:flutter/widgets.dart';

import '../data/models/inquiry.dart';
import '../data/services/inquiries_service.dart';
import '../services/auth_service.dart';

class InquiriesStore extends ChangeNotifier with WidgetsBindingObserver {
  InquiriesStore._() {
    WidgetsBinding.instance.addObserver(this);
    _load();
    _subscribe();
  }
  static final instance = InquiriesStore._();

  List<Inquiry> items = const [];
  bool loading = true;
  String? error;

  List<Inquiry> byCustomer(String customerId) =>
      items.where((i) => i.customerId == customerId).toList();

  List<Inquiry> forQuery(String q) {
    if (q.trim().isEmpty) return items;
    final low = q.trim().toLowerCase();
    return items
        .where((i) =>
            i.name.toLowerCase().contains(low) ||
            i.subject.toLowerCase().contains(low) ||
            i.email.toLowerCase().contains(low))
        .toList();
  }

  Future<void> reload() => _load();

  Future<void> _load() async {
    loading = true; error = null; notifyListeners();
    try {
      items = await InquiriesService.instance.fetchAll();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false; notifyListeners();
    }
  }

  void _subscribe() {
    AuthService.instance.pb
        .collection('inquiries')
        .subscribe('*', (_) => _load());
  }

  void _unsubscribe() {
    try {
      AuthService.instance.pb.collection('inquiries').unsubscribe();
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
