import 'package:flutter/material.dart';
import 'browser_page.dart';

class GameSite {
  final String name;
  final String url;
  final String description;
  final Color color;
  final IconData icon;

  const GameSite({
    required this.name,
    required this.url,
    required this.description,
    required this.color,
    required this.icon,
  });
}

class GameSitesPage extends StatelessWidget {
  const GameSitesPage({super.key});

  final List<GameSite> gameSites = const [
    GameSite(
      name: 'CrazyGames',
      url: 'https://www.crazygames.com/',
      description: 'Free browser games with instant play',
      color: Colors.purple,
      icon: Icons.gamepad,
    ),
    GameSite(
      name: 'Poki',
      url: 'https://poki.com/',
      description: 'Popular online games platform',
      color: Colors.pink,
      icon: Icons.sports_esports,
    ),
    GameSite(
      name: 'Cool Math Games',
      url: 'https://www.coolmathgames.com/',
      description: 'Fun brain training games',
      color: Colors.blue,
      icon: Icons.calculate,
    ),
    GameSite(
      name: 'Y8 Games',
      url: 'https://www.y8.com/',
      description: 'Classic flash and HTML5 games',
      color: Colors.red,
      icon: Icons.videogame_asset,
    ),
    GameSite(
      name: 'Friv',
      url: 'https://www.friv.com/',
      description: 'Simple and fun games collection',
      color: Colors.orange,
      icon: Icons.star,
    ),
    GameSite(
      name: 'Addicting Games',
      url: 'https://www.addictinggames.com/',
      description: 'Thousands of free online games',
      color: Colors.green,
      icon: Icons.extension,
    ),
    GameSite(
      name: 'Armor Games',
      url: 'https://armorgames.com/',
      description: 'Strategy and adventure games',
      color: Colors.indigo,
      icon: Icons.shield,
    ),
    GameSite(
      name: 'Kongregate',
      url: 'https://www.kongregate.com/',
      description: 'Social gaming platform',
      color: Colors.deepOrange,
      icon: Icons.people,
    ),
    GameSite(
      name: 'Miniclip',
      url: 'https://www.miniclip.com/',
      description: 'Sports and multiplayer games',
      color: Colors.cyan,
      icon: Icons.sports_soccer,
    ),
    GameSite(
      name: 'Kizi',
      url: 'https://kizi.com/',
      description: 'Fun games for all ages',
      color: Colors.teal,
      icon: Icons.child_care,
    ),
    GameSite(
      name: 'Lagged',
      url: 'https://lagged.com/',
      description: 'Mobile-friendly online games',
      color: Colors.amber,
      icon: Icons.phone_android,
    ),
    GameSite(
      name: 'A10',
      url: 'https://www.a10.com/',
      description: 'Action and racing games',
      color: Colors.deepPurple,
      icon: Icons.speed,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Game Sites'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: gameSites.length,
        itemBuilder: (context, index) {
          final site = gameSites[index];
          return Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BrowserPage(initialUrl: site.url),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      site.color.withValues(alpha: 0.7),
                      site.color.withValues(alpha: 0.4),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          site.icon,
                          size: 36,
                          color: site.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        site.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        site.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}