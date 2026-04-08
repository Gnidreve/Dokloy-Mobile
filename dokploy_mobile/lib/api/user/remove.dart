import '../_client.dart';

Future<void> userRemove(
  ApiClient client, {
  required String userId,
}) async {
  await client.post('/api/user.remove', body: {'userId': userId});
}
