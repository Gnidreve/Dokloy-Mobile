import '../_client.dart';

Future<Map<String, dynamic>> userCreateApiKey(
  ApiClient client, {
  required String name,
}) async {
  final data = await client.post(
    '/api/user.createApiKey',
    body: {'name': name},
  );
  if (data is! Map<String, dynamic>) {
    throw const ApiException('Unerwartetes API-Format für user.createApiKey.');
  }
  return data;
}
