import '../_client.dart';

Future<Map<String, dynamic>> userSession(ApiClient client) async {
  final data = await client.get('/api/user.session');
  if (data is! Map<String, dynamic>) {
    throw const ApiException('Unerwartetes API-Format fuer user.session.');
  }
  return data;
}
