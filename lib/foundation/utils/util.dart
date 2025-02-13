import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme createTextTheme() {
  return GoogleFonts.interTextTheme();
}

WidgetStateProperty<Color?> computeDataRowColor(ColorScheme colorScheme) {
  return WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
    const Set<WidgetState> interactiveStates = <WidgetState>{
      WidgetState.pressed,
      WidgetState.hovered,
      WidgetState.focused,
    };

    if (states.any(interactiveStates.contains)) {
      return colorScheme.primaryContainer;
    }
    return Colors.transparent;
  });
}
