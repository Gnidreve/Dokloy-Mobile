import 'models.dart';

/// Globaler static holder für den eingeloggten User.
/// Wird beim App-Start via [ConnectingPage] befüllt und
/// danach als read-only behandelt.
class UserStore {
  UserStore._();

  static User? current;
  static String? lastError;

  static void clear() {
    current = null;
    lastError = null;
  }
}
