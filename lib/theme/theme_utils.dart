
import 'package:flutter/material.dart';

const Color primary = Colors.green;

ThemeData appThemeDark = ThemeData(
  useMaterial3: true,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.dark,
  ),
  brightness: Brightness.dark,
  iconTheme: _iconTheme,
  listTileTheme: _listTileTheme,
  cardTheme: _cardTheme,
  inputDecorationTheme: _inputDecorationTheme,
  bottomNavigationBarTheme: _bottomNavigationBarTheme,
  outlinedButtonTheme: _outlinedButtonTheme,
  toggleButtonsTheme: _toggleButtonsTheme
);

ThemeData appTheme = ThemeData(
  useMaterial3: true,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF4c662b),
    brightness: Brightness.light
  ),
  brightness: Brightness.light,
  iconTheme: _iconTheme,
  listTileTheme: _listTileTheme,
  cardTheme: _cardTheme,
  inputDecorationTheme: _inputDecorationTheme,
  bottomNavigationBarTheme: _bottomNavigationBarTheme,
  outlinedButtonTheme: _outlinedButtonTheme,
  toggleButtonsTheme: _toggleButtonsTheme
);

//
// Theme per widget
//

const _iconTheme = IconThemeData(
  color: primary
);

const _listTileTheme = ListTileThemeData(
  iconColor: primary
);

final _cardTheme = CardThemeData(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(4),
  )
);

const _inputDecorationTheme = InputDecorationTheme(
  errorBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.redAccent)
  ),
  errorStyle: TextStyle(color: Colors.redAccent),
  prefixIconColor: primary,
);

const _bottomNavigationBarTheme = BottomNavigationBarThemeData(
  selectedItemColor: primary
);

final _outlinedButtonTheme = OutlinedButtonThemeData(
  style: ButtonStyle(
    side: WidgetStateProperty.all<BorderSide>(
      const BorderSide(
        color: primary,
        width: 1.0,
        style: BorderStyle.solid
      )
    ),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      )
    )
  )
);

final _toggleButtonsTheme = ToggleButtonsThemeData(
  borderRadius:  const BorderRadius.all(Radius.circular(8.0)),
  selectedBorderColor: Colors.greenAccent[700],
  selectedColor: primary,
);