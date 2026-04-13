import '../_client.dart';
import 'models.dart';

Future<List<Project>> projectAll(ApiClient client) async {
  final data = await client.get('/api/project.all');
  if (data is! List) {
    throw const ApiException('Unerwartetes API-Format für project.all.');
  }
  return data.whereType<Map<String, dynamic>>().map(Project.fromJson).toList();
}
