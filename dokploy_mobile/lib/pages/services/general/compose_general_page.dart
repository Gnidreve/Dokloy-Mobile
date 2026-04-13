import 'package:flutter/material.dart';

import '../../../api/project/models.dart';
import 'source_provider_general_page.dart';

class ComposeGeneralPage extends StatelessWidget {
  const ComposeGeneralPage({super.key, required this.service});

  final ProjectService service;

  @override
  Widget build(BuildContext context) {
    return SourceProviderGeneralPage(
      service: service,
      previewLabel: 'Preview Compose',
    );
  }
}
