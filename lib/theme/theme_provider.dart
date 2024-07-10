import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/themes.dart';

/// This class help to manage switching light/dark theme.
/// Whenever a change occurs, notify listeners to rebuild widgets with the new state.
class ThemeProvider extends ChangeNotifier {
  /// The actual theme used in the app. It defaults to `light`.
  ThemeMode themeMode = ThemeMode.light;

  /// Returns `true` if the actual theme used in the app is `light`.
  @Deprecated("Use `themeMode` instead")
  bool get isLightMode => themeMode == ThemeMode.light;

  /// The default light theme
  ThemeData get lightTheme => Themes.lightTheme;

  /// The default dark theme
  ThemeData get darkTheme => Themes.darkTheme;

  /// Boolean value to know if the `ThemeProvider` has already been initialized with user's preference
  bool initialized = false;

  Future<bool> initialize() async {
    if (initialized) return SynchronousFuture(true);
    themeMode = await _loadThemePreference();
    initialized = true;
    return true;
  }

  /// Change the theme of the app (dark/light) depending on a boolean toggle value.
  /// Notify listeners (main Material App) when called, to rebuild the entire widget tree.
  ///
  /// `themeMode`: ThemeMode value, usually provided by a toggle. If equals ThemeMode.light, set light theme,
  /// otherwise set dark theme.
  Future setTheme(ThemeMode themeMode) async {
    this.themeMode = themeMode;
    await _saveThemePreference(mode: themeMode);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness:
            themeMode == ThemeMode.light ? Brightness.light : Brightness.dark));
    notifyListeners();
  }

  /// Retrieve the user preference for theme, if any (light/dark).
  /// Defaults to ThemeMode.light.
  Future<ThemeMode> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString("mode");
    if (mode == null) {
      return ThemeMode.light;
    }

    return ThemeMode.values
            .where((element) => element.name == mode)
            .firstOrNull ??
        ThemeMode.light;
  }

  /// Save Theme preference (light/dark) in SharedPreferences
  Future _saveThemePreference({required ThemeMode mode}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("mode", mode.name);
  }
}
