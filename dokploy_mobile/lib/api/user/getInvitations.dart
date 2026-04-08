import '../_client.dart';

Future<List<Map<String, dynamic>>> userGetInvitations(ApiClient client) async {
  final data = await client.get('/api/user.getInvitations');
  if (data is! List) {
    throw const ApiException('Unerwartetes API-Format für user.getInvitations.');
  }
  return data.whereType<Map<String, dynamic>>().toList();
}
