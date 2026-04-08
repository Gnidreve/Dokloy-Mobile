import '../_client.dart';
import '../models.dart';
import 'assignPermissions.dart';
import 'checkUserOrganizations.dart';
import 'createApiKey.dart';
import 'createUserWithCredentials.dart';
import 'deleteApiKey.dart';
import 'generateToken.dart';
import 'get.dart';
import 'getContainerMetrics.dart';
import 'getInvitations.dart';
import 'getMetricsToken.dart';
import 'getPermissions.dart';
import 'getUserByToken.dart';
import 'remove.dart';
import 'sendInvitation.dart';
import 'session.dart';
import 'update.dart';

class UserApi {
  const UserApi(this._client);

  final ApiClient _client;

  Future<User> get() => userGet(_client);

  Future<Map<String, dynamic>> getPermissions() =>
      userGetPermissions(_client);

  Future<Map<String, dynamic>> createApiKey({required String name}) =>
      userCreateApiKey(_client, name: name);

  Future<void> deleteApiKey({required String apiKeyId}) =>
      userDeleteApiKey(_client, apiKeyId: apiKeyId);

  Future<List<Map<String, dynamic>>> getInvitations() =>
      userGetInvitations(_client);

  Future<void> sendInvitation({required String email}) =>
      userSendInvitation(_client, email: email);

  Future<Map<String, dynamic>> checkUserOrganizations() =>
      userCheckUserOrganizations(_client);

  Future<Map<String, dynamic>> generateToken() =>
      userGenerateToken(_client);

  Future<Map<String, dynamic>> getContainerMetrics({required String appName}) =>
      userGetContainerMetrics(_client, appName: appName);

  Future<Map<String, dynamic>> getMetricsToken() =>
      userGetMetricsToken(_client);

  Future<Map<String, dynamic>> getUserByToken({required String token}) =>
      userGetUserByToken(_client, token: token);

  Future<void> remove({required String userId}) =>
      userRemove(_client, userId: userId);

  Future<Map<String, dynamic>> session() => userSession(_client);

  Future<Map<String, dynamic>> createUserWithCredentials({
    required String email,
    required String password,
  }) => userCreateUserWithCredentials(_client, email: email, password: password);

  Future<void> assignPermissions({
    required String userId,
    required Map<String, dynamic> permissions,
  }) => userAssignPermissions(_client, userId: userId, permissions: permissions);

  Future<void> update({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? currentPassword,
  }) => userUpdate(
        _client,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        currentPassword: currentPassword,
      );
}
