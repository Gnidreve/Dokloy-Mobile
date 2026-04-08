import '../_client.dart';

Future<Map<String, dynamic>> userGetPermissions(ApiClient client) async {
  final data = await client.get('/api/user.getPermissions');
  if (data is! Map<String, dynamic>) {
    throw const ApiException('Unerwartetes API-Format für user.getPermissions.');
  }
  return data;
}
