import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:pocketbase/pocketbase.dart';

import '../data/models/customer.dart';
import '../data/models/inquiry.dart';
import '../data/models/invoice.dart';
import '../data/services/customers_service.dart';
import '../data/services/inquiries_service.dart';
import '../data/services/invoices_service.dart';
import 'auth_service.dart';

/// Globaler, reaktiver Datenspeicher.
///
/// - Initialisiert sich nach dem Login einmalig (`init()`).
/// - Subscribed alle Collections auf PocketBase-Realtime.
/// - Handhabt App-Lifecycle: unsubscribed bei Pause, resubscribed bei Resume.
/// - Neue Inquiries werden über [newInquiries] als Stream ausgeliefert.
class SyncService with WidgetsBindingObserver {
  SyncService._();
  static final instance = SyncService._();

  // ── Data ───────────────────────────────────────────────────────────────────
  List<Customer> customers = const [];
  List<Inquiry>  inquiries = const [];
  List<Invoice>  invoices  = const [];
  bool ready = false;

  // ── Listeners ──────────────────────────────────────────────────────────────
  final _listeners = <VoidCallback>[];
  void addListener(VoidCallback l) => _listeners.add(l);
  void removeListener(VoidCallback l) => _listeners.remove(l);
  void _notify() {
    for (final l in List.of(_listeners)) { l(); }
  }

  // ── New-Inquiry-Stream (für Notification-Banner) ───────────────────────────
  // ignore: close_sinks
  final _newInquiryCtrl = StreamController<Inquiry>.broadcast();
  Stream<Inquiry> get newInquiries => _newInquiryCtrl.stream;

  bool _initialized = false;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);
    await _fetchAll();
    _subscribeAll();
  }

  Future<void> refresh() => _fetchAll();

  void shutdown() {
    if (!_initialized) return;
    _initialized = false;
    WidgetsBinding.instance.removeObserver(this);
    _unsubscribeAll();
    customers = const [];
    inquiries = const [];
    invoices  = const [];
    ready = false;
    _notify();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // SSE-Verbindung nach Hintergrund wieder aufbauen + Daten aktualisieren
      _unsubscribeAll();
      _subscribeAll();
      _fetchAll();
    } else if (state == AppLifecycleState.paused) {
      _unsubscribeAll();
    }
  }

  // ── Fetch ──────────────────────────────────────────────────────────────────
  Future<void> _fetchAll() async {
    try {
      final results = await Future.wait([
        CustomersService.instance.fetchAll(),
        InquiriesService.instance.fetchAll(),
        InvoicesService.instance.fetchAll(),
      ]);
      customers = results[0] as List<Customer>;
      inquiries = results[1] as List<Inquiry>;
      invoices  = results[2] as List<Invoice>;
      ready = true;
      _notify();
    } catch (_) {}
  }

  // ── Subscribe ──────────────────────────────────────────────────────────────
  void _subscribeAll() {
    _subscribeCollection<Customer>(
      collection: 'customers',
      fromRecord: Customer.fromRecord,
      getList: () => customers,
      setList: (v) => customers = v,
      getId: (c) => c.id,
    );
    _subscribeCollection<Inquiry>(
      collection: 'inquiries',
      fromRecord: Inquiry.fromRecord,
      getList: () => inquiries,
      setList: (v) => inquiries = v,
      getId: (i) => i.id,
      onCreate: _newInquiryCtrl.add,
    );
    _subscribeCollection<Invoice>(
      collection: 'invoices',
      fromRecord: Invoice.fromRecord,
      getList: () => invoices,
      setList: (v) => invoices = v,
      getId: (i) => i.id,
    );
  }

  void _subscribeCollection<T>({
    required String collection,
    required T Function(RecordModel) fromRecord,
    required List<T> Function() getList,
    required void Function(List<T>) setList,
    required String Function(T) getId,
    void Function(T)? onCreate,
  }) {
    try {
      AuthService.instance.pb.collection(collection).subscribe('*', (e) {
        if (e.record == null) return;
        final list = List<T>.of(getList());
        final id = e.record!.id;
        switch (e.action) {
          case 'create':
            final item = fromRecord(e.record!);
            list.insert(0, item);
            onCreate?.call(item);
          case 'update':
            final idx = list.indexWhere((x) => getId(x) == id);
            if (idx >= 0) list[idx] = fromRecord(e.record!);
          case 'delete':
            list.removeWhere((x) => getId(x) == id);
        }
        setList(list);
        _notify();
      });
    } catch (_) {}
  }

  void _unsubscribeAll() {
    for (final c in ['customers', 'inquiries', 'invoices']) {
      try {
        AuthService.instance.pb.collection(c).unsubscribe();
      } catch (_) {}
    }
  }
}
