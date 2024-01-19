 import 'package:flutter/material.dart';

const MaterialColor primary = MaterialColor(_primaryPrimaryValue, <int, Color>{
  50: Color(0xFFF2EEFB),
  100: Color(0xFFDFD4F5),
  200: Color(0xFFCAB8EF),
  300: Color(0xFFB49CE8),
  400: Color(0xFFA486E3),
  500: Color(_primaryPrimaryValue),
  600: Color(0xFF8C69DA),
  700: Color(0xFF815ED5),
  800: Color(0xFF7754D1),
  900: Color(0xFF6542C8),
});
 const int _primaryPrimaryValue = 0xFF9471DE;

 const MaterialColor primaryAccent = MaterialColor(_primaryAccentValue, <int, Color>{
  100: Color(0xFFFFFFFF),
  200: Color(_primaryAccentValue),
  400: Color(0xFFC7B5FF),
  700: Color(0xFFB49CFF),
});
 const int _primaryAccentValue = 0xFFEEE8FF;