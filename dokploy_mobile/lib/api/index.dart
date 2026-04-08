import 'package:http/http.dart' as http;

import '_client.dart';
import 'project/index.dart';
import 'user/index.dart';

export '_client.dart' show ApiException;
export 'models.dart';

class DokployApi {
  DokployApi({http.Client? client}) : _client = ApiClient(httpClient: client);

  final ApiClient _client;

  late final user = UserApi(_client);
  late final project = ProjectApi(_client);
}
