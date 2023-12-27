import 'package:flutter/material.dart';

const Color seedColor = Color(0xff012e6e);

Color lighten(Color color, [double amount = 0.5]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}
