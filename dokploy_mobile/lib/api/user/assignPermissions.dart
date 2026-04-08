import '../_client.dart';

Future<void> userAssignPermissions(
  ApiClient client, {
  required String userId,
  required Map<String, dynamic> permissions,
}) async {
  await client.post(
    '/api/user.assignPermissions',
    body: {'userId': userId, ...permissions},
  );
}
