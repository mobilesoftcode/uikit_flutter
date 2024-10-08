import 'dart:math';

import 'package:flutter/material.dart';

class ExpandableFloatingContainer extends StatefulWidget {
  final Widget child;
  final Widget title;
  final Color backgroundColor;
  final double horizontalPadding;
  final double verticalPercentage;
  final double? maxWidth;

  final int animationMillis;
  final Widget Function(bool isExpanded) icon;

  const ExpandableFloatingContainer(
      {super.key,
      required this.icon,
      required this.title,
      required this.backgroundColor,
      required this.child,
      this.horizontalPadding = 16.0,
      this.verticalPercentage = 0.7,
      this.animationMillis = 300,
      this.maxWidth});

  @override
  State<ExpandableFloatingContainer> createState() =>
      _ExpandableFloatingContainerState();
}

class _ExpandableFloatingContainerState
    extends State<ExpandableFloatingContainer> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(24))),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            AnimatedSize(
                curve: Curves.easeInCirc,
                duration: Duration(milliseconds: widget.animationMillis),
                child: _body()),
            _action(!isExpanded)
          ],
        ));
  }

  Widget _action(bool expand) {
    return IconButton(
        onPressed: () {
          setState(() {
            isExpanded = expand;
          });
        },
        icon: widget.icon(isExpanded));
  }

  double _width() {
    var width =
        MediaQuery.of(context).size.width - (widget.horizontalPadding * 2);

    var maxWidth = widget.maxWidth;

    if (maxWidth != null) {
      width = min(maxWidth, width);
    }

    return width;
  }

  Widget _body() {
    if (!isExpanded) {
      return Container();
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height * widget.verticalPercentage),
      child: SizedBox(
        width: _width(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [widget.title, widget.child],
        ),
      ),
    );
  }
}
