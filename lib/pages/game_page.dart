import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Platform imports for Android/iOS specific features
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class GamePage extends StatefulWidget {
  final String? initialUrl;

  const GamePage({super.key, this.initialUrl});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0;
  String _currentUrl = 'https://www.crazygames.com/';
  String _siteName = 'CrazyGames';
  String _homeUrl = 'https://www.crazygames.com/';
  bool _canGoBack = false;
  bool _canGoForward = false;
  bool _hasError = false;
  bool _showAppBar = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Enable all orientations for game pages
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _currentUrl = widget.initialUrl ?? 'https://www.crazygames.com/';
    _setSiteInfo(_currentUrl);
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _animationController.forward();

    // Initialize cookies before WebView
    _initializeCookies();
    _initializeWebView();
    _hideAppBarAfterDelay();
  }

  Future<void> _initializeCookies() async {
    final WebViewCookieManager cookieManager = WebViewCookieManager();
    // Accept all cookies for OAuth to work
    await cookieManager.setCookie(const WebViewCookie(name: 'cookie_enabled', value: 'true', domain: '.google.com', path: '/'));
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Clear WebView cache to free memory
    _controller.clearCache();
    _controller.clearLocalStorage();
    // Reset to portrait only when leaving game page
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _setSiteInfo(String url) {
    if (url.contains('crazygames.com')) {
      _siteName = 'CrazyGames';
      _homeUrl = 'https://www.crazygames.com/';
    } else if (url.contains('poki.com')) {
      _siteName = 'Poki';
      _homeUrl = 'https://poki.com/';
    } else if (url.contains('addictinggames.com')) {
      _siteName = 'Addicting Games';
      _homeUrl = 'https://www.addictinggames.com/';
    } else if (url.contains('coolmathgames.com')) {
      _siteName = 'Cool Math Games';
      _homeUrl = 'https://www.coolmathgames.com/';
    } else if (url.contains('lagged.com')) {
      _siteName = 'Lagged';
      _homeUrl = 'https://lagged.com/';
    } else if (url.contains('armorgames.com')) {
      _siteName = 'Armor Games';
      _homeUrl = 'https://armorgames.com/';
    } else if (url.contains('friv.com')) {
      _siteName = 'Friv';
      _homeUrl = 'https://www.friv.com/';
    } else {
      _siteName = 'Game Browser';
      _homeUrl = _currentUrl;
    }
  }

  void _goToSiteHome() {
    _controller.loadRequest(Uri.parse(_homeUrl));
  }

  void _hideAppBarAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isLoading) {
        setState(() {
          _showAppBar = false;
        });
        _animationController.reverse();
      }
    });
  }

  void _toggleAppBar() {
    if (!mounted) return;
    setState(() {
      _showAppBar = !_showAppBar;
    });
    if (_showAppBar) {
      _animationController.forward();
      _hideAppBarAfterDelay();
    } else {
      _animationController.reverse();
    }
  }

  void _initializeWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        limitsNavigationsToAppBoundDomains: false,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    // Configure platform-specific settings
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      final androidController = controller.platform as AndroidWebViewController;
      androidController
        ..setMediaPlaybackRequiresUserGesture(false)
        ..setOnPlatformPermissionRequest((request) {
          // Grant permissions for camera, microphone, etc.
          request.grant();
        });
    }

    if (controller.platform is WebKitWebViewController) {
      final webKitController = controller.platform as WebKitWebViewController;
      webKitController
        ..setInspectable(true)
        ..setAllowsBackForwardNavigationGestures(true);
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Use Chrome desktop user agent for better OAuth compatibility
      ..setUserAgent('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
      ..setBackgroundColor(Colors.white)
      ..enableZoom(true)
      ..setOnConsoleMessage((JavaScriptConsoleMessage message) {
        debugPrint('JS Console: ${message.level.name}: ${message.message}');
      })
      ..setOnJavaScriptAlertDialog((JavaScriptAlertDialogRequest request) async {
        // Handle JavaScript alerts
        return Future.value();
      })
      ..setOnJavaScriptConfirmDialog((JavaScriptConfirmDialogRequest request) async {
        // Auto-confirm for OAuth flows
        return true;
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // Log navigation for debugging
            debugPrint('Navigating to: ${request.url}');

            // Intercept Google OAuth and show helpful message
            if (request.url.contains('accounts.google.com') && (request.url.contains('oauth') || request.url.contains('signin'))) {
              debugPrint('Google OAuth detected - not supported in WebView');
              _showOAuthAlternativeDialog();
              return NavigationDecision.prevent;
            }

            // Allow all other navigation
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
                _setSiteInfo(url);
                _hasError = false;
              });
              _updateNavigationState();
            }
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');

            if (mounted) {
              setState(() {
                _isLoading = false;
                _currentUrl = url;
                _hasError = false;
              });
              _updateNavigationState();

              // Detect OAuth error messages
              _controller
                  .runJavaScript('''
                (function() {
                  var bodyText = document.body ? document.body.innerText : '';
                  if (bodyText.includes('browser or app may not be secure') ||
                      bodyText.includes('missing initial state') ||
                      bodyText.includes('Unable to process request')) {
                    return 'oauth_error';
                  }
                  return 'ok';
                })();
              ''')
                  .then((Object? result) {
                    if (result != null && result.toString() == 'oauth_error' && mounted) {
                      _showOAuthErrorDialog();
                    }
                  })
                  .catchError((error) {
                    // Ignore JavaScript errors
                    debugPrint('JS error checking OAuth: $error');
                  });

              // Inject JavaScript to handle OAuth and popups
              _controller.runJavaScript('''
                // Override window.open to handle OAuth popups
                if (!window._originalOpen) {
                  window._originalOpen = window.open;
                  window.open = function(url, target, features) {
                    console.log('Window.open intercepted:', url);

                    // For OAuth URLs, try to open in same window
                    if (url && (url.includes('accounts.google.com') || url.includes('oauth'))) {
                      // Try to handle OAuth in current context
                      window.location.href = url;
                      return window;
                    }

                    // For other popups, use original behavior
                    return window._originalOpen.call(this, url, target, features);
                  };
                }

                // Ensure sessionStorage is available
                if (typeof(Storage) !== "undefined") {
                  console.log('Storage available');
                  // Try to preserve OAuth state
                  if (!sessionStorage.getItem('oauth_init')) {
                    sessionStorage.setItem('oauth_init', Date.now().toString());
                  }
                }

                // Handle postMessage for OAuth communication
                window.addEventListener('message', function(e) {
                  console.log('PostMessage received:', e.origin, e.data);
                  // Handle OAuth callbacks
                  if (e.data && e.data.type === 'auth-callback') {
                    console.log('Auth callback received');
                    window.location.reload();
                  }
                });

                // Enable third-party cookies for OAuth
                document.cookie = "SameSite=None; Secure";
              ''');

              if (url != 'about:blank') {
                _hideAppBarAfterDelay();
              }
            }
          },
          onWebResourceError: (WebResourceError error) {
            // Only show error for main frame failures, ignore sub-resource errors
            if (mounted && error.isForMainFrame == true) {
              // Additional filtering: ignore certain error codes that are not critical
              // -1009: No internet connection
              // -1001: Request timed out
              // -1003: Server not found
              // Only show error screen for critical network errors
              if (error.errorCode == -1009 || error.errorCode == -1001 || error.errorCode == -1003) {
                setState(() {
                  _hasError = true;
                  _isLoading = false;
                });
              }
            }
          },
          onHttpAuthRequest: (HttpAuthRequest request) async {
            // Auto-handle HTTP auth if needed
            debugPrint('HTTP Auth requested');
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

  Future<void> _refresh() async {
    await _controller.reload();
  }

  void _showOAuthErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign-In Limitation'),
        content: const Text(
          'Google sign-in is restricted in this view for security reasons.\n\n'
          'To sign in with Google:\n'
          '1. Use the Browser mode (from home screen)\n'
          '2. Or visit the game site directly in your browser\n'
          '3. Once signed in there, return to the app\n\n'
          'Alternatively, try creating an account with email instead.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to home
            },
            child: const Text('Go to Browser'),
          ),
        ],
      ),
    );
  }

  void _showOAuthAlternativeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Sign-In Alternative'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Google blocks sign-in in embedded browsers for security.', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Alternative options:'),
            SizedBox(height: 8),
            Text('• Sign up with email instead'),
            Text('• Use the Browser mode (home screen)'),
            Text('• Sign in on the website first'),
            SizedBox(height: 12),
            Text('Most game sites offer email sign-up as an alternative.', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Go back to the game site
              _controller.goBack();
            },
            child: const Text('Try Email Sign-Up'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go to home
            },
            child: const Text('Use Browser Mode'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        // Check if webview can go back
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBodyBehindAppBar: true,
        appBar: _showAppBar
            ? PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -100 * (1 - _animationController.value)),
                      child: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        flexibleSpace: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.deepPurple.shade800.withValues(alpha: 0.95),
                                Colors.blue.shade600.withValues(alpha: 0.95),
                                Colors.indigo.shade700.withValues(alpha: 0.95),
                              ],
                            ),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3))],
                          ),
                        ),
                        title: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                            ),
                            child: GestureDetector(
                              onTap: _goToSiteHome,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.home_outlined, size: 16, color: Colors.white.withValues(alpha: 0.9)),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      _siteName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.white,
                                        shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 2, offset: const Offset(0, 1))],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.launch, size: 12, color: Colors.white.withValues(alpha: 0.7)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        leading: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.home, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                            tooltip: 'Back to Home',
                          ),
                        ),
                        actions: [
                          Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _canGoBack ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _canGoBack ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: IconButton(
                              onPressed: _canGoBack ? () => _controller.goBack() : null,
                              icon: Icon(Icons.arrow_back, color: _canGoBack ? Colors.white : Colors.white.withValues(alpha: 0.4)),
                              tooltip: 'Go Back',
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _canGoForward ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _canGoForward ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: IconButton(
                              onPressed: _canGoForward ? () => _controller.goForward() : null,
                              icon: Icon(Icons.arrow_forward, color: _canGoForward ? Colors.white : Colors.white.withValues(alpha: 0.4)),
                              tooltip: 'Go Forward',
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: IconButton(
                              onPressed: _refresh,
                              icon: const Icon(Icons.refresh, color: Colors.white),
                              tooltip: 'Refresh',
                            ),
                          ),
                        ],
                        bottom: _isLoading
                            ? PreferredSize(
                                preferredSize: const Size.fromHeight(6),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: _loadingProgress,
                                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.9)),
                                      minHeight: 6,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              )
            : null,
        body: SafeArea(
          child: Stack(
            children: [
              // Add theme-aware background container
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
                            const SizedBox(height: 16),
                            Text('Failed to load page', style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 8),
                            Text('Check your internet connection and try again', style: Theme.of(context).textTheme.bodyLarge),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(onPressed: _refresh, icon: const Icon(Icons.refresh), label: const Text('Retry')),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          WebViewWidget(controller: _controller),
                          if (_isLoading && _loadingProgress == 0)
                            Container(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(color: Theme.of(context).primaryColor),
                                    const SizedBox(height: 16),
                                    Text('Loading game...', style: Theme.of(context).textTheme.bodyLarge),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
              // Gesture detector overlay for app bar controls
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 150,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (!_showAppBar) _toggleAppBar();
                  },
                  onPanDown: (details) {
                    if (details.globalPosition.dy < 100 && !_showAppBar) {
                      _toggleAppBar();
                    }
                  },
                  onPanUpdate: (details) {
                    if (details.globalPosition.dy < 150 && details.delta.dy > 0 && !_showAppBar) {
                      _toggleAppBar();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _currentUrl.contains('about:blank') || (_isLoading && _loadingProgress > 0 && _loadingProgress < 1)
            ? FloatingActionButton(
                onPressed: () {
                  debugPrint('Manual reload triggered');
                  _controller.loadRequest(Uri.parse(_homeUrl));
                },
                tooltip: 'Reload Page',
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.refresh),
              )
            : null,
      ),
    );
  }
}
