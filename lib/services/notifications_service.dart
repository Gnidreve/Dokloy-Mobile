import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'auth_service.dart';

class NotificationsService extends ChangeNotifier {
  NotificationsService._();

  static final instance = NotificationsService._();

  bool _bootstrapped = false;
  bool _firebaseReady = false;
  bool _loading = false;
  bool _enabled = false;
  bool _systemPermissionGranted = false;
  String? _deviceToken;
  String? _serverToken;
  String? _lastError;
  StreamSubscription<String>? _tokenRefreshSubscription;

  bool get isSupported => !kIsWeb && Platform.isAndroid;
  bool get loading => _loading;
  bool get enabled => _enabled;
  String? get deviceToken => _deviceToken;
  String? get serverToken => _serverToken;
  String? get lastError => _lastError;

  String get statusText {
    if (!isSupported) {
      return 'Push-Benachrichtigungen sind aktuell nur auf Android vorbereitet.';
    }
    if (_loading) {
      return 'Benachrichtigungsstatus wird geladen …';
    }
    if (!_firebaseReady) {
      return 'Firebase ist noch nicht bereit. Lege zuerst die google-services.json unter android/app/ ab.';
    }
    if (!_systemPermissionGranted) {
      return 'Android-Berechtigung ist noch nicht freigegeben.';
    }
    if ((_serverToken ?? '').isEmpty) {
      return 'Berechtigung vorhanden, aber aktuell ist noch kein Device-Token im Backend gespeichert.';
    }
    return 'Benachrichtigungen sind aktiv und der aktuelle Device-Token ist im Backend hinterlegt.';
  }

  Future<void> bootstrap() async {
    if (_bootstrapped || !isSupported) return;
    _bootstrapped = true;

    await _ensureFirebaseReady();
    if (!_firebaseReady) return;

    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
        .listen((token) => unawaited(_handleTokenRefresh(token)));
  }

  @override
  void dispose() {
    _tokenRefreshSubscription?.cancel();
    super.dispose();
  }

  Future<void> refreshStatus() async {
    if (!isSupported) {
      _loading = false;
      _enabled = false;
      _systemPermissionGranted = false;
      _deviceToken = null;
      _serverToken = null;
      _lastError = null;
      notifyListeners();
      return;
    }

    _loading = true;
    _lastError = null;
    notifyListeners();

    try {
      await bootstrap();
      final record = await AuthService.instance.refreshCurrentUser();
      _serverToken = _readDeviceToken(record.data['device_token']);

      if (!_firebaseReady) {
        _enabled = false;
        return;
      }

      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      _systemPermissionGranted = _isAuthorized(settings.authorizationStatus);
      _deviceToken = _systemPermissionGranted
          ? await FirebaseMessaging.instance.getToken()
          : null;

      if (_systemPermissionGranted &&
          (_serverToken ?? '').isNotEmpty &&
          (_deviceToken ?? '').isNotEmpty &&
          _serverToken != _deviceToken) {
        await _pushTokenToServer(_deviceToken!);
        _serverToken = _deviceToken;
      }

      _enabled = _systemPermissionGranted && (_serverToken ?? '').isNotEmpty;
    } catch (e) {
      _enabled = false;
      _lastError = _friendlyError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> setEnabled(bool value) async {
    if (!isSupported) return;

    _loading = true;
    _lastError = null;
    notifyListeners();

    try {
      await bootstrap();
      if (!_firebaseReady) {
        throw StateError(
          'Firebase ist nicht initialisiert. Bitte zuerst google-services.json hinterlegen.',
        );
      }

      if (value) {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        _systemPermissionGranted = _isAuthorized(settings.authorizationStatus);
        if (!_systemPermissionGranted) {
          _enabled = false;
          return;
        }

        final token = await FirebaseMessaging.instance.getToken();
        if (token == null || token.isEmpty) {
          throw StateError(
            'Es konnte kein Device-Token von Firebase gelesen werden.',
          );
        }

        _deviceToken = token;
        await _pushTokenToServer(token);
        _serverToken = token;
        _enabled = true;
      } else {
        await _pushTokenToServer('');
        _serverToken = null;
        if (_firebaseReady) {
          final settings = await FirebaseMessaging.instance
              .getNotificationSettings();
          _systemPermissionGranted = _isAuthorized(
            settings.authorizationStatus,
          );
          _deviceToken = _systemPermissionGranted
              ? await FirebaseMessaging.instance.getToken()
              : null;
        }
        _enabled = false;
      }
    } catch (e) {
      _lastError = _friendlyError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _ensureFirebaseReady() async {
    if (_firebaseReady || !isSupported) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
      _firebaseReady = true;
    } catch (e) {
      _firebaseReady = false;
      _lastError = _friendlyError(e);
    }
  }

  Future<void> _handleTokenRefresh(String token) async {
    _deviceToken = token;
    if ((_serverToken ?? '').isEmpty) {
      notifyListeners();
      return;
    }

    try {
      await _pushTokenToServer(token);
      _serverToken = token;
      _enabled = true;
      _lastError = null;
    } catch (e) {
      _lastError = _friendlyError(e);
    }
    notifyListeners();
  }

  Future<void> _pushTokenToServer(String token) async {
    await AuthService.instance.updateCurrentUser({'device_token': token});
  }

  bool _isAuthorized(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  String? _readDeviceToken(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  String _friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('google-services.json') ||
        text.contains('Default FirebaseApp is not initialized')) {
      return 'Firebase ist noch nicht vollständig konfiguriert. Bitte die google-services.json unter android/app/ ablegen.';
    }
    return text;
  }
}
