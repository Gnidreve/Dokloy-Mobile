import '../_client.dart';

Future<Map<String, dynamic>> userCreateUserWithCredentials(
  ApiClient client, {
  required String email,
  required String password,
}) async {
  final data = await client.post(
    '/api/user.createUserWithCredentials',
    body: {'email': email, 'password': password},
  );
  if (data is! Map<String, dynamic>) {
    throw const ApiException('Unerwartetes API-Format für user.createUserWithCredentials.');
  }
  return data;
}
