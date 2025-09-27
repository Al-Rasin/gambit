import 'package:flutter/material.dart';

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