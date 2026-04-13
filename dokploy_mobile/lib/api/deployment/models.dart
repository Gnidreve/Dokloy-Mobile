class Deployment {
  const Deployment({
    required this.id,
    required this.serviceName,
    required this.projectName,
    required this.environmentName,
    required this.serverName,
    required this.title,
    required this.type,
    required this.status,
    required this.createdAt,
  });

  factory Deployment.fromJson(Map<String, dynamic> json) {
    final application = json['application'] as Map<String, dynamic>?;
    final compose = json['compose'] as Map<String, dynamic>?;
    final source = application ?? compose ?? const <String, dynamic>{};
    final environment = source['environment'] as Map<String, dynamic>?;
    final project = environment?['project'] as Map<String, dynamic>?;
    final server =
        (source['server'] as Map<String, dynamic>?) ??
        (json['server'] as Map<String, dynamic>?);

    return Deployment(
      id: json['deploymentId'] as String? ?? '',
      serviceName: source['name'] as String? ?? 'Unknown service',
      projectName: project?['name'] as String? ?? 'Unknown project',
      environmentName: environment?['name'] as String? ?? 'Unknown environment',
      serverName: server?['name'] as String? ?? '—',
      title: json['title'] as String? ?? '',
      type: application != null ? 'Application' : 'Compose',
      status: DeploymentStatusX.fromRaw(json['status'] as String?),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String id;
  final String serviceName;
  final String projectName;
  final String environmentName;
  final String serverName;
  final String title;
  final String type;
  final DeploymentStatus status;
  final DateTime createdAt;
}

enum DeploymentStatus { running, done, error, cancelled }

extension DeploymentStatusX on DeploymentStatus {
  static DeploymentStatus fromRaw(String? value) {
    switch (value?.toLowerCase()) {
      case 'running':
        return DeploymentStatus.running;
      case 'done':
      case 'success':
        return DeploymentStatus.done;
      case 'cancelled':
      case 'canceled':
        return DeploymentStatus.cancelled;
      case 'error':
      case 'failed':
      default:
        return DeploymentStatus.error;
    }
  }
}

class DeploymentQueueItem {
  const DeploymentQueueItem({
    required this.id,
    required this.serviceName,
    required this.projectName,
    required this.environmentName,
    required this.serverName,
    required this.title,
    required this.type,
    required this.state,
    required this.timestamp,
  });

  factory DeploymentQueueItem.fromJson(Map<String, dynamic> json) {
    final data =
        json['data'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final servicePath =
        json['servicePath'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final href = servicePath['href'] as String? ?? '';
    final segments = Uri.tryParse(href)?.pathSegments ?? const <String>[];

    return DeploymentQueueItem(
      id: json['id'] as String? ?? '',
      serviceName: servicePath['label'] as String? ?? 'Unknown service',
      projectName: segments.length > 2 ? segments[2] : 'Unknown project',
      environmentName: segments.length > 4
          ? segments[4]
          : 'Unknown environment',
      serverName: (data['server'] as bool? ?? false) ? 'Server' : '—',
      title: data['titleLog'] as String? ?? '',
      type: _queueTypeLabel(data['applicationType'] as String?),
      state: json['state'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['timestamp'] as num?)?.toInt() ?? 0,
      ),
    );
  }

  final String id;
  final String serviceName;
  final String projectName;
  final String environmentName;
  final String serverName;
  final String title;
  final String type;
  final String state;
  final DateTime timestamp;

  static String _queueTypeLabel(String? value) {
    switch (value?.toLowerCase()) {
      case 'compose':
        return 'Compose';
      case 'application':
        return 'Application';
      default:
        return value == null || value.isEmpty ? 'Unknown' : value;
    }
  }
}
