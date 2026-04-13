export 'deployment/models.dart';
export 'project/models.dart';
export 'user/models.dart';

class Schedule {
  const Schedule({required this.id, required this.name, required this.cron});

  final String id;
  final String name;
  final String cron;
}

class RemoteServer {
  const RemoteServer({required this.id, required this.name, required this.ip});

  final String id;
  final String name;
  final String ip;
}
