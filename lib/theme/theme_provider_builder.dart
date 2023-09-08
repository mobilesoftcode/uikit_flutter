import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme_provider.dart';

/// To add theme management in the app, modify the build method in your `main.dart` as follow:

/// ```dart
/// return ThemeProviderBuilder(
///     builder: (context, themeProvider) => MaterialApp(
///             [...]
///             themeMode: themeProvider.themeMode,
///             theme: themeProvider.lightTheme,
///             darkTheme: themeProvider.darkTheme,
///             [...]
///         ),
/// );
class ThemeProviderBuilder extends StatelessWidget {
  /// Use this builder to return your MaterialApp/CupertinoApp with a reference
  /// to the [ThemeProvider] to access theme management.
  final Widget Function(BuildContext, ThemeProvider) builder;

  /// You can use this widget to specify what to show during [ThemeProvider] initialization.
  /// If `null` an empty [Scaffold] will be shown.
  final Widget? loadingWidget;

  /// To add theme management in the app, modify the build method in your `main.dart` as follow:

  /// ```dart
  /// return ThemeProviderBuilder(
  ///     builder: (context, themeProvider) => MaterialApp(
  ///             [...]
  ///             themeMode: themeProvider.themeMode,
  ///             theme: themeProvider.lightTheme,
  ///             darkTheme: themeProvider.darkTheme,
  ///             [...]
  ///         ),
  /// );
  const ThemeProviderBuilder(
      {Key? key, required this.builder, this.loadingWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (buildContext, _) {
        final themeProvider = Provider.of<ThemeProvider>(buildContext);
        var initialized = themeProvider.initialized;

        return StatefulBuilder(builder: (context, setState) {
          if (!initialized) {
            themeProvider.initialize().then(
                  (value) => setState(() {
                    initialized = value;
                  }),
                );
          }

          return initialized
              ? builder(context, themeProvider)
              : loadingWidget ?? Container(color: Colors.white);
        });
      },
    );
  }
}
