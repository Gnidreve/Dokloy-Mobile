import '../_client.dart';

Future<Map<String, dynamic>> userCheckUserOrganizations(ApiClient client) async {
  final data = await client.get('/api/user.checkUserOrganizations');
  if (data is! Map<String, dynamic>) {
    throw const ApiException('Unerwartetes API-Format für user.checkUserOrganizations.');
  }
  return data;
}
