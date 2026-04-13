import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ServiceEnvironmentPage extends StatefulWidget {
  const ServiceEnvironmentPage({super.key});

  @override
  State<ServiceEnvironmentPage> createState() => _ServiceEnvironmentPageState();
}

class _ServiceEnvironmentPageState extends State<ServiceEnvironmentPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isVisible = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Environment Settings', style: theme.textTheme.h3),
                      const SizedBox(height: 4),
                      Text(
                        'You can add environment variables to your resource.',
                        style: theme.textTheme.muted,
                      ),
                    ],
                  ),
                ),
                ShadButton.outline(
                  onPressed: () => setState(() => _isVisible = !_isVisible),
                  size: ShadButtonSize.sm,
                  child: Icon(
                    _isVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                ShadTextarea(
                  controller: _controller,
                  minHeight: 360,
                  maxHeight: 360,
                  resizable: false,
                  style: _isVisible
                      ? null
                      : theme.textTheme.p.copyWith(color: Colors.transparent),
                  placeholder: const Text('Type your message here'),
                ),
                if (!_isVisible)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Text(
                          _controller.text.isEmpty
                              ? ''
                              : List.filled(
                                  _controller.text.length,
                                  '•',
                                ).join(),
                          style: theme.textTheme.p.copyWith(
                            color: theme.colorScheme.foreground,
                          ),
                          maxLines: null,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ShadButton(onPressed: () {}, child: const Text('Save')),
            ),
          ],
        ),
      ),
    );
  }
}
