import 'package:flutter/material.dart';
import 'home_page.dart';
import '../providers/theme_provider.dart';

class SplashScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const SplashScreen({super.key, required this.themeProvider});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _pulseController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _dotController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);

    _animationController.forward();
    _pulseController.repeat(reverse: true);
    _dotController.repeat();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage(themeProvider: widget.themeProvider)));
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
                cacheWidth: 1080,
                filterQuality: FilterQuality.low,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color.fromRGBO(0, 0, 0, 0.3), const Color.fromRGBO(0, 0, 0, 0.5)],
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'GAMBIT',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                      shadows: [Shadow(blurRadius: 10.0, color: Colors.black54, offset: Offset(2.0, 2.0))],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Your Ultimate Gaming Hub', style: TextStyle(fontSize: 18, color: Colors.white70, letterSpacing: 1)),
                  const SizedBox(height: 60),
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 80,
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                const Color.fromRGBO(255, 255, 255, 0.8),
                                Colors.white,
                                const Color.fromRGBO(255, 255, 255, 0.8),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: const Color.fromRGBO(255, 255, 255, 0.5), blurRadius: 10, spreadRadius: 2)],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _dotController,
                    builder: (context, child) {
                      int dotCount = (_dotController.value * 4).floor() % 4;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: index < dotCount ? Colors.white : const Color.fromRGBO(255, 255, 255, 0.3),
                              shape: BoxShape.circle,
                              boxShadow: index < dotCount
                                  ? [BoxShadow(color: const Color.fromRGBO(255, 255, 255, 0.6), blurRadius: 8, spreadRadius: 2)]
                                  : null,
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
