import '../_client.dart';

Future<Map<String, dynamic>> userGetContainerMetrics(
  ApiClient client, {
  required String appName,
}) async {
  final data = await client.get(
    '/api/user.getContainerMetrics?appName=${Uri.encodeComponent(appName)}',
  );
  if (data is! Map<String, dynamic>) {
    throw const ApiException('Unerwartetes API-Format für user.getContainerMetrics.');
  }
  return data;
}
