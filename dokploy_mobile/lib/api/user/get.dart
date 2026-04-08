import '../_client.dart';
import '../models.dart';

Future<User> userGet(ApiClient client) async {
  final data = await client.get(
    '/api/user.get',
    timeout: const Duration(seconds: 5),
  );
  if (data is! Map<String, dynamic>) {
    throw const ApiException('Unerwartetes API-Format für user.get.');
  }
  return User.fromJson(data);
}
