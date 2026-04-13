// GET
import '../_client.dart';
import 'models.dart';

Future<List<DeploymentQueueItem>> deploymentQueueList(ApiClient client) async {
  final data = await client.get('/api/deployment.queueList');
  if (data is! List) {
    throw const ApiException(
      'Unerwartetes API-Format für deployment.queueList.',
    );
  }

  return data
      .whereType<Map<String, dynamic>>()
      .map(DeploymentQueueItem.fromJson)
      .toList();
}
