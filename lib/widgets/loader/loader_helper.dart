import 'package:flutter/material.dart';

import 'src/loading_dialog.dart';

/// An helper class to manage the loader all throughout the application (show/hide).
///
/// Before use, it must be initialised calling
///
/// ``` dart
/// LoaderHelper.shared.init(context);
/// ```
///
/// For further details, check the method documentation itself.
class LoaderHelper {
  // Singleton management
  static final LoaderHelper _singleton = LoaderHelper._internal();
  factory LoaderHelper() => _singleton;
  LoaderHelper._internal();
  static LoaderHelper get shared => _singleton;

  /// Set the root [BuildContext] to this [LoaderHelper] singleton to be used
  /// in the app.
  ///
  /// Optionally, a loaderWidget and a loaderBarrierColor can be passed to
  /// override the default ones.
  ///
  /// **NOTES**
  ///
  /// - If this method is not called, than the other methods of this
  /// [LoaderHelper] will do nothing (without throwing errors).
  /// - If this method is called with a [BuildContext] different from the root one,
  /// calling the other methods could throw errors in debug.
  ///
  /// To avoid errors, call `init` in the root widget, right after the [MaterialApp] or
  /// the [CupertinoApp] (or whatever is the App widget), in the "home" attribtue.
  ///
  /// If you use `router` such as [MaterialApp.router], use the [BuildContext] of the
  /// root [Navigator] widget in the [RouterDelegate].
  ///
  /// ## Tip
  /// If you use the [RouteManager package](https://git.mobilesoft.it/mobile-competence-center/competence-flutter/packages/route_manager),
  /// you can get the root context wherever you want by calling
  ///
  /// ``` dart
  /// BuildContext? context = RouteManager.of(context).navigatorContext;
  /// ```
  ///
  /// Note that it's an optional value to be null-checked before use.
  void init(BuildContext context,
      {Widget? loaderWidget, Color? loaderBarrierColor}) {
    _context = context;
    _loaderWidget = loaderWidget;
    _loaderBarrierColor = loaderBarrierColor;
  }

  /// The [BuildContext] that will be used to show the loading dialog.
  BuildContext? _context;

  /// The loader actually shown. If no loader is shown, then this object is `null`.
  LoadingDialog? _loadingDialog;

  /// Eventually a loader widget to override the default one.
  Widget? _loaderWidget;

  /// Eventually a color for the dialog barrier to ovveride the default one.
  Color? _loaderBarrierColor;

  /// Show a spinner in a dialog on top of all the app content.
  /// The loader is shown only if there are no other active loaders.
  show({bool scheduler = false}) {
    if (_loadingDialog == null && _context != null) {
      _loadingDialog = LoadingDialog(loaderWidget: _loaderWidget);
      _loadingDialog?.show(_context!,
          scheduler: scheduler, barrierColor: _loaderBarrierColor);
    }
  }

  /// Hide the spinner loader, if shown.
  hide({bool scheduler = false}) {
    if (_loadingDialog != null) {
      _loadingDialog?.hide(scheduler: scheduler);
      _loadingDialog = null;
    }
  }
}
