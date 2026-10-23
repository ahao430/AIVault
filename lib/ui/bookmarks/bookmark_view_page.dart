import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 书签目标页：应用内 WebView。
/// 支持网页内后退（系统返回键优先退网页历史）、刷新、复制地址。
class BookmarkViewPage extends StatefulWidget {
  const BookmarkViewPage({super.key, required this.name, required this.url});

  final String name;
  final String url;

  @override
  State<BookmarkViewPage> createState() => _BookmarkViewPageState();
}

class _BookmarkViewPageState extends State<BookmarkViewPage> {
  late final WebViewController _controller;
  String? _pageTitle;
  double _progress = 0;
  bool _canGoBack = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) async {
          // webview_flutter 没有同步 title API：JS 取 document.title
          Object? title;
          try {
            title = await _controller.runJavaScriptReturningResult('document.title');
          } catch (_) {}
          _canGoBack = await _controller.canGoBack();
          if (!mounted) return;
          setState(() {
            _progress = 1;
            // 返回值是 JS 字符串字面量（带引号），剥掉
            final raw = title is String ? title : null;
            _pageTitle = raw == null
                ? null
                : raw.startsWith('"') && raw.endsWith('"') && raw.length > 1
                    ? raw.substring(1, raw.length - 1)
                    : raw;
          });
        },
        onProgress: (p) => setState(() => _progress = p / 100),
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // 预捕获（回调里跨 async 使用 context 会触发 lint）
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    return PopScope(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
          return;
        }
        navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            (_pageTitle?.isNotEmpty ?? false) ? _pageTitle! : widget.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              tooltip: '刷新',
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.reload(),
            ),
            IconButton(
              tooltip: '复制网址',
              icon: const Icon(Icons.link),
              onPressed: () async {
                final url = await _controller.currentUrl();
                if (url == null) return;
                await Clipboard.setData(ClipboardData(text: url));
                messenger.showSnackBar(const SnackBar(content: Text('已复制网址')));
              },
            ),
          ],
        ),
        body: Column(
          children: [
            if (_progress < 1)
              LinearProgressIndicator(
                  value: _progress, minHeight: 2, backgroundColor: cs.surfaceContainerHighest),
            Expanded(child: WebViewWidget(controller: _controller)),
          ],
        ),
      ),
    );
  }
}
