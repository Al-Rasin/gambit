import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../widgets/game_site_card.dart';
import 'game_page.dart';
import '../games/flappy_bird_game.dart';
import '../games/dino_game.dart';
import '../providers/theme_provider.dart';

class HomePage extends StatelessWidget {
  final ThemeProvider themeProvider;
  const HomePage({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                  themeProvider.currentTheme == ThemeType.light
                      ? Icons.light_mode
                      : themeProvider.currentTheme == ThemeType.dark
                      ? Icons.dark_mode
                      : Icons.brightness_auto,
                  color: Colors.white,
                ),
                onPressed: () => _showThemeDialog(context),
                tooltip: 'Change Theme',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'Gambit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(offset: Offset(0, 2), blurRadius: 8, color: Colors.black87),
                    Shadow(offset: Offset(0, 1), blurRadius: 20, color: Colors.purpleAccent),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.purple.shade400, Colors.blue.shade600, Colors.indigo.shade800],
                          ),
                        ),
                        child: const Center(child: Icon(Icons.sports_esports, size: 80, color: Colors.white70)),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Online Games Section
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Online Games',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.headlineMedium?.color),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final gameController = GameController();
                final site = gameController.gameSites[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GameSiteCard(
                    site: site,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => GamePage(initialUrl: site.url)));
                    },
                  ),
                );
              }, childCount: GameController().gameSites.length),
            ),
          ),
          // Offline Games Section
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Offline Games',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.headlineMedium?.color),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FlappyBirdGame(isCheatModeEnabled: themeProvider.isCheatModeEnabled)),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [const Color(0xFF4EC0CA).withValues(alpha: 0.1), const Color(0xFF4EC0CA).withValues(alpha: 0.05)],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4EC0CA).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.flutter_dash, size: 32, color: Color(0xFF4EC0CA)),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Flappy Bird',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4EC0CA)),
                                ),
                                const SizedBox(height: 4),
                                Text('Play offline anytime!', style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color)),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: const Color(0xFF4EC0CA).withValues(alpha: 0.7)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Dino Game Card
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DinoGame(isCheatModeEnabled: themeProvider.isCheatModeEnabled)));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blueGrey.withValues(alpha: 0.1), Colors.blueGrey.withValues(alpha: 0.05)],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.blueGrey.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                            child: Icon(Icons.smart_toy, size: 32, color: Colors.blueGrey.shade700),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Robot Runner',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700),
                                ),
                                const SizedBox(height: 4),
                                Text('Classic endless runner!', style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color)),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.blueGrey.withValues(alpha: 0.7)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 50)),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Theme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.light_mode),
                    title: const Text('Light'),
                    trailing: themeProvider.currentTheme == ThemeType.light ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
                    onTap: () {
                      themeProvider.setTheme(ThemeType.light);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Dark'),
                    trailing: themeProvider.currentTheme == ThemeType.dark ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
                    onTap: () {
                      themeProvider.setTheme(ThemeType.dark);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.brightness_auto),
                    title: const Text('System'),
                    trailing: themeProvider.currentTheme == ThemeType.system ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
                    onTap: () {
                      themeProvider.setTheme(ThemeType.system);
                      Navigator.pop(context);
                    },
                  ),
                  Divider(height: 24, color: themeProvider.isCheatModeEnabled ? Colors.green : Colors.greenAccent),
                  InkWell(
                    onTap: () {
                      themeProvider.toggleCheatMode();
                      setState(() {});
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(child: SizedBox()),
                          Expanded(
                            flex: 1,
                            child: Switch(
                              value: themeProvider.isCheatModeEnabled,
                              onChanged: (value) {
                                themeProvider.toggleCheatMode();
                                setState(() {});
                              },
                              activeThumbColor: Colors.transparent,
                              activeTrackColor: Colors.red,
                              inactiveThumbColor: Colors.transparent,
                              inactiveTrackColor: Colors.transparent,
                              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                              trackOutlineWidth: WidgetStateProperty.all(0),
                              thumbColor: WidgetStateProperty.all(Colors.transparent),
                              trackColor: WidgetStateProperty.all(Colors.transparent),
                              overlayColor: WidgetStateProperty.all(Colors.transparent),
                              splashRadius: 0,
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
            );
          },
        );
      },
    );
  }
}
