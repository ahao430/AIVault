import 'dart:async';

import 'package:flutter/material.dart';

/// 居中轻提示：替代 Material 默认的底部白色 SnackBar。
///
/// 深色半透明圆角 + 图标，居中弹出，自动淡出；连续调用时新提示
/// 顶替旧提示。不拦截任何点击事件。
class Toast {
  Toast._();

  static OverlayEntry? _entry;

  static void show(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration duration = const Duration(milliseconds: 2400),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    showOn(overlay, message, icon: icon, duration: duration);
  }

  /// 已捕获 rootOverlay 的异步场景（await 之后 context 可能失效）。
  static void showOn(
    OverlayState overlay,
    String message, {
    IconData? icon,
    Duration duration = const Duration(milliseconds: 2400),
  }) {
    dismiss();
    _entry = OverlayEntry(
      builder: (_) => _ToastView(
        message: message,
        icon: icon,
        duration: duration,
        onDone: dismiss,
      ),
    );
    overlay.insert(_entry!);
  }

  static void dismiss() {
    _entry?.remove();
    _entry = null;
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({
    required this.message,
    required this.duration,
    required this.onDone,
    this.icon,
  });

  final String message;
  final IconData? icon;
  final Duration duration;
  final VoidCallback onDone;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    // 留出淡出时间，到点先 reverse 再移除 OverlayEntry
    final hold = widget.duration - const Duration(milliseconds: 160);
    Timer(hold > Duration.zero ? hold : Duration.zero, () async {
      if (!mounted) return;
      await _controller.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 20, color: Colors.white70),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
