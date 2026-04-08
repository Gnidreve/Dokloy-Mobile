import '../_client.dart';
import '../models.dart';
import 'all.dart';

class ProjectApi {
  const ProjectApi(this._client);

  final ApiClient _client;

  Future<List<Project>> all() => projectAll(_client);

  Future<Project> find(String projectId) async {
    final projects = await all();
    try {
      return projects.firstWhere((p) => p.id == projectId);
    } on StateError {
      throw const ApiException('Projekt wurde nicht gefunden.');
    }
  }
}
