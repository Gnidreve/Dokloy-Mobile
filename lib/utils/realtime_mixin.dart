import 'package:flutter/widgets.dart';

import '../services/auth_service.dart';

/// Fügt einer StatefulWidget-State-Klasse PocketBase-Realtime hinzu.
///
/// Verwendung:
/// ```dart
/// class _MyPageState extends State<MyPage>
///     with WidgetsBindingObserver, RealtimeMixin<MyPage> {
///
///   @override
///   String get realtimeCollection => 'my_collection';
///
///   @override
///   void onRealtimeChange() => _load(silent: true);
///
///   @override
///   void initState() {
///     super.initState();
///     _load();
///     initRealtime();
///   }
///
///   @override
///   void dispose() {
///     disposeRealtime();
///     super.dispose();
///   }
/// }
/// ```
mixin RealtimeMixin<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  /// Name der PocketBase-Collection, auf die subscribed wird.
  String get realtimeCollection;

  /// Wird aufgerufen wenn sich ein Datensatz ändert (create/update/delete).
  void onRealtimeChange();

  void initRealtime() {
    WidgetsBinding.instance.addObserver(this);
    _subscribe();
  }

  void disposeRealtime() {
    WidgetsBinding.instance.removeObserver(this);
    _unsubscribe();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // SSE-Verbindung kann nach Hintergrund unterbrochen sein → neu aufbauen
      _unsubscribe();
      _subscribe();
    } else if (state == AppLifecycleState.paused) {
      _unsubscribe();
    }
  }

  void _subscribe() {
    AuthService.instance.pb
        .collection(realtimeCollection)
        .subscribe('*', (_) {
          if (mounted) onRealtimeChange();
        });
  }

  void _unsubscribe() {
    try {
      AuthService.instance.pb
          .collection(realtimeCollection)
          .unsubscribe();
    } catch (_) {}
  }
}
