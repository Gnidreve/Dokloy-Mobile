import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketbase/pocketbase.dart';

class AuthService {
  AuthService._();

  static final instance = AuthService._();

  static const _storageKey = 'pb_auth';
  static const _skipEnvLoginKey = 'skip_env_login';

  final _storage = const FlutterSecureStorage();

  late final PocketBase pb;

  /// Fallback ohne persistierten Token — PocketBase wird ohne AuthStore-Inhalt initialisiert.
  Future<void> initFallback() async {
    final url =
        dotenv.env['BASE_URL']?.trim() ?? 'https://pocketbase.everding.online';
    pb = PocketBase(url);
  }

  Future<void> init() async {
    final url =
        dotenv.env['BASE_URL']?.trim() ?? 'https://pocketbase.everding.online';

    // Gespeichertes Auth-Token laden — defensiv, falls Keystore nicht verfügbar
    String? storedAuth;
    try {
      storedAuth = await _storage.read(key: _storageKey);
    } catch (_) {
      // Ohne gespeichertem Token starten
    }

    final store = AsyncAuthStore(
      save: (data) async {
        try {
          await _storage.write(key: _storageKey, value: data);
        } catch (_) {}
      },
      initial: storedAuth,
      clear: () async {
        try {
          await _storage.delete(key: _storageKey);
        } catch (_) {}
      },
    );

    pb = PocketBase(url, authStore: store);
  }

  bool get isLoggedIn => pb.authStore.isValid;

  RecordModel? get currentUser => pb.authStore.record;

  String? get currentUserId => pb.authStore.record?.id;

  String get currentUserName =>
      pb.authStore.record?.getStringValue('name').trim() ?? '';

  String get currentUserEmail =>
      pb.authStore.record?.getStringValue('email') ?? '';

  String get currentUserInitials {
    final name = currentUserName;
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return name[0].toUpperCase();
    }
    final email = currentUserEmail;
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }

  /// Versucht automatischen Login aus .env (nur für Development).
  /// Gibt true zurück wenn erfolgreich, false wenn keine Env-Vars vorhanden.
  Future<bool> tryEnvLogin() async {
    if (await _shouldSkipEnvLogin()) return false;

    final email = dotenv.env['EMAIL']?.trim() ?? '';
    final password = dotenv.env['PASSWORD']?.trim() ?? '';
    if (email.isEmpty || password.isEmpty) return false;
    await pb.collection('_superusers').authWithPassword(email, password);
    return true;
  }

  Future<void> login(String email, String password) async {
    await pb.collection('_superusers').authWithPassword(email, password);
    await _clearSkipEnvLogin();
  }

  Future<void> logout() async {
    pb.authStore.clear();
    try {
      await _storage.write(key: _skipEnvLoginKey, value: 'true');
    } catch (_) {}
  }

  Future<RecordModel> refreshCurrentUser() async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      throw StateError('Kein eingeloggter Benutzer vorhanden.');
    }

    final record = await pb.collection('_superusers').getOne(userId);
    pb.authStore.save(pb.authStore.token, record);
    return record;
  }

  Future<RecordModel> updateCurrentUser(Map<String, dynamic> body) async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      throw StateError('Kein eingeloggter Benutzer vorhanden.');
    }

    final record = await pb
        .collection('_superusers')
        .update(userId, body: body);
    pb.authStore.save(pb.authStore.token, record);
    return record;
  }

  Future<bool> _shouldSkipEnvLogin() async {
    try {
      return await _storage.read(key: _skipEnvLoginKey) == 'true';
    } catch (_) {
      return false;
    }
  }

  Future<void> _clearSkipEnvLogin() async {
    try {
      await _storage.delete(key: _skipEnvLoginKey);
    } catch (_) {}
  }
}
