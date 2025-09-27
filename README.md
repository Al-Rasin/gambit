Screenshots:
<img width="1170" height="2532" alt="Image" src="https://github.com/user-attachments/assets/769e65ee-2e53-4679-ae16-6217143a7554" />
<img width="1170" height="2532" alt="Image" src="https://github.com/user-attachments/assets/caedf6fa-bec7-4bf7-a904-f4cdbb136d85" />
<img width="1170" height="2532" alt="Image" src="https://github.com/user-attachments/assets/5fbf3a56-8d60-4a3e-b12c-ae507dec6c84" />
<img width="1170" height="2532" alt="Image" src="https://github.com/user-attachments/assets/c25cc19d-1e19-49d9-9c46-fef06a2e4395" />
<img width="1170" height="2532" alt="Image" src="https://github.com/user-attachments/assets/bfb27e99-7884-418d-b859-3b6466a19f35" />
# Gambit - Your Ultimate Gaming Hub 🎮

A comprehensive Flutter gaming application that combines built-in games with access to popular web-based gaming platforms. Experience the best of both worlds with native Flutter games and seamless web game browsing.

## ✨ Features

### 🎯 Built-in Games
- **Flappy Bird**: Classic bird flight game with physics-based gameplay
- **Dino Runner**: Chrome-inspired endless runner with multiple obstacle types
- **Local high score tracking** with persistent storage
- **Multiple themes support** (Light, Dark, Gaming modes)

### 🌐 Web Games Integration
- **CrazyGames**: Free browser games with instant play
- **Poki**: Popular online games platform
- **Cool Math Games**: Fun brain training games
- **Y8 Games**: Classic flash and HTML5 games
- **Miniclip**: Premium online gaming experience
- **Kongregate**: Community-driven gaming platform
- **Armor Games**: Quality indie and flash games
- **AddictingGames**: Casual gaming entertainment

### 🎨 User Experience
- **Custom WebView integration** for seamless web gaming
- **Responsive design** optimized for mobile and tablet
- **Theme customization** with persistent preferences
- **Smooth animations** and polished UI
- **Cross-platform support** (iOS, Android, Web, Desktop)

## 📱 Screenshots

*Coming soon - Add screenshots of your app here*

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.9.2)
- Dart SDK
- Android Studio / Xcode for mobile development
- Web browser for web development

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Al-Rasin/gambit.git
   cd gambit
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # For mobile development
   flutter run
   
   # For web development
   flutter run -d chrome
   
   # For desktop (macOS/Linux/Windows)
   flutter run -d macos    # or linux/windows
   ```

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── controllers/              # Business logic controllers
├── games/                    # Built-in game implementations
│   ├── flappy_bird_game.dart # Flappy Bird game logic
│   ├── dino_game.dart        # Dino runner game logic
│   └── game_storage.dart     # Local storage utilities
├── models/                   # Data models
├── pages/                    # Screen components
│   ├── splash_screen.dart    # Loading screen
│   ├── home_page.dart        # Main dashboard
│   ├── game_page.dart        # Game container
│   ├── game_sites_page.dart  # Web games directory
│   └── browser_page.dart     # WebView container
├── providers/                # State management
│   └── theme_provider.dart   # Theme management
└── widgets/                  # Reusable UI components
```

## 🛠️ Dependencies

### Core Dependencies
- **flutter**: SDK framework
- **cupertino_icons**: iOS-style icons
- **webview_flutter**: WebView integration
- **shared_preferences**: Local data persistence
- **cached_network_image**: Efficient image caching
- **url_launcher**: External URL handling
- **flutter_custom_tabs**: Enhanced browser experience

### Platform-specific
- **webview_flutter_android**: Android WebView optimizations
- **webview_flutter_wkwebview**: iOS WKWebView integration

## 🎮 How to Play

### Flappy Bird
- **Tap**: Make the bird jump
- **Goal**: Navigate through pipes without hitting them
- **Scoring**: Pass through pipes to increase score
- **High Score**: Beat your personal best!

### Dino Runner
- **Tap/Spacebar**: Jump over obstacles
- **Goal**: Survive as long as possible
- **Obstacles**: Barriers, buildings, aircraft
- **Progressive Difficulty**: Game speeds up over time

### Web Games
1. Navigate to the "Web Games" section
2. Choose from popular gaming platforms
3. Tap on any platform to launch games
4. Use the built-in browser controls for navigation

## 🎨 Customization

### Themes
The app supports three theme modes:
- **Light Theme**: Clean, minimalist design
- **Dark Theme**: Easy on the eyes for extended play
- **Gaming Theme**: Vibrant colors optimized for gaming

### Adding New Games
To add new built-in games:
1. Create a new game file in `lib/games/`
2. Implement game logic using Flutter's animation framework
3. Add navigation in `home_page.dart`
4. Include high score tracking with `game_storage.dart`

### Adding Web Game Sites
To add new gaming platforms:
1. Update the `gameSites` list in `game_sites_page.dart`
2. Add platform details (name, URL, description, theme colors)
3. The WebView will automatically handle the new site

## 🔧 Development

### Running Tests
```bash
flutter test
```

### Building for Production
```bash
# Android APK
flutter build apk

# iOS
flutter build ios

# Web
flutter build web

# Desktop
flutter build macos    # or linux/windows
```

### Code Style
This project follows Flutter's official style guidelines and uses:
- Dart analysis with `analysis_options.yaml`
- Consistent naming conventions
- Proper widget composition patterns
- State management best practices

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-game`)
3. Commit your changes (`git commit -m 'Add amazing new game'`)
4. Push to the branch (`git push origin feature/amazing-game`)
5. Open a Pull Request

### Contribution Guidelines
- Follow existing code patterns and style
- Add tests for new game features
- Update documentation for significant changes
- Ensure cross-platform compatibility

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Al-Rasin**
- GitHub: [@Al-Rasin](https://github.com/Al-Rasin)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Game platform providers for inspiration
- Open source community for tools and libraries
- Classic games that inspired the built-in implementations

## 📞 Support

If you encounter any issues or have suggestions:
1. Check existing [Issues](https://github.com/Al-Rasin/gambit/issues)
2. Create a new issue with detailed information
3. Include steps to reproduce any bugs
4. Specify your platform and Flutter version

---

**Happy Gaming! 🎮**


