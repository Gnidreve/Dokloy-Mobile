class Project {
  const Project({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.serviceCount,
    required this.environments,
    this.description = '',
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final int serviceCount;
  final String description;
  final List<ProjectEnvironment> environments;

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
}

class ProjectEnvironment {
  const ProjectEnvironment({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.services,
  });

  final String id;
  final String name;
  final bool isDefault;
  final List<ProjectService> services;

  int get serviceCount => services.length;

  factory ProjectEnvironment.fromJson(Map<String, dynamic> json) {
    final services = <ProjectService>[
      ..._parseServices(
        json['applications'],
        type: 'Application',
        idKeys: const ['applicationId', 'appId', 'id'],
        statusKeys: const ['applicationStatus', 'status'],
      ),
      ..._parseServices(
        json['mariadb'],
        type: 'MariaDB',
        idKeys: const ['mariadbId', 'id'],
        statusKeys: const ['mariadbStatus', 'status'],
      ),
      ..._parseServices(
        json['mongo'],
        type: 'Mongo',
        idKeys: const ['mongoId', 'id'],
        statusKeys: const ['mongoStatus', 'status'],
      ),
      ..._parseServices(
        json['mysql'],
        type: 'MySQL',
        idKeys: const ['mysqlId', 'id'],
        statusKeys: const ['mysqlStatus', 'status'],
      ),
      ..._parseServices(
        json['postgres'],
        type: 'Postgres',
        idKeys: const ['postgresId', 'id'],
        statusKeys: const ['postgresStatus', 'status'],
      ),
      ..._parseServices(
        json['redis'],
        type: 'Redis',
        idKeys: const ['redisId', 'id'],
        statusKeys: const ['redisStatus', 'status'],
      ),
      ..._parseServices(
        json['compose'],
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

  static List<ProjectService> _parseServices(
    Object? value, {
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
    required this.type,
    this.status,
  });

  final String id;
  final String name;
  final String type;
  final String? status;
}

class User {
  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.image,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? image;

  String get displayName => '$firstName $lastName'.trim();

  String get initials {
    final parts = displayName.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    if (parts.isNotEmpty) return parts.first[0].toUpperCase();
    return '?';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return User(
      id: user['id'] as String? ?? '',
      email: user['email'] as String? ?? '',
      firstName: user['firstName'] as String? ?? '',
      lastName: user['lastName'] as String? ?? '',
      image: user['image'] as String?,
    );
  }
}

class Deployment {
  const Deployment({
    required this.id,
    required this.serviceName,
    required this.projectName,
    required this.type,
    required this.status,
  });

  final String id;
  final String serviceName;
  final String projectName;
  final String type;
  final DeploymentStatus status;
}

enum DeploymentStatus { running, done, error, cancelled }

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
