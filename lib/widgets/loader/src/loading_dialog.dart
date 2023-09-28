import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Default loading indicator widget.
class LoadingDialog {
  /// Eventually a loader widget to override the default one.
  final Widget? loaderWidget;

  /// Create a loading indicator widget,
  /// with a gif animation and a customizable text.
  /// The loader avoids any user interaction.
  ///
  /// To show/hide the widget call the `show`/`hide` functions.
  LoadingDialog({
    this.loaderWidget,
  });

  BuildContext? _context;

  /// The custom loading widget
  late Widget loading = WillPopScope(
    onWillPop: () async => false,
    child: Dialog(
        backgroundColor: Colors.transparent,
        child: loaderWidget ??
            Image.asset('assets/double_ring_loading_io.gif',
                package: "flutter_ui_kit",
                height: 70,
                width: 70,
                color: Colors.white)),
  );

  /// Hide this loader.
  void hide({bool scheduler = false}) {
    if (_context != null && (_context?.mounted ?? false)) {
      if (scheduler) {
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          Navigator.pop(_context!);
        });
      } else {
        Navigator.pop(_context!);
      }
    }
  }

  /// Show this loader on top of widget tree. It avoids any user interaction.
  void show(BuildContext context,
      {bool scheduler = false, Color? barrierColor}) {
    _context = context;
    if (scheduler) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        showDialog(
            context: context,
            barrierColor: barrierColor,
            barrierDismissible: false,
            builder: (context) {
              _context = context;
              return loading;
            });
      });
    } else {
      showDialog(
          context: context,
          barrierColor: barrierColor,
          barrierDismissible: false,
          builder: (context) {
            _context = context;
            return loading;
          });
    }
  }
}
