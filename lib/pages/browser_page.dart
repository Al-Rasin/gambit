import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class BrowserPage extends StatefulWidget {
  final String? initialUrl;

  const BrowserPage({super.key, this.initialUrl});

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  late final WebViewController _controller;
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  double _loadingProgress = 0;
  String _currentUrl = '';
  bool _canGoBack = false;
  bool _canGoForward = false;
  final FocusNode _urlFocusNode = FocusNode();
  bool _isMobileView = true; // Default to mobile view

  // Popular game sites
  final List<Map<String, String>> _bookmarks = [
    {'name': 'CrazyGames', 'url': 'https://www.crazygames.com/'},
    {'name': 'Poki', 'url': 'https://poki.com/'},
    {'name': 'Cool Math Games', 'url': 'https://www.coolmathgames.com/'},
    {'name': 'Addicting Games', 'url': 'https://www.addictinggames.com/'},
    {'name': 'Armor Games', 'url': 'https://armorgames.com/'},
    {'name': 'Friv', 'url': 'https://www.friv.com/'},
    {'name': 'Lagged', 'url': 'https://lagged.com/'},
    {'name': 'Y8', 'url': 'https://www.y8.com/'},
    {'name': 'Miniclip', 'url': 'https://www.miniclip.com/'},
    {'name': 'Kongregate', 'url': 'https://www.kongregate.com/'},
  ];

  @override
  void initState() {
    super.initState();

    // Enable all orientations for browser
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _currentUrl = widget.initialUrl ?? 'https://www.google.com/search?q=online+games';
    _urlController.text = _currentUrl;
    _initializeWebView();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _urlFocusNode.dispose();

    // Reset to portrait only when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  void _initializeWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    // Configure platform-specific settings
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false);
      final androidController = controller.platform as AndroidWebViewController;
      androidController
        ..setMediaPlaybackRequiresUserGesture(false)
        ..setOnPlatformPermissionRequest((request) {
          // Grant permissions for camera, microphone, etc.
          request.grant();
        });
    }

    if (controller.platform is WebKitWebViewController) {
      (controller.platform as WebKitWebViewController)
        .setInspectable(false);
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Start with mobile user agent by default
      ..setUserAgent(_isMobileView
          ? 'Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36'
          : 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
      ..setBackgroundColor(Colors.white)
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation
            return NavigationDecision.navigate;
          },
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress / 100;
                _isLoading = progress < 100;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _currentUrl = url;
                _urlController.text = url;
              });
              _updateNavigationState();
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _currentUrl = url;
                _urlController.text = url;
              });
              _updateNavigationState();
            }
          },
          onWebResourceError: (WebResourceError error) {
            // Ignore non-critical errors
          },
        ),
      )
      ..loadRequest(Uri.parse(_currentUrl));

    _controller = controller;
  }

  Future<void> _updateNavigationState() async {
    final canGoBack = await _controller.canGoBack();
    final canGoForward = await _controller.canGoForward();
    if (mounted) {
      setState(() {
        _canGoBack = canGoBack;
        _canGoForward = canGoForward;
      });
    }
  }


  void _loadUrl(String url) {
    String finalUrl = url;

    // Add http:// if no protocol specified
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      // Check if it looks like a search query
      if (!url.contains('.')) {
        // It's a search query
        finalUrl = 'https://www.google.com/search?q=${Uri.encodeComponent(url)}';
      } else {
        // It's a URL without protocol
        finalUrl = 'https://$url';
      }
    }

    _controller.loadRequest(Uri.parse(finalUrl));
    _urlFocusNode.unfocus();
  }

  void _toggleViewMode() {
    setState(() {
      _isMobileView = !_isMobileView;
    });
    // Update user agent
    _controller.setUserAgent(_isMobileView
        ? 'Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36'
        : 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
    // Reload the page with new user agent
    _controller.reload();
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Browser Controls
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Address Bar
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          // Home Button
                          IconButton(
                            icon: const Icon(Icons.home),
                            onPressed: () => Navigator.pop(context),
                            tooltip: 'Home',
                          ),
                          // Address Field
                          Expanded(
                            child: TextField(
                              controller: _urlController,
                              focusNode: _urlFocusNode,
                              decoration: InputDecoration(
                                hintText: 'Search or enter URL',
                                filled: true,
                                fillColor: Theme.of(context).scaffoldBackgroundColor,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: _isLoading
                                    ? Container(
                                        width: 20,
                                        height: 20,
                                        padding: const EdgeInsets.all(12),
                                        child: const CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Icon(
                                        Icons.search,
                                        color: Theme.of(context).hintColor,
                                      ),
                              ),
                              onSubmitted: _loadUrl,
                              textInputAction: TextInputAction.go,
                            ),
                          ),
                          // Refresh Button
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => _controller.reload(),
                            tooltip: 'Refresh',
                          ),
                        ],
                      ),
                    ),
                    // Navigation Controls
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: _canGoBack ? () => _controller.goBack() : null,
                            tooltip: 'Back',
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: _canGoForward ? () => _controller.goForward() : null,
                            tooltip: 'Forward',
                          ),
                          const Spacer(),
                          // View Mode Toggle
                          IconButton(
                            icon: Icon(_isMobileView ? Icons.smartphone : Icons.desktop_windows),
                            onPressed: _toggleViewMode,
                            tooltip: _isMobileView ? 'Switch to Desktop View' : 'Switch to Mobile View',
                          ),
                          // Bookmarks Menu
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.bookmarks),
                            tooltip: 'Game Sites',
                            onSelected: (url) => _loadUrl(url),
                            itemBuilder: (context) => _bookmarks.map((bookmark) {
                              return PopupMenuItem<String>(
                                value: bookmark['url']!,
                                child: Row(
                                  children: [
                                    const Icon(Icons.sports_esports, size: 20),
                                    const SizedBox(width: 8),
                                    Text(bookmark['name']!),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    // Loading Bar
                    if (_isLoading)
                      LinearProgressIndicator(
                        value: _loadingProgress,
                        minHeight: 2,
                      ),
                  ],
                ),
              ),
              // WebView
              Expanded(
                child: WebViewWidget(controller: _controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}