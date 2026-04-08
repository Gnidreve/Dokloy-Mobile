import '../_client.dart';

Future<void> userSendInvitation(
  ApiClient client, {
  required String email,
}) async {
  await client.post('/api/user.sendInvitation', body: {'email': email});
}
