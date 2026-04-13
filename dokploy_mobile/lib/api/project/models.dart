class Project {
  const Project({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.serviceCount,
    required this.environments,
    this.description = '',
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    final environments = (json['environments'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ProjectEnvironment.fromJson)
        .toList();

    final totalServices = environments.fold<int>(
      0,
      (sum, environment) => sum + environment.serviceCount,
    );

    return Project(
      id: json['projectId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      serviceCount: totalServices,
      environments: environments,
    );
  }

  final String id;
  final String name;
  final DateTime createdAt;
  final int serviceCount;
  final String description;
  final List<ProjectEnvironment> environments;
}

class ProjectEnvironment {
  const ProjectEnvironment({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.services,
  });

  factory ProjectEnvironment.fromJson(Map<String, dynamic> json) {
    final services = <ProjectService>[
      ..._parseServices(
        json['applications'],
        sourceKey: 'applications',
        type: 'Application',
        idKeys: const ['applicationId', 'appId', 'id'],
        statusKeys: const ['applicationStatus', 'status'],
      ),
      ..._parseServices(
        json['mariadb'],
        sourceKey: 'mariadb',
        type: 'MariaDB',
        idKeys: const ['mariadbId', 'id'],
        statusKeys: const ['mariadbStatus', 'status'],
      ),
      ..._parseServices(
        json['mongo'],
        sourceKey: 'mongo',
        type: 'Mongo',
        idKeys: const ['mongoId', 'id'],
        statusKeys: const ['mongoStatus', 'status'],
      ),
      ..._parseServices(
        json['mysql'],
        sourceKey: 'mysql',
        type: 'MySQL',
        idKeys: const ['mysqlId', 'id'],
        statusKeys: const ['mysqlStatus', 'status'],
      ),
      ..._parseServices(
        json['postgres'],
        sourceKey: 'postgres',
        type: 'Postgres',
        idKeys: const ['postgresId', 'id'],
        statusKeys: const ['postgresStatus', 'status'],
      ),
      ..._parseServices(
        json['redis'],
        sourceKey: 'redis',
        type: 'Redis',
        idKeys: const ['redisId', 'id'],
        statusKeys: const ['redisStatus', 'status'],
      ),
      ..._parseServices(
        json['compose'],
        sourceKey: 'compose',
        type: 'Compose',
        idKeys: const ['composeId', 'id'],
        statusKeys: const ['composeStatus', 'status'],
      ),
    ];

    return ProjectEnvironment(
      id: json['environmentId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
      services: services,
    );
  }

  final String id;
  final String name;
  final bool isDefault;
  final List<ProjectService> services;

  int get serviceCount => services.length;

  static List<ProjectService> _parseServices(
    Object? value, {
    required String sourceKey,
    required String type,
    required List<String> idKeys,
    required List<String> statusKeys,
  }) {
    final items = value as List<dynamic>? ?? const [];
    return items.whereType<Map<String, dynamic>>().map((item) {
      String? id;
      for (final key in idKeys) {
        final candidate = item[key] as String?;
        if (candidate != null && candidate.isNotEmpty) {
          id = candidate;
          break;
        }
      }

      String? status;
      for (final key in statusKeys) {
        final candidate = item[key] as String?;
        if (candidate != null && candidate.isNotEmpty) {
          status = candidate;
          break;
        }
      }

      return ProjectService(
        id: id ?? '',
        name: item['name'] as String? ?? type,
        sourceKey: sourceKey,
        type: type,
        status: status,
      );
    }).toList();
  }
}

class ProjectService {
  const ProjectService({
    required this.id,
    required this.name,
    required this.sourceKey,
    required this.type,
    this.status,
  });

  final String id;
  final String name;
  final String sourceKey;
  final String type;
  final String? status;

  String get endpointSlug {
    switch (sourceKey) {
      case 'applications':
        return 'application';
      default:
        return sourceKey;
    }
  }

  String get endpointQueryKey => '${endpointSlug}Id';
}
