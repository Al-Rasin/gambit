import 'package:flutter/material.dart';
import '../models/game_site.dart';

class GameController extends ChangeNotifier {
  static final List<GameSite> _gameSites = [
    GameSite(
      name: 'CrazyGames',
      url: 'https://www.crazygames.com/',
      description: 'Free online games for everyone',
      color: Colors.purple,
      icon: Icons.games,
    ),
    GameSite(name: 'Poki', url: 'https://poki.com/', description: 'The ultimate online playground', color: Colors.blue, icon: Icons.sports_esports),
    GameSite(
      name: 'Addicting Games',
      url: 'https://www.addictinggames.com/',
      description: 'Addictively fun games',
      color: Colors.red,
      icon: Icons.psychology,
    ),
    GameSite(
      name: 'Cool Math Games',
      url: 'https://www.coolmathgames.com/',
      description: 'Math + Games = Fun',
      color: Colors.green,
      icon: Icons.calculate,
    ),
    GameSite(name: 'Lagged', url: 'https://lagged.com/', description: 'Free online games and more', color: Colors.orange, icon: Icons.flash_on),
    GameSite(name: 'Armor Games', url: 'https://armorgames.com/', description: 'Premium gaming experience', color: Colors.indigo, icon: Icons.shield),
    GameSite(name: 'Friv', url: 'https://www.friv.com/', description: 'Classic online games', color: Colors.teal, icon: Icons.videogame_asset),
  ];

  List<GameSite> get gameSites => _gameSites;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<GameSite> get filteredGameSites {
    if (_searchQuery.isEmpty) {
      return _gameSites;
    }
    return _gameSites
        .where(
          (site) =>
              site.name.toLowerCase().contains(_searchQuery.toLowerCase()) || site.description.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
