import 'package:flutter/widgets.dart';
import 'package:pocketbase/pocketbase.dart';

import '../data/models/todo_item.dart';
import '../data/services/todos_service.dart';
import '../services/auth_service.dart';

class TodosStore extends ChangeNotifier with WidgetsBindingObserver {
  TodosStore._() {
    WidgetsBinding.instance.addObserver(this);
    _load();
    _subscribe();
  }
  static final instance = TodosStore._();

  List<TodoItem> items = const [];
  bool loading = true;
  String? error;

  Future<void> reload() => _load();

  Future<void> setFinished(String id, {required bool finished}) async {
    // Optimistic update
    items = [
      for (final t in items)
        if (t.id == id)
          TodoItem(id: t.id, keyword: t.keyword, isFinished: finished)
        else
          t,
    ];
    notifyListeners();
    try {
      await TodosService.instance.setFinished(id, finished: finished);
    } catch (_) {
      await _load(); // revert on error
    }
  }

  Future<void> _load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await TodosService.instance.fetchAll();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _applyEvent(RecordSubscriptionEvent e) {
    if (e.record == null) return;
    final list = List<TodoItem>.of(items);
    switch (e.action) {
      case 'create':
        list.add(TodoItem.fromRecord(e.record!));
      case 'update':
        final idx = list.indexWhere((t) => t.id == e.record!.id);
        if (idx >= 0) list[idx] = TodoItem.fromRecord(e.record!);
      case 'delete':
        list.removeWhere((t) => t.id == e.record!.id);
    }
    items = list;
    notifyListeners();
  }

  void _subscribe() {
    AuthService.instance.pb.collection('todo').subscribe('*', _applyEvent);
  }

  void _unsubscribe() {
    try {
      AuthService.instance.pb.collection('todo').unsubscribe();
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
