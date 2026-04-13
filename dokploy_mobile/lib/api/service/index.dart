import '../_client.dart';
import '../project/models.dart';
import 'one.dart';

class ServiceApi {
  const ServiceApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> one({
    required String slug,
    required String id,
  }) => serviceOne(_client, slug: slug, id: id);

  Future<Map<String, dynamic>> oneForProjectService(ProjectService service) {
    return one(slug: service.endpointSlug, id: service.id);
  }
}
