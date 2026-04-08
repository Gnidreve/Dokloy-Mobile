import '../_client.dart';

Future<Map<String, dynamic>> userGetUserByToken(
  ApiClient client, {
  required String token,
}) async {
  final data = await client.get(
    '/api/user.getUserByToken?token=${Uri.encodeComponent(token)}',
  );
  if (data is! Map<String, dynamic>) {
    throw const ApiException('Unerwartetes API-Format für user.getUserByToken.');
  }
  return data;
}
