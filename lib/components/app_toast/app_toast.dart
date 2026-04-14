import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum AppToastType { success, error }

class AppToast {
  AppToast._();

  static OverlayEntry? _current;

  static void showSuccess(
    BuildContext context, {
    required String title,
    String? subtitle,
  }) =>
      _show(context, type: AppToastType.success, title: title, subtitle: subtitle);

  static void showError(
    BuildContext context, {
    required String title,
    String? subtitle,
  }) =>
      _show(context, type: AppToastType.error, title: title, subtitle: subtitle);

  static void _show(
    BuildContext context, {
    required AppToastType type,
    required String title,
    String? subtitle,
  }) {
    _current?.remove();
    _current = null;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _AppToastOverlay(
        type: type,
        title: title,
        subtitle: subtitle,
        onDismiss: () {
          entry.remove();
          if (_current == entry) _current = null;
        },
      ),
    );

    _current = entry;
    Overlay.of(context).insert(entry);
  }
}

class _AppToastOverlay extends StatefulWidget {
  const _AppToastOverlay({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.onDismiss,
  });

  final AppToastType type;
  final String title;
  final String? subtitle;
  final VoidCallback onDismiss;

  @override
  State<_AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends State<_AppToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  Timer? _timer;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _timer = Timer(const Duration(seconds: 4), _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    _timer?.cancel();
    if (!mounted) return;
    await _ctrl.reverse();
    widget.onDismiss();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (d.delta.dy < 0) {
      setState(() => _dragOffset += d.delta.dy);
    }
  }

  void _onDragEnd(DragEndDetails d) {
    final velocity = d.primaryVelocity ?? 0;
    if (_dragOffset < -36 || velocity < -400) {
      _dismiss();
    } else {
      setState(() => _dragOffset = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isError = widget.type == AppToastType.error;
    final scheme = ShadTheme.of(context).colorScheme;

    final bg = isError ? scheme.destructive : scheme.card;
    final fg = isError ? scheme.destructiveForeground : scheme.cardForeground;
    final muted = isError
        ? scheme.destructiveForeground.withValues(alpha: 0.75)
        : scheme.mutedForeground;
    final icon = isError ? LucideIcons.circleX : LucideIcons.circleCheck;
    final iconColor = isError ? scheme.destructiveForeground : const Color(0xFF22c55e);
    final borderColor = isError ? Colors.transparent : scheme.border;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: GestureDetector(
                onVerticalDragUpdate: _onDragUpdate,
                onVerticalDragEnd: _onDragEnd,
                child: Transform.translate(
                  offset: Offset(0, _dragOffset.clamp(-300.0, 0.0)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, color: iconColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  color: fg,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              if (widget.subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.subtitle!,
                                  style: TextStyle(color: muted, fontSize: 13),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _dismiss,
                          child: Icon(LucideIcons.x, size: 16, color: muted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
