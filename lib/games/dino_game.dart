import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';

enum ObstacleType { barrier, building, airplane, helicopter, drone }

class DinoGame extends StatefulWidget {
  final bool isCheatModeEnabled;

  const DinoGame({super.key, this.isCheatModeEnabled = false});

  @override
  State<DinoGame> createState() => _DinoGameState();
}

class _DinoGameState extends State<DinoGame> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _dinoRunController;
  late AnimationController _cloudController;
  Timer? _gameTimer;

  static const double groundEpsilon = 0.5;
  bool get _isOnGround => dinoY <= groundEpsilon;

  // Game constants
  static const double gravity = -1600;
  static const double jumpVelocity = 600;
  static const double groundHeight = 100;
  static const double initialSpeed = 300;
  static const double maxSpeed = 600;

  // Game state
  double dinoY = 0;
  double dinoVelocity = 0;
  double gameSpeed = initialSpeed;
  List<Obstacle> obstacles = [];
  List<Cloud> clouds = [];
  bool isGameStarted = false;
  bool isGameOver = false;
  int score = 0;
  int highScore = 0;
  bool isJumping = false;
  int frameCount = 0;

  @override
  void initState() {
    super.initState();
    _dinoRunController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100))..repeat();

    _cloudController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();

    _loadHighScore();
    _resetGame();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Generate initial clouds only once after dependencies are available
    if (clouds.isEmpty) {
      _generateInitialClouds();
    }
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('dino_high_score') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    // Save high score regardless of cheat mode
    if (score > highScore) {
      setState(() {
        highScore = score;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('dino_high_score', highScore);
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _dinoRunController.dispose();
    _cloudController.dispose();
    super.dispose();
  }

  void _generateInitialClouds() {
    final random = Random();
    for (int i = 0; i < 3; i++) {
      clouds.add(
        Cloud(x: random.nextDouble() * MediaQuery.of(context).size.width, y: random.nextDouble() * 150 + 50, speed: random.nextDouble() * 30 + 20),
      );
    }
  }

  void _resetGame() {
    setState(() {
      dinoY = 0;
      dinoVelocity = 0;
      obstacles = [];
      isGameStarted = false;
      isGameOver = false;
      score = 0;
      gameSpeed = initialSpeed;
      isJumping = false;
      frameCount = 0;
    });
  }

  void _startGame() {
    if (isGameStarted) return;

    setState(() {
      isGameStarted = true;
      isGameOver = false;
    });

    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _updateGame(0.016);
    });
  }

  void _jump() {
    if (isGameOver) {
      _resetGame();
      return;
    }

    if (!isGameStarted) {
      _startGame();
      _performJump();
      return;
    }

    // Allow jump only when on ground
    if (_isOnGround && !isJumping) {
      _performJump();
    }
  }

  void _performJump() {
    setState(() {
      dinoVelocity = jumpVelocity;
      isJumping = true;
    });
    HapticFeedback.lightImpact();
  }

  void _updateGame(double dt) {
    if (!isGameStarted || isGameOver) return;

    setState(() {
      frameCount++;

      // Update score
      if (frameCount % 10 == 0) {
        score++;

        // Save high score immediately in cheat mode since game won't end
        if (widget.isCheatModeEnabled && score > highScore) {
          _saveHighScore();
        }

        // Increase speed gradually
        if (score % 100 == 0 && gameSpeed < maxSpeed) {
          gameSpeed = min(maxSpeed, gameSpeed + 50);
        }
      }

      // Update dino physics
      if (isJumping || dinoY > 0) {
        dinoVelocity += gravity * dt;
        dinoY += dinoVelocity * dt;

        // Check if landed
        if (dinoY <= 0) {
          dinoY = 0; // snap to ground
          dinoVelocity = 0;
          isJumping = false;
        }
      }

      // Update clouds
      for (var cloud in clouds) {
        cloud.x -= cloud.speed * dt;
        if (cloud.x < -100) {
          cloud.x = MediaQuery.of(context).size.width + Random().nextDouble() * 200;
          cloud.y = Random().nextDouble() * 150 + 50;
        }
      }

      // Update obstacles
      for (var obstacle in obstacles) {
        obstacle.x -= gameSpeed * dt;
      }

      // Remove off-screen obstacles
      obstacles.removeWhere((obstacle) => obstacle.x < -100);

      // Generate new obstacles
      if (obstacles.isEmpty || obstacles.last.x < MediaQuery.of(context).size.width - 300) {
        _generateObstacle();
      }

      // Check collisions
      _checkCollisions();
    });
  }

  void _generateObstacle() {
    final random = Random();
    final screenWidth = MediaQuery.of(context).size.width;

    // Random obstacle type
    ObstacleType type;
    final typeRandom = random.nextDouble();
    if (typeRandom < 0.35) {
      type = ObstacleType.barrier;
    } else if (typeRandom < 0.6) {
      type = ObstacleType.building;
    } else if (typeRandom < 0.75) {
      type = ObstacleType.airplane;
    } else if (typeRandom < 0.9) {
      type = ObstacleType.helicopter;
    } else {
      type = ObstacleType.drone;
    }

    double width, height, y;
    switch (type) {
      case ObstacleType.barrier:
        width = 35;
        height = 45;
        y = 0;
        break;
      case ObstacleType.building:
        width = 50;
        height = 70;
        y = 0;
        break;
      case ObstacleType.airplane:
        width = 70;
        height = 30;
        y = random.nextDouble() * 70 + 40; // Airplanes fly high
        break;
      case ObstacleType.helicopter:
        width = 55;
        height = 35;
        y = random.nextDouble() * 60 + 20; // Helicopters fly at medium height
        break;
      case ObstacleType.drone:
        width = 35;
        height = 25;
        y = random.nextDouble() * 80 + 10; // Drones fly at various heights
        break;
    }

    obstacles.add(Obstacle(x: screenWidth + random.nextDouble() * 200, y: y, width: width, height: height, type: type));
  }

  void _checkCollisions() {
    // Skip collision detection if cheat mode is enabled
    if (widget.isCheatModeEnabled) {
      return;
    }

    final dinoLeft = MediaQuery.of(context).size.width / 2 - 150;
    final dinoRight = dinoLeft + 40;
    final dinoTop = groundHeight + dinoY;
    final dinoBottom = dinoTop + 60;

    for (var obstacle in obstacles) {
      final obstacleLeft = obstacle.x;
      final obstacleRight = obstacle.x + obstacle.width;
      final obstacleTop = groundHeight + obstacle.y;
      final obstacleBottom = obstacleTop + obstacle.height;

      // Add some margin for better gameplay
      final margin = 5.0;
      if (dinoRight - margin > obstacleLeft &&
          dinoLeft + margin < obstacleRight &&
          dinoBottom - margin > obstacleTop &&
          dinoTop + margin < obstacleBottom) {
        _gameOver();
        return;
      }
    }
  }

  void _gameOver() {
    setState(() {
      isGameOver = true;
    });
    _gameTimer?.cancel();
    _saveHighScore();
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Robot Runner',
              style: TextStyle(color: Theme.of(context).textTheme.headlineMedium?.color, fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _jump,
        child: Stack(
          children: [
            // Game area
            Center(
              child: SizedBox(
                width: screenWidth,
                height: screenHeight,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Sky with clouds
                    ...clouds.map((cloud) {
                      return Positioned(
                        left: cloud.x,
                        top: cloud.y,
                        child: Icon(Icons.cloud, size: 60, color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
                      );
                    }),

                    // Ground
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: groundHeight,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade400,
                          border: Border(top: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade600, width: 3)),
                        ),
                        child: CustomPaint(
                          painter: GroundPainter(offset: frameCount * gameSpeed * 0.016, isDarkMode: isDarkMode),
                        ),
                      ),
                    ),

                    // Obstacles
                    ...obstacles.map((obstacle) {
                      return Positioned(left: obstacle.x, bottom: groundHeight + obstacle.y, child: _buildObstacle(obstacle));
                    }),

                    // Dino
                    Positioned(
                      left: screenWidth / 2 - 150,
                      bottom: groundHeight + dinoY,
                      child: AnimatedBuilder(
                        animation: _dinoRunController,
                        builder: (context, child) {
                          return _buildDino();
                        },
                      ),
                    ),

                    // Score
                    Positioned(
                      top: 50,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'HI ${highScore.toString().padLeft(5, '0')}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text(
                            score.toString().padLeft(5, '0'),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.headlineMedium?.color,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Start/Game Over message
                    if (!isGameStarted || isGameOver)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).cardTheme.color?.withValues(alpha: 0.95) ??
                                (isDarkMode ? Colors.black.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.95)),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400, width: 2),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isGameOver) ...[
                                Text(
                                  'GAME OVER',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).textTheme.headlineLarge?.color,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Score: $score',
                                  style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyLarge?.color, fontFamily: 'monospace'),
                                ),
                                if (score > 0 && score == highScore)
                                  Text(
                                    'NEW HIGH SCORE!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade600,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                              ] else ...[
                                Icon(Icons.sports_handball, size: 60, color: Theme.of(context).iconTheme.color),
                                const SizedBox(height: 20),
                                Text(
                                  'TAP TO START',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).textTheme.headlineMedium?.color,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              Text(
                                'Tap to jump',
                                style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDino() {
    final isRunning = isGameStarted && !isGameOver && !isJumping;
    final runFrame = isRunning ? (_dinoRunController.value * 2).floor() : 0;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 60,
      height: 60,
      child: CustomPaint(
        painter: RobotPainter(isRunning: isRunning, runFrame: runFrame, isDarkMode: isDarkMode, jumpHeight: dinoY),
      ),
    );
  }

  Widget _buildObstacle(Obstacle obstacle) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: obstacle.width,
      height: obstacle.height,
      child: CustomPaint(
        painter: ObstaclePainter(type: obstacle.type, isDarkMode: isDarkMode),
      ),
    );
  }
}

class Obstacle {
  double x;
  double y;
  double width;
  double height;
  ObstacleType type;

  Obstacle({required this.x, required this.y, required this.width, required this.height, required this.type});
}

class Cloud {
  double x;
  double y;
  double speed;

  Cloud({required this.x, required this.y, required this.speed});
}

class RobotPainter extends CustomPainter {
  final bool isRunning;
  final int runFrame;
  final bool isDarkMode;
  final double jumpHeight;

  RobotPainter({required this.isRunning, required this.runFrame, required this.isDarkMode, required this.jumpHeight});

  @override
  void paint(Canvas canvas, Size size) {
    // Robot metallic colors
    final bodyPaint = Paint()
      ..color = isDarkMode ? Colors.blueGrey.shade400 : Colors.blueGrey.shade700
      ..style = PaintingStyle.fill;

    final accentPaint = Paint()
      ..color = isDarkMode ? Colors.cyan.shade300 : Colors.cyan.shade600
      ..style = PaintingStyle.fill;

    final jointPaint = Paint()
      ..color = isDarkMode ? Colors.grey.shade600 : Colors.grey.shade800
      ..style = PaintingStyle.fill;

    // Draw Robot
    // Head (helmet-like)
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(22, 5, 16, 14), Radius.circular(3)), bodyPaint);

    // Visor (glowing)
    final visorPaint = Paint()
      ..color = isDarkMode ? Colors.cyan.shade200 : Colors.cyan.shade400
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(24, 8, 12, 6), visorPaint);

    // Eye lights
    canvas.drawCircle(Offset(27, 11), 1.5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(33, 11), 1.5, Paint()..color = Colors.white);

    // Antenna
    canvas.drawRect(Rect.fromLTWH(29, 2, 2, 4), jointPaint);
    canvas.drawCircle(Offset(30, 2), 2, accentPaint);

    // Body (torso)
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(20, 18, 20, 22), Radius.circular(2)), bodyPaint);

    // Chest panel
    canvas.drawRect(Rect.fromLTWH(24, 21, 12, 8), accentPaint);
    // Power core
    canvas.drawCircle(Offset(30, 25), 3, Paint()..color = Colors.yellow.shade600);
    canvas.drawCircle(Offset(30, 25), 2, Paint()..color = Colors.yellow.shade300);

    // Control panel lines
    final panelPaint = Paint()
      ..color = jointPaint.color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(26, 31), Offset(34, 31), panelPaint);
    canvas.drawLine(Offset(26, 33), Offset(34, 33), panelPaint);
    canvas.drawLine(Offset(26, 35), Offset(34, 35), panelPaint);

    // Arms
    // Left arm
    canvas.drawRect(Rect.fromLTWH(15, 20, 5, 12), bodyPaint);
    canvas.drawCircle(Offset(17.5, 20), 2.5, jointPaint); // Shoulder joint
    canvas.drawRect(Rect.fromLTWH(14, 31, 6, 8), bodyPaint); // Forearm
    canvas.drawRect(Rect.fromLTWH(13, 38, 7, 4), accentPaint); // Hand

    // Right arm
    canvas.drawRect(Rect.fromLTWH(40, 20, 5, 12), bodyPaint);
    canvas.drawCircle(Offset(42.5, 20), 2.5, jointPaint); // Shoulder joint
    canvas.drawRect(Rect.fromLTWH(40, 31, 6, 8), bodyPaint); // Forearm
    canvas.drawRect(Rect.fromLTWH(40, 38, 7, 4), accentPaint); // Hand

    // Legs with mechanical joints
    if (isRunning) {
      if (runFrame == 0) {
        // Left leg forward
        canvas.drawRect(Rect.fromLTWH(22, 40, 7, 10), bodyPaint);
        canvas.drawCircle(Offset(25.5, 40), 2, jointPaint); // Hip joint
        canvas.drawRect(Rect.fromLTWH(21, 49, 8, 8), bodyPaint); // Lower leg
        canvas.drawCircle(Offset(25, 49), 1.5, jointPaint); // Knee joint
        canvas.drawRect(Rect.fromLTWH(19, 56, 12, 4), accentPaint); // Foot

        // Right leg back
        canvas.drawRect(Rect.fromLTWH(31, 40, 7, 8), bodyPaint);
        canvas.drawCircle(Offset(34.5, 40), 2, jointPaint); // Hip joint
        canvas.drawRect(Rect.fromLTWH(30, 47, 8, 8), bodyPaint); // Lower leg
        canvas.drawCircle(Offset(34, 47), 1.5, jointPaint); // Knee joint
        canvas.drawRect(Rect.fromLTWH(28, 54, 12, 4), accentPaint); // Foot
      } else {
        // Right leg forward
        canvas.drawRect(Rect.fromLTWH(31, 40, 7, 10), bodyPaint);
        canvas.drawCircle(Offset(34.5, 40), 2, jointPaint); // Hip joint
        canvas.drawRect(Rect.fromLTWH(30, 49, 8, 8), bodyPaint); // Lower leg
        canvas.drawCircle(Offset(34, 49), 1.5, jointPaint); // Knee joint
        canvas.drawRect(Rect.fromLTWH(28, 56, 12, 4), accentPaint); // Foot

        // Left leg back
        canvas.drawRect(Rect.fromLTWH(22, 40, 7, 8), bodyPaint);
        canvas.drawCircle(Offset(25.5, 40), 2, jointPaint); // Hip joint
        canvas.drawRect(Rect.fromLTWH(21, 47, 8, 8), bodyPaint); // Lower leg
        canvas.drawCircle(Offset(25, 47), 1.5, jointPaint); // Knee joint
        canvas.drawRect(Rect.fromLTWH(19, 54, 12, 4), accentPaint); // Foot
      }
    } else {
      // Standing position
      // Left leg
      canvas.drawRect(Rect.fromLTWH(22, 40, 7, 10), bodyPaint);
      canvas.drawCircle(Offset(25.5, 40), 2, jointPaint); // Hip joint
      canvas.drawRect(Rect.fromLTWH(21, 49, 8, 8), bodyPaint); // Lower leg
      canvas.drawCircle(Offset(25, 49), 1.5, jointPaint); // Knee joint
      canvas.drawRect(Rect.fromLTWH(19, 56, 12, 4), accentPaint); // Foot

      // Right leg
      canvas.drawRect(Rect.fromLTWH(31, 40, 7, 10), bodyPaint);
      canvas.drawCircle(Offset(34.5, 40), 2, jointPaint); // Hip joint
      canvas.drawRect(Rect.fromLTWH(30, 49, 8, 8), bodyPaint); // Lower leg
      canvas.drawCircle(Offset(34, 49), 1.5, jointPaint); // Knee joint
      canvas.drawRect(Rect.fromLTWH(28, 56, 12, 4), accentPaint); // Foot
    }

    // Jet pack effect when jumping
    if (!isRunning && jumpHeight > 5) {
      final flamePaint = Paint()
        ..color = Colors.orange.shade600
        ..style = PaintingStyle.fill;
      final flameInnerPaint = Paint()
        ..color = Colors.yellow.shade600
        ..style = PaintingStyle.fill;

      // Left jet
      canvas.drawOval(Rect.fromLTWH(18, 42, 4, 8), flamePaint);
      canvas.drawOval(Rect.fromLTWH(19, 43, 2, 5), flameInnerPaint);

      // Right jet
      canvas.drawOval(Rect.fromLTWH(38, 42, 4, 8), flamePaint);
      canvas.drawOval(Rect.fromLTWH(39, 43, 2, 5), flameInnerPaint);
    }
  }

  @override
  bool shouldRepaint(RobotPainter oldDelegate) {
    return runFrame != oldDelegate.runFrame || isDarkMode != oldDelegate.isDarkMode;
  }
}

class ObstaclePainter extends CustomPainter {
  final ObstacleType type;
  final bool isDarkMode;

  ObstaclePainter({required this.type, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case ObstacleType.barrier:
        // Draw traffic barrier/cone
        final barrierPaint = Paint()
          ..color = isDarkMode ? Colors.orange.shade700 : Colors.orange.shade600
          ..style = PaintingStyle.fill;

        // Cone shape
        final conePath = Path()
          ..moveTo(17.5, 5)
          ..lineTo(10, 40)
          ..lineTo(25, 40)
          ..close();
        canvas.drawPath(conePath, barrierPaint);

        // White stripes
        final stripePaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(14, 15), Offset(21, 15), stripePaint);
        canvas.drawLine(Offset(13, 25), Offset(22, 25), stripePaint);
        canvas.drawLine(Offset(12, 35), Offset(23, 35), stripePaint);

        // Base
        canvas.drawRect(Rect.fromLTWH(8, 40, 19, 5), Paint()..color = Colors.grey.shade800);
        break;

      case ObstacleType.building:
        // Draw futuristic building/skyscraper
        final buildingPaint = Paint()
          ..color = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade600
          ..style = PaintingStyle.fill;

        // Main structure
        canvas.drawRect(Rect.fromLTWH(10, 10, 30, 60), buildingPaint);

        // Windows (glowing)
        final windowPaint = Paint()
          ..color = isDarkMode ? Colors.cyan.shade300 : Colors.blue.shade400
          ..style = PaintingStyle.fill;

        for (int row = 0; row < 5; row++) {
          for (int col = 0; col < 3; col++) {
            canvas.drawRect(Rect.fromLTWH(13 + col * 9, 15 + row * 11, 6, 6), windowPaint);
          }
        }

        // Antenna on top
        canvas.drawRect(Rect.fromLTWH(23, 5, 4, 8), buildingPaint);
        canvas.drawCircle(Offset(25, 4), 2, Paint()..color = Colors.red);

        // Base
        canvas.drawRect(Rect.fromLTWH(8, 68, 34, 2), Paint()..color = Colors.grey.shade800);
        break;

      case ObstacleType.airplane:
        // Draw airplane
        final planePaint = Paint()
          ..color = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600
          ..style = PaintingStyle.fill;

        // Fuselage
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(10, 12, 50, 8), Radius.circular(4)), planePaint);

        // Cockpit
        final cockpitPaint = Paint()
          ..color = isDarkMode ? Colors.blue.shade300 : Colors.blue.shade600
          ..style = PaintingStyle.fill;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(50, 13, 8, 6), Radius.circular(3)), cockpitPaint);

        // Main wings
        canvas.drawRect(Rect.fromLTWH(25, 8, 20, 15), planePaint);

        // Tail wing
        canvas.drawRect(Rect.fromLTWH(5, 10, 8, 10), planePaint);

        // Tail fin
        final tailPath = Path()
          ..moveTo(10, 12)
          ..lineTo(5, 5)
          ..lineTo(10, 8)
          ..close();
        canvas.drawPath(tailPath, planePaint);

        // Windows
        for (int i = 0; i < 4; i++) {
          canvas.drawCircle(Offset(20 + i * 7.0, 16), 1.5, cockpitPaint);
        }

        // Engine glow
        canvas.drawCircle(Offset(8, 16), 3, Paint()..color = Colors.orange.shade600);
        canvas.drawCircle(Offset(8, 16), 2, Paint()..color = Colors.yellow.shade600);
        break;

      case ObstacleType.helicopter:
        // Draw helicopter
        final heliPaint = Paint()
          ..color = isDarkMode ? Colors.grey.shade500 : Colors.grey.shade700
          ..style = PaintingStyle.fill;

        // Body
        canvas.drawOval(Rect.fromLTWH(15, 15, 30, 15), heliPaint);

        // Cockpit
        final cockpitPaint = Paint()
          ..color = isDarkMode ? Colors.cyan.shade300 : Colors.cyan.shade600
          ..style = PaintingStyle.fill;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(35, 17, 10, 10), Radius.circular(3)), cockpitPaint);

        // Tail boom
        canvas.drawRect(Rect.fromLTWH(8, 20, 10, 5), heliPaint);

        // Tail rotor
        canvas.drawRect(Rect.fromLTWH(5, 18, 3, 10), Paint()..color = Colors.grey.shade600);
        canvas.drawRect(Rect.fromLTWH(3, 22, 7, 1), Paint()..color = Colors.grey.shade800);

        // Main rotor mast
        canvas.drawRect(Rect.fromLTWH(29, 10, 2, 6), heliPaint);

        // Main rotor blades (spinning effect)
        final rotorPaint = Paint()
          ..color = Colors.grey.shade800.withValues(alpha: 0.6)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(30, 10), Offset(10, 10), rotorPaint);
        canvas.drawLine(Offset(30, 10), Offset(50, 10), rotorPaint);
        canvas.drawLine(Offset(30, 10), Offset(30, 5), rotorPaint);
        canvas.drawLine(Offset(30, 10), Offset(30, 15), rotorPaint);

        // Landing skids
        canvas.drawRect(Rect.fromLTWH(20, 29, 20, 2), Paint()..color = Colors.grey.shade800);
        canvas.drawRect(Rect.fromLTWH(18, 28, 2, 4), Paint()..color = Colors.grey.shade800);
        canvas.drawRect(Rect.fromLTWH(40, 28, 2, 4), Paint()..color = Colors.grey.shade800);
        break;

      case ObstacleType.drone:
        // Draw quadcopter drone
        final dronePaint = Paint()
          ..color = isDarkMode ? Colors.grey.shade600 : Colors.grey.shade800
          ..style = PaintingStyle.fill;

        // Central body
        canvas.drawCircle(Offset(17.5, 12.5), 5, dronePaint);

        // Camera gimbal
        canvas.drawCircle(Offset(17.5, 16), 2.5, Paint()..color = Colors.black);
        canvas.drawCircle(Offset(17.5, 16), 1.5, Paint()..color = Colors.blue.shade600);

        // Arms
        final armPaint = Paint()
          ..color = dronePaint.color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        // Diagonal arms
        canvas.drawLine(Offset(17.5, 12.5), Offset(8, 5), armPaint);
        canvas.drawLine(Offset(17.5, 12.5), Offset(27, 5), armPaint);
        canvas.drawLine(Offset(17.5, 12.5), Offset(8, 20), armPaint);
        canvas.drawLine(Offset(17.5, 12.5), Offset(27, 20), armPaint);

        // Propeller motors
        canvas.drawCircle(Offset(8, 5), 3, dronePaint);
        canvas.drawCircle(Offset(27, 5), 3, dronePaint);
        canvas.drawCircle(Offset(8, 20), 3, dronePaint);
        canvas.drawCircle(Offset(27, 20), 3, dronePaint);

        // Spinning propellers (blur effect)
        final propPaint = Paint()
          ..color = Colors.grey.shade400.withValues(alpha: 0.5)
          ..style = PaintingStyle.fill;
        canvas.drawOval(Rect.fromLTWH(3, 3, 10, 4), propPaint);
        canvas.drawOval(Rect.fromLTWH(22, 3, 10, 4), propPaint);
        canvas.drawOval(Rect.fromLTWH(3, 18, 10, 4), propPaint);
        canvas.drawOval(Rect.fromLTWH(22, 18, 10, 4), propPaint);

        // LED lights
        canvas.drawCircle(Offset(8, 5), 1, Paint()..color = Colors.green);
        canvas.drawCircle(Offset(27, 5), 1, Paint()..color = Colors.green);
        canvas.drawCircle(Offset(8, 20), 1, Paint()..color = Colors.red);
        canvas.drawCircle(Offset(27, 20), 1, Paint()..color = Colors.red);
        break;
    }
  }

  @override
  bool shouldRepaint(ObstaclePainter oldDelegate) {
    return type != oldDelegate.type || isDarkMode != oldDelegate.isDarkMode;
  }
}

class GroundPainter extends CustomPainter {
  final double offset;
  final bool isDarkMode;

  GroundPainter({required this.offset, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade600
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw ground texture lines
    for (double x = -offset % 50; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 20), Offset(x + 10, 20), paint);
      canvas.drawLine(Offset(x + 25, 40), Offset(x + 35, 40), paint);
      canvas.drawLine(Offset(x + 15, 60), Offset(x + 25, 60), paint);
    }
  }

  @override
  bool shouldRepaint(GroundPainter oldDelegate) {
    return offset != oldDelegate.offset || isDarkMode != oldDelegate.isDarkMode;
  }
}
