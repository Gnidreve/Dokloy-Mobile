import '../_client.dart';

Future<Map<String, dynamic>> userGenerateToken(ApiClient client) async {
  final data = await client.post('/api/user.generateToken');
  if (data is! Map<String, dynamic>) {
    throw const ApiException('Unerwartetes API-Format für user.generateToken.');
  }
  return data;
}
