import '../_client.dart';

Future<Map<String, dynamic>> userGetMetricsToken(ApiClient client) async {
  final data = await client.get('/api/user.getMetricsToken');
  if (data is! Map<String, dynamic>) {
    throw const ApiException('Unerwartetes API-Format für user.getMetricsToken.');
  }
  return data;
}
