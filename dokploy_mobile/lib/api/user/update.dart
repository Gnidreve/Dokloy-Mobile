// POST { firstName?, lastName?, email?, password?, currentPassword? }

import '../_client.dart';

Future<void> userUpdate(
  ApiClient client, {
  String? firstName,
  String? lastName,
  String? email,
  String? password,
  String? currentPassword,
}) async {
  final body = <String, dynamic>{
    if (firstName != null) 'firstName': firstName,
    if (lastName != null) 'lastName': lastName,
    if (email != null) 'email': email,
    if (password != null && password.isNotEmpty) 'password': password,
    if (currentPassword != null && currentPassword.isNotEmpty)
      'currentPassword': currentPassword,
  };
  await client.post('/api/user.update', body: body);
}
