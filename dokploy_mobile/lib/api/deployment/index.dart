import '../_client.dart';
import 'models.dart';
import 'all.dart';
import 'queueList.dart';

class DeploymentApi {
  const DeploymentApi(this._client);

  final ApiClient _client;

  Future<List<Deployment>> all() => deploymentAll(_client);

  Future<List<DeploymentQueueItem>> queueList() => deploymentQueueList(_client);
}
