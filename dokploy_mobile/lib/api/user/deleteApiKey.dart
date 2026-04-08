import '../_client.dart';

Future<void> userDeleteApiKey(
  ApiClient client, {
  required String apiKeyId,
}) async {
  await client.post(
    '/api/user.deleteApiKey',
    body: {'apiKeyId': apiKeyId},
  );
}
