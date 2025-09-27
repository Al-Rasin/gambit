import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'game_storage.dart';

// Keep enum for storage compatibility only
enum Difficulty { easy, medium, hard }

class FlappyBirdGame extends StatefulWidget {
  final bool isCheatModeEnabled;

  const FlappyBirdGame({super.key, this.isCheatModeEnabled = false});

  @override
  State<FlappyBirdGame> createState() => _FlappyBirdGameState();
}

class _FlappyBirdGameState extends State<FlappyBirdGame> with TickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _gameTimer;

  // Game settings (easy mode)
  final double gravity = 600;
  final double jumpVelocity = -280;
  final double pipeSpeed = 120;
  final double pipeGap = 295;
  final double speedIncrement = 0.02;

  // Constants
  static const double birdSize = 40;
  static const double pipeWidth = 80;

  // Game state
  double birdY = 0;
  double birdVelocity = 0;
  double gameSpeed = 1;
  List<Pipe> pipes = [];
  bool isGameStarted = false;
  bool isGameOver = false;
  int score = 0;

  // High score
  int highScore = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200))..repeat(reverse: true);
    _loadHighScore();
    _resetGame();
  }

  Future<void> _loadHighScore() async {
    final scores = await GameStorage.getHighScores();
    if (mounted) {
      setState(() {
        highScore = scores[Difficulty.easy] ?? 0;
      });
    }
  }

  Future<void> _saveHighScore() async {
    // Save high score regardless of cheat mode
    await GameStorage.saveHighScore(Difficulty.easy, score);
    // Reload score to update UI
    await _loadHighScore();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _resetGame() {
    setState(() {
      birdY = 0;
      birdVelocity = 0;
      pipes = [];
      isGameStarted = false;
      isGameOver = false;
      score = 0;
      gameSpeed = 1;
    });
  }

  void _startGame() {
    if (isGameStarted) return;

    setState(() {
      isGameStarted = true;
      isGameOver = false;
      birdVelocity = jumpVelocity;
    });

    _generatePipe();

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
      return;
    }

    setState(() {
      birdVelocity = jumpVelocity;
    });

    HapticFeedback.lightImpact();
  }

  void _updateGame(double dt) {
    if (!isGameStarted || isGameOver) return;

    setState(() {
      // Update bird physics
      birdVelocity += gravity * dt;
      birdY += birdVelocity * dt;

      // Check boundaries (skip if cheat mode is enabled)
      final screenHeight = MediaQuery.of(context).size.height - 200;
      if (!widget.isCheatModeEnabled && (birdY > screenHeight / 2 - birdSize || birdY < -screenHeight / 2 + birdSize)) {
        _gameOver();
        return;
      }

      // Update pipes
      for (var pipe in pipes) {
        pipe.x -= pipeSpeed * dt * gameSpeed;

        // Check if bird passed the pipe
        if (!pipe.passed && pipe.x < -pipeWidth / 2) {
          pipe.passed = true;
          score++;

          // Save high score immediately in cheat mode since game won't end
          if (widget.isCheatModeEnabled && score > highScore) {
            _saveHighScore();
          }

          if (score % 5 == 0) {
            gameSpeed = min(2.5, gameSpeed + speedIncrement);
          }
        }
      }

      // Remove off-screen pipes
      pipes.removeWhere((pipe) => pipe.x < -MediaQuery.of(context).size.width);

      // Generate new pipes
      double pipeSpacing = MediaQuery.of(context).size.width * 0.45; // Increased horizontal spacing between pipes
      if (pipes.isEmpty || pipes.last.x < pipeSpacing) {
        _generatePipe();
      }

      // Check collisions
      _checkCollisions();
    });
  }

  void _generatePipe() {
    final random = Random();
    final screenHeight = MediaQuery.of(context).size.height - 200;
    final minPipeHeight = 80.0; // Increased minimum height for any pipe

    // Calculate available space for pipes after accounting for the gap
    final availableHeight = screenHeight - pipeGap;

    // Ensure we don't exceed available height with minimum pipe requirements
    if (availableHeight < minPipeHeight * 2) {
      // If screen is too small for both minimum pipes and gap, use smaller minimums
      final adjustedMinHeight = availableHeight / 2.5;
      final topHeight = adjustedMinHeight + random.nextDouble() * (availableHeight - adjustedMinHeight * 2);
      final bottomHeight = availableHeight - topHeight;
      pipes.add(Pipe(x: MediaQuery.of(context).size.width / 2 + pipeWidth, topHeight: topHeight, bottomHeight: bottomHeight));
      return;
    }

    // Generate random height for top pipe within valid range
    final maxTopHeight = availableHeight - minPipeHeight;
    final topHeight = minPipeHeight + random.nextDouble() * (maxTopHeight - minPipeHeight);

    // Calculate bottom pipe height (remaining height after top pipe)
    final bottomHeight = availableHeight - topHeight;

    pipes.add(Pipe(x: MediaQuery.of(context).size.width / 2 + pipeWidth, topHeight: topHeight, bottomHeight: bottomHeight));
  }

  void _checkCollisions() {
    // Skip collision detection if cheat mode is enabled
    if (widget.isCheatModeEnabled) {
      return;
    }

    final birdLeft = -birdSize / 2;
    final birdRight = birdSize / 2;
    final birdTop = birdY - birdSize / 2;
    final birdBottom = birdY + birdSize / 2;

    for (var pipe in pipes) {
      final pipeLeft = pipe.x - pipeWidth / 2;
      final pipeRight = pipe.x + pipeWidth / 2;

      if (birdRight > pipeLeft && birdLeft < pipeRight) {
        final screenHeight = MediaQuery.of(context).size.height - 200;
        final topPipeBottom = -screenHeight / 2 + pipe.topHeight;
        final bottomPipeTop = screenHeight / 2 - pipe.bottomHeight;

        if (birdTop < topPipeBottom || birdBottom > bottomPipeTop) {
          _gameOver();
          return;
        }
      }
    }
  }

  void _gameOver() {
    setState(() {
      isGameOver = true;
    });
    _saveHighScore();
    _gameTimer?.cancel();
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4EC0CA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Flappy Bird',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: _jump,
        child: Stack(
          children: [
            // Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFF4EC0CA), const Color(0xFF7FD5DA).withValues(alpha: 0.8)],
                ),
              ),
            ),

            // Game area
            Center(
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height - 200,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // Clouds
                    ...List.generate(3, (index) {
                      return Positioned(
                        top: 50.0 + index * 120,
                        left: 50.0 + index * 100,
                        child: Icon(Icons.cloud, size: 80, color: Colors.white.withValues(alpha: 0.3)),
                      );
                    }),

                    // Pipes - render each pipe pair with proper positioning
                    ...pipes.map((pipe) {
                      return Stack(
                        children: [
                          // Top pipe - positioned from top of screen
                          Positioned(
                            left: pipe.x + MediaQuery.of(context).size.width / 2 - pipeWidth / 2,
                            top: 0,
                            child: Container(
                              width: pipeWidth,
                              height: pipe.topHeight,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.green.shade600, Colors.green.shade800],
                                ),
                                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                border: Border.all(color: Colors.green.shade900, width: 3),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 5, offset: const Offset(2, 2))],
                              ),
                            ),
                          ),
                          // Bottom pipe - calculate position from top to maintain exact gap
                          Positioned(
                            left: pipe.x + MediaQuery.of(context).size.width / 2 - pipeWidth / 2,
                            top: pipe.topHeight + pipeGap,
                            child: Container(
                              width: pipeWidth,
                              height: pipe.bottomHeight,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.green.shade600, Colors.green.shade800],
                                ),
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                border: Border.all(color: Colors.green.shade900, width: 3),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 5, offset: const Offset(2, 2))],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    // Bird
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, birdY),
                          child: Transform.rotate(
                            angle: birdVelocity * 0.001,
                            child: Container(
                              width: birdSize,
                              height: birdSize,
                              decoration: BoxDecoration(
                                color: Colors.yellow.shade600,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.orange.shade800, width: 2),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 5, offset: const Offset(0, 2))],
                              ),
                              child: Stack(
                                children: [
                                  // Eye
                                  Positioned(
                                    right: 8,
                                    top: 10,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.black, width: 1),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 4,
                                          height: 4,
                                          decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Beak
                                  Positioned(
                                    right: 5,
                                    top: 18,
                                    child: Transform.rotate(
                                      angle: 0.3,
                                      child: Container(
                                        width: 12,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade700,
                                          borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Wing
                                  Positioned(
                                    left: 5,
                                    top: 12,
                                    child: AnimatedBuilder(
                                      animation: _animationController,
                                      builder: (context, child) {
                                        return Transform.rotate(
                                          angle: _animationController.value * 0.5 - 0.25,
                                          child: Container(
                                            width: 15,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: Colors.yellow.shade700,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Colors.orange.shade800, width: 1),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Score
                    Positioned(
                      top: 50,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 3))],
                        ),
                        child: Text(
                          'Score: $score',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                    ),

                    // High Score
                    if (highScore > 0)
                      Positioned(
                        top: 100,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(15)),
                          child: Text(
                            'Best: $highScore',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                      ),

                    // Start/Game Over message
                    if (!isGameStarted || isGameOver)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 5))],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isGameOver) ...[
                                const Text(
                                  'Game Over!',
                                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red),
                                ),
                                const SizedBox(height: 10),
                                Text('Score: $score', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                if (score > highScore)
                                  const Text(
                                    'NEW HIGH SCORE!',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                                  ),
                              ] else ...[
                                const Icon(Icons.touch_app, size: 60, color: Colors.blue),
                                const SizedBox(height: 20),
                                const Text('Tap to Start', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                              const SizedBox(height: 10),
                              const Text('Tap to fly!', style: TextStyle(fontSize: 16, color: Colors.grey)),
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
}

class Pipe {
  double x;
  double topHeight;
  double bottomHeight;
  bool passed;

  Pipe({required this.x, required this.topHeight, required this.bottomHeight, this.passed = false});
}
