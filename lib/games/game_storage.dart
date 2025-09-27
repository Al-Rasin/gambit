import 'package:shared_preferences/shared_preferences.dart';
import 'flappy_bird_game.dart';

/// Simple storage class that handles both SharedPreferences and in-memory fallback
class GameStorage {
  static Difficulty _lastDifficulty = Difficulty.easy;
  static final Map<Difficulty, int> _highScores = {
    Difficulty.easy: 0,
    Difficulty.medium: 0,
    Difficulty.hard: 0,
  };

  static bool _useSharedPrefs = true;
  static bool _initialized = false;

  /// Initialize storage and check if SharedPreferences is available
  static Future<void> init() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      // Try to read a test value to ensure it's working
      await prefs.setString('test_key', 'test');
      prefs.getString('test_key');
      await prefs.remove('test_key');
      _useSharedPrefs = true;

      // Load saved values
      await _loadFromSharedPrefs();
    } catch (e) {
      // SharedPreferences not available, use in-memory storage
      _useSharedPrefs = false;
      // Silent fallback to in-memory storage
    }

    _initialized = true;
  }

  static Future<void> _loadFromSharedPrefs() async {
    if (!_useSharedPrefs) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load last difficulty
      final difficultyIndex = prefs.getInt('flappy_last_difficulty') ?? 0;
      if (difficultyIndex >= 0 && difficultyIndex < Difficulty.values.length) {
        _lastDifficulty = Difficulty.values[difficultyIndex];
      }

      // Load high scores
      _highScores[Difficulty.easy] = prefs.getInt('flappy_high_score_easy') ?? 0;
      _highScores[Difficulty.medium] = prefs.getInt('flappy_high_score_medium') ?? 0;
      _highScores[Difficulty.hard] = prefs.getInt('flappy_high_score_hard') ?? 0;
    } catch (e) {
      _useSharedPrefs = false;
    }
  }

  /// Get the last selected difficulty
  static Future<Difficulty> getLastDifficulty() async {
    await init();
    return _lastDifficulty;
  }

  /// Save the last selected difficulty
  static Future<void> saveLastDifficulty(Difficulty difficulty) async {
    await init();
    _lastDifficulty = difficulty;

    if (_useSharedPrefs) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('flappy_last_difficulty', difficulty.index);
      } catch (e) {
        // Ignore errors, in-memory value is already set
      }
    }
  }

  /// Get high scores
  static Future<Map<Difficulty, int>> getHighScores() async {
    await init();
    return Map.from(_highScores);
  }

  /// Save a high score if it's better than the current one
  static Future<void> saveHighScore(Difficulty difficulty, int score) async {
    await init();

    if (score > (_highScores[difficulty] ?? 0)) {
      _highScores[difficulty] = score;

      if (_useSharedPrefs) {
        try {
          final prefs = await SharedPreferences.getInstance();
          String key = '';
          switch (difficulty) {
            case Difficulty.easy:
              key = 'flappy_high_score_easy';
              break;
            case Difficulty.medium:
              key = 'flappy_high_score_medium';
              break;
            case Difficulty.hard:
              key = 'flappy_high_score_hard';
              break;
          }
          await prefs.setInt(key, score);
        } catch (e) {
          // Ignore errors, in-memory value is already set
        }
      }
    }
  }

  /// Get a specific high score
  static int getHighScore(Difficulty difficulty) {
    return _highScores[difficulty] ?? 0;
  }
}