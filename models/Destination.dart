import 'package:flutter/material.dart';

class Destination {
  const Destination({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const destinations = [
  Destination(label: 'Home', icon: Icons.home_outlined),
  Destination(label: 'Category', icon: Icons.category),
  Destination(label: 'Shop', icon: Icons.shop_2),
  Destination(label: 'Profile', icon: Icons.person),
];
