import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../api/project/models.dart';

final _providerTabs = <({IconData icon, String label})>[
  (icon: LucideIcons.circleDot, label: 'GitHub'),
  (icon: LucideIcons.triangle, label: 'GitLab'),
  (icon: LucideIcons.square, label: 'Bitbucket'),
  (icon: LucideIcons.leaf, label: 'Gitea'),
  (icon: LucideIcons.gitBranch, label: 'Git'),
  (icon: LucideIcons.codeXml, label: 'Raw'),
];

const _providerDropdownOptions = <String>[
  'GitHub',
  'GitLab',
  'BitBucket',
  'Gitea',
  'Docker',
  'Git',
  'Drop',
];

class SourceProviderGeneralPage extends StatelessWidget {
  const SourceProviderGeneralPage({
    super.key,
    required this.service,
    required this.previewLabel,
  });

  final ProjectService service;
  final String previewLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShadSelect<String>(
          initialValue: 'GitHub',
          placeholder: const _ProviderDropdownLabel(provider: 'GitHub'),
          selectedOptionBuilder: (context, value) =>
              _ProviderDropdownLabel(provider: value),
          onChanged: (_) {},
          options: _providerDropdownOptions
              .map(
                (provider) => ShadOption(
                  value: provider,
                  child: _ProviderDropdownLabel(provider: provider),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        ShadCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Provider',
                            style: ShadTheme.of(context).textTheme.h3,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Select the source of your code',
                            style: ShadTheme.of(context).textTheme.muted,
                          ),
                        ],
                      ),
                    ),
                    ShadButton.outline(
                      onPressed: () {},
                      leading: const Icon(LucideIcons.wandSparkles, size: 16),
                      child: Text(previewLabel),
                    ),
                    const SizedBox(width: 8),
                    ShadButton.outline(
                      onPressed: () {},
                      size: ShadButtonSize.sm,
                      child: const Icon(LucideIcons.gitBranchPlus, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _providerTabs
                        .map(
                          (provider) => Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: _ProviderTab(
                              icon: provider.icon,
                              label: provider.label,
                              selected: provider.label == 'GitHub',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
                const _FieldColumn(
                  label: 'Github Account',
                  value: 'Select a Github Account',
                  trailingIcon: LucideIcons.chevronDown,
                ),
                const SizedBox(height: 16),
                const _FieldColumn(
                  label: 'Repository',
                  value: 'Select repository',
                  trailingIcon: LucideIcons.chevronsUpDown,
                ),
                const SizedBox(height: 16),
                const _FieldColumn(
                  label: 'Branch',
                  value: 'Select branch',
                  trailingIcon: LucideIcons.chevronsUpDown,
                ),
                const SizedBox(height: 16),
                const _FieldColumn(label: 'Build Path', value: '/'),
                const SizedBox(height: 16),
                const _FieldColumn(
                  label: 'Trigger Type',
                  value: 'On Push',
                  trailingIcon: LucideIcons.chevronDown,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(
                      child: _FieldColumn(
                        label: 'Watch Paths',
                        value:
                            'Enter a path to watch (e.g., src/**, dist/*.js)',
                      ),
                    ),
                    const SizedBox(width: 8),
                    ShadButton.outline(
                      onPressed: () {},
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const ShadSwitch(value: false),
                    const SizedBox(width: 12),
                    Text(
                      'Enable Submodules',
                      style: ShadTheme.of(context).textTheme.p,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ShadButton(
                    onPressed: () {},
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProviderTab extends StatelessWidget {
  const _ProviderTab({
    required this.icon,
    required this.label,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: selected ? theme.colorScheme.border : Colors.transparent,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.p.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? null : theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldColumn extends StatelessWidget {
  const _FieldColumn({
    required this.label,
    required this.value,
    this.trailingIcon,
  });

  final String label;
  final String value;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ShadTheme.of(context).textTheme.p),
        const SizedBox(height: 8),
        ShadInput(
          initialValue: value,
          trailing: trailingIcon == null ? null : Icon(trailingIcon, size: 16),
        ),
      ],
    );
  }
}

class _ProviderDropdownLabel extends StatelessWidget {
  const _ProviderDropdownLabel({required this.provider});

  final String provider;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ProviderAssetIcon(provider: provider),
        const SizedBox(width: 8),
        Flexible(child: Text(provider, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _ProviderAssetIcon extends StatefulWidget {
  const _ProviderAssetIcon({required this.provider});

  final String provider;

  @override
  State<_ProviderAssetIcon> createState() => _ProviderAssetIconState();
}

class _ProviderAssetIconState extends State<_ProviderAssetIcon> {
  static Future<_ProviderAssetLookup>? _assetLookupFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ProviderAssetLookup>(
      future: _assetLookupFuture ??= _loadAssetLookup(),
      builder: (context, snapshot) {
        final assetPath = snapshot.data?.findAssetFor(widget.provider);

        if (assetPath == null) {
          return Icon(
            _fallbackIcon(widget.provider),
            size: 16,
            color: ShadTheme.of(context).colorScheme.foreground,
          );
        }

        if (assetPath.toLowerCase().endsWith('.svg')) {
          return SvgPicture.asset(assetPath, width: 16, height: 16);
        }

        return Image.asset(
          assetPath,
          width: 16,
          height: 16,
          fit: BoxFit.contain,
        );
      },
    );
  }

  Future<_ProviderAssetLookup> _loadAssetLookup() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final manifest = jsonDecode(manifestContent) as Map<String, dynamic>;
    final paths = manifest.keys
        .where((path) => path.startsWith('lib/assets/providers/'))
        .toList();

    return _ProviderAssetLookup(
      entries: [
        for (final path in paths)
          _ProviderAssetEntry(
            normalizedName: _normalizedAssetFileName(path),
            assetPath: path,
          ),
      ],
    );
  }

  String _normalizedAssetFileName(String path) {
    final fileName = path.split('/').last;
    final baseName = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;
    return _normalizeToken(baseName);
  }

  String _normalizeToken(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  IconData _fallbackIcon(String provider) {
    switch (_normalizeToken(provider)) {
      case 'github':
      case 'gitlab':
      case 'bitbucket':
      case 'gitea':
      case 'git':
        return LucideIcons.gitBranch;
      case 'docker':
        return LucideIcons.container;
      case 'drop':
        return LucideIcons.upload;
      default:
        return LucideIcons.circle;
    }
  }
}

class _ProviderAssetLookup {
  const _ProviderAssetLookup({required this.entries});

  final List<_ProviderAssetEntry> entries;

  String? findAssetFor(String provider) {
    final candidate = _normalizeToken(provider);
    if (candidate.isEmpty) return null;

    final exact = entries
        .where((entry) => entry.normalizedName == candidate)
        .firstOrNull;
    if (exact != null) return exact.assetPath;

    final fuzzy = entries
        .where(
          (entry) =>
              entry.normalizedName.contains(candidate) ||
              candidate.contains(entry.normalizedName),
        )
        .firstOrNull;
    return fuzzy?.assetPath;
  }

  String _normalizeToken(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}

class _ProviderAssetEntry {
  const _ProviderAssetEntry({
    required this.normalizedName,
    required this.assetPath,
  });

  final String normalizedName;
  final String assetPath;
}
