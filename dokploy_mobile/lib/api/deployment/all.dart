// GET
import '../_client.dart';
import 'models.dart';

Future<List<Deployment>> deploymentAll(ApiClient client) async {
  final data = await client.get('/api/deployment.allCentralized');
  if (data is! List) {
    throw const ApiException('Unerwartetes API-Format für deployment.all.');
  }

  return data
      .whereType<Map<String, dynamic>>()
      .map(Deployment.fromJson)
      .toList();
}
