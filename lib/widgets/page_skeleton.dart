import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:uikit_flutter/src/utils/constants.dart';

/// Default skeleton page, with SafeArea, scrollbar and padding.
class PageSkeleton extends StatelessWidget {
  /// The body to show in the scaffold page.
  final Widget body;

  /// Optionally, an appbar can be provided as a custom widget.
  final PreferredSizeWidget? appBar;

  /// Optionally, a FAB can be provided as a custom widget.
  /// If not specified, no FAB will be added.
  final Widget? floatingActionButton;

  /// Optionally, a widget to display on top of the page (eventually under an AppBar) can be provided.
  /// It will expand for entire screen's width, without considering the
  /// max page width set in this uikit.
  final Widget? topWidget;

  /// If true removes default padding in page.
  /// Defaults to false.
  final bool removePadding;

  /// Creates a scaffold page with SafeArea, simple scroll bar and a default inner padding.
  /// Its content will expand in width until a max page width set in this uikit.
  ///
  /// Eventually, an appbar and a FAB can be provided as custom widgets, so as a widget can be provided
  /// to be shown under on top of the page extended beyond the max page width.
  const PageSkeleton(
      {Key? key,
      required this.body,
      this.appBar,
      this.floatingActionButton,
      this.topWidget,
      this.removePadding = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: !kIsWeb && Platform.isIOS
              ? const ClampingScrollPhysics()
              : const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              topWidget ?? Container(),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxPageWidth),
                  child: Padding(
                    padding: removePadding
                        ? const EdgeInsets.all(0)
                        : const EdgeInsets.all(10.0),
                    child: body,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
