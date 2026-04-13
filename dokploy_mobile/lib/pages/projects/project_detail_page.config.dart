import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../api/project/models.dart';
import '../services/advanced/service_advanced_page.dart';
import '../services/environment/service_environment_page.dart';
import '../services/general/application_general_page.dart';
import '../services/general/compose_general_page.dart';
import '../services/general/database_general_page.dart';

const databaseServiceTabs = <ServiceTabDefinition>[
  ServiceTabDefinition(key: 'general', label: 'General'),
  ServiceTabDefinition(key: 'environment', label: 'Environment'),
  ServiceTabDefinition(key: 'logs', label: 'Logs'),
  ServiceTabDefinition(key: 'monitoring', label: 'Monitoring'),
  ServiceTabDefinition(key: 'backups', label: 'Backups'),
  ServiceTabDefinition(key: 'advanced', label: 'Advanced'),
];

const redisServiceTabs = <ServiceTabDefinition>[
  ServiceTabDefinition(key: 'general', label: 'General'),
  ServiceTabDefinition(key: 'environment', label: 'Environment'),
  ServiceTabDefinition(key: 'logs', label: 'Logs'),
  ServiceTabDefinition(key: 'monitoring', label: 'Monitoring'),
  ServiceTabDefinition(key: 'advanced', label: 'Advanced'),
];

const applicationServiceTabs = <ServiceTabDefinition>[
  ServiceTabDefinition(key: 'general', label: 'General'),
  ServiceTabDefinition(key: 'environment', label: 'Environment'),
  ServiceTabDefinition(key: 'domains', label: 'Domains'),
  ServiceTabDefinition(key: 'deployments', label: 'Deployments'),
  ServiceTabDefinition(
    key: 'preview-deployments',
    label: 'Preview Deployments',
  ),
  ServiceTabDefinition(key: 'schedules', label: 'Schedules'),
  ServiceTabDefinition(key: 'volume-backups', label: 'Volume Backups'),
  ServiceTabDefinition(key: 'logs', label: 'Logs'),
  ServiceTabDefinition(key: 'patches', label: 'Patches'),
  ServiceTabDefinition(key: 'monitoring', label: 'Monitoring'),
  ServiceTabDefinition(key: 'advanced', label: 'Advanced'),
];

const composeServiceTabs = <ServiceTabDefinition>[
  ServiceTabDefinition(key: 'general', label: 'General'),
  ServiceTabDefinition(key: 'environment', label: 'Environment'),
  ServiceTabDefinition(key: 'logs', label: 'Logs'),
  ServiceTabDefinition(key: 'monitoring', label: 'Monitoring'),
  ServiceTabDefinition(key: 'backups', label: 'Backups'),
  ServiceTabDefinition(key: 'advanced', label: 'Advanced'),
];

class ServiceTabDefinition {
  const ServiceTabDefinition({required this.key, required this.label});

  final String key;
  final String label;
}

typedef ServiceGeneralPageBuilder = Widget Function(ProjectService service);

class ServiceGeneralConfig {
  const ServiceGeneralConfig({required this.builder});

  final ServiceGeneralPageBuilder builder;
}

const serviceGeneralConfigs = <String, ServiceGeneralConfig>{
  'applications': ServiceGeneralConfig(builder: _buildApplicationGeneralPage),
  'compose': ServiceGeneralConfig(builder: _buildComposeGeneralPage),
  'mariadb': ServiceGeneralConfig(builder: _buildMariaDbGeneralPage),
  'mongo': ServiceGeneralConfig(builder: _buildMongoGeneralPage),
  'mysql': ServiceGeneralConfig(builder: _buildMySqlGeneralPage),
  'postgres': ServiceGeneralConfig(builder: _buildPostgresGeneralPage),
  'redis': ServiceGeneralConfig(builder: _buildRedisGeneralPage),
};

List<ServiceTabDefinition> tabsForService(ProjectService service) {
  switch (service.sourceKey) {
    case 'applications':
      return applicationServiceTabs;
    case 'compose':
      return composeServiceTabs;
    case 'redis':
      return redisServiceTabs;
    case 'mariadb':
    case 'mongo':
    case 'mysql':
    case 'postgres':
      return databaseServiceTabs;
    default:
      return applicationServiceTabs;
  }
}

ServiceTabDefinition resolveActiveServiceTab(
  List<ServiceTabDefinition> tabs,
  String? tabKey,
) {
  if (tabKey == null || tabKey.isEmpty) {
    return tabs.first;
  }

  return tabs.where((tab) => tab.key == tabKey).firstOrNull ?? tabs.first;
}

Widget buildServiceTabContent(
  BuildContext context, {
  required ProjectService service,
  required ServiceTabDefinition activeTab,
}) {
  if (activeTab.key == 'advanced') {
    return ServiceAdvancedPage(service: service);
  }

  if (activeTab.key == 'environment') {
    return const ServiceEnvironmentPage();
  }

  if (activeTab.key != 'general') {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          activeTab.label,
          style: ShadTheme.of(context).textTheme.large,
        ),
      ),
    );
  }

  final config = serviceGeneralConfigs[service.sourceKey];
  if (config == null) {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          activeTab.label,
          style: ShadTheme.of(context).textTheme.large,
        ),
      ),
    );
  }

  return config.builder(service);
}

Widget _buildApplicationGeneralPage(ProjectService service) {
  return ApplicationGeneralPage(service: service);
}

Widget _buildComposeGeneralPage(ProjectService service) {
  return ComposeGeneralPage(service: service);
}

Widget _buildMariaDbGeneralPage(ProjectService service) {
  return DatabaseGeneralPage(
    service: service,
    databaseKind: 'MariaDB',
    defaultUser: 'mariadb',
    defaultDatabaseName: 'mariadb',
    defaultPort: '3306',
  );
}

Widget _buildMongoGeneralPage(ProjectService service) {
  return DatabaseGeneralPage(
    service: service,
    databaseKind: 'Mongo',
    defaultUser: 'mongo',
    defaultPort: '27017',
    showDatabaseName: false,
  );
}

Widget _buildMySqlGeneralPage(ProjectService service) {
  return DatabaseGeneralPage(
    service: service,
    databaseKind: 'MySQL',
    defaultUser: 'mysql',
    defaultDatabaseName: 'mysql',
    defaultPort: '3306',
    secondarySecretLabel: 'Root Password',
  );
}

Widget _buildPostgresGeneralPage(ProjectService service) {
  return DatabaseGeneralPage(
    service: service,
    databaseKind: 'Postgres',
    defaultUser: 'postgres',
    defaultDatabaseName: 'postgres',
    defaultPort: '5432',
  );
}

Widget _buildRedisGeneralPage(ProjectService service) {
  return DatabaseGeneralPage(
    service: service,
    databaseKind: 'Redis',
    defaultUser: 'default',
    defaultPort: '6379',
    showDatabaseName: false,
  );
}
