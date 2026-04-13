// GET ?{slug}Id=string
import '../_client.dart';

Future<Map<String, dynamic>> serviceOne(
  ApiClient client, {
  required String slug,
  required String id,
}) async {
  final queryKey = '${slug}Id';
  final data = await client.get(
    '/api/$slug.one?$queryKey=${Uri.encodeComponent(id)}',
  );
  if (data is! Map<String, dynamic>) {
    throw ApiException('Unerwartetes API-Format für $slug.one.');
  }
  return data;
}
