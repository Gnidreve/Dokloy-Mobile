import 'package:flutter/widgets.dart';
import 'package:pocketbase/pocketbase.dart';

import '../data/models/email_item.dart';
import '../data/services/emails_service.dart';
import '../services/auth_service.dart';

class EmailsStore extends ChangeNotifier with WidgetsBindingObserver {
  EmailsStore._() {
    WidgetsBinding.instance.addObserver(this);
    _load();
    _subscribe();
  }
  static final instance = EmailsStore._();

  List<EmailItem> items = const [];
  bool loading = true;
  String? error;

  List<EmailItem> byCustomer(String customerId) =>
      items.where((email) => email.customerId == customerId).toList();

  List<EmailItem> forQuery(String q) {
    if (q.trim().isEmpty) return items;
    final low = q.trim().toLowerCase();
    return items.where((email) {
      return email.subject.toLowerCase().contains(low) ||
          email.from.toLowerCase().contains(low) ||
          email.to.toLowerCase().contains(low);
    }).toList();
  }

  Future<void> reload() => _load();

  Future<void> _load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await EmailsService.instance.fetchAll();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _applyEvent(RecordSubscriptionEvent e) {
    if (e.record == null) return;
    final list = List<EmailItem>.of(items);
    switch (e.action) {
      case 'create':
        list.insert(0, EmailItem.fromRecord(e.record!));
      case 'update':
        final idx = list.indexWhere((item) => item.id == e.record!.id);
        if (idx >= 0) list[idx] = EmailItem.fromRecord(e.record!);
      case 'delete':
        list.removeWhere((item) => item.id == e.record!.id);
    }
    items = list;
    notifyListeners();
  }

  void _subscribe() {
    AuthService.instance.pb.collection('emails').subscribe('*', _applyEvent);
  }

  void _unsubscribe() {
    try {
      AuthService.instance.pb.collection('emails').unsubscribe();
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
