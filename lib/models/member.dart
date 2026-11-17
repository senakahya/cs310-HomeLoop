import 'package:flutter/material.dart';

/// A person who lives in the household.
class Member {
  final String id;
  final String name;

  /// Colour as a 6-digit hex string, e.g. 'E07A5F'.
  final String colorHex;
  final bool isOwner;

  const Member({
    required this.id,
    required this.name,
    required this.colorHex,
    this.isOwner = false,
  });

  Color get color => Color(int.parse('FF$colorHex', radix: 16));

  String get initial => name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();

  /// Avatar loaded from the network (Step 2.2 requirement: network image).
  /// ui-avatars.com draws the member's initial on the member's colour.
  String get avatarUrl =>
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}'
      '&background=$colorHex&color=ffffff&bold=true&size=128&length=1';
}
