import 'package:flutter/material.dart';

/// A card-styled container widget with rounded corners, shadows on the background
/// and eventually an external margin.
class ShadowBox extends StatelessWidget {
  /// The child widget to append inside the container.
  final Widget child;

  /// If `true` removes the default external margins of the ShadowBox container.
  /// Defaults to `false`.
  final bool removeMargin;

  /// Creates a card-styled container widget with rounded corners, shadows on the background
  /// and eventually an external margin.
  ///
  /// It has a default margin that can be removed by setting `removeMargin` to `true`.
  const ShadowBox({
    Key? key,
    required this.child,
    this.removeMargin = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: removeMargin ? EdgeInsets.zero : const EdgeInsets.all(10),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(color: Theme.of(context).shadowColor, blurRadius: 10)
      ]),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
              color: Theme.of(context).colorScheme.background, child: child)),
    );
  }
}

/// A card-styled container widget with rounded corners, shadows on the background
/// and eventually an external margin. It shows a title.
class ShadowBoxWithTitle extends StatefulWidget {
  /// The child widget to append inside the container.
  final Widget child;

  /// If `true` removes the default external margins of the ShadowBox container.
  /// Defaults to `false`.
  final bool removeMargin;

  /// If `true` removes the padding on top and bottom of `child` in ShadowBox.
  /// Defaults to `false`.
  final bool removeInnerPadding;

  /// The title to show on top of the shadow box.
  final String title;

  /// If `true` the title is colored with red.
  final bool isWarning;

  /// If `true` adds an icon button to show/hide [child]
  final bool shouldAllowHiding;

  /// If `true` shows the child, otherwise hides it initially by default.
  /// Defaults to `true`.
  final bool initiallyShowChild;

  /// Creates a card-styled container widget with rounded corners, shadows on the background
  /// and eventually an external margin.
  ///
  /// It has a default margin that can be removed by setting `removeMargin` to `true`.
  /// It has also a title and eventually an icon button to hide/show content.
  const ShadowBoxWithTitle(
      {Key? key,
      required this.child,
      this.removeMargin = false,
      this.removeInnerPadding = false,
      required this.title,
      this.isWarning = false,
      this.shouldAllowHiding = false,
      this.initiallyShowChild = true})
      : super(key: key);

  @override
  createState() => _ShadowBoxWithTitleState();
}

class _ShadowBoxWithTitleState extends State<ShadowBoxWithTitle>
    with TickerProviderStateMixin {
  late bool showChild = (MediaQuery.of(context).accessibleNavigation)
      ? true
      : widget.initiallyShowChild;

  /// The controller of the rotating animation of chevron when tapped
  late final AnimationController _rotationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    upperBound: 0.5,
  );

  /// The controller of expandable child widget when chevron is tapped
  late final AnimationController _expandController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 200));

  void _runAnimationCheck() {
    if (widget.initiallyShowChild) {
      _expandController.forward();
      _rotationController.forward(from: 0);
    } else {
      _rotationController.reverse(from: 0.5);
      _expandController.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    _runAnimationCheck();
  }

  @override
  void didUpdateWidget(ShadowBoxWithTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    // _runAnimationCheck();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadowBox(
      removeMargin: widget.removeMargin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            excludeSemantics: true,
            label: widget.title,
            child: Material(
              child: InkWell(
                onTap: widget.shouldAllowHiding
                    ? () {
                        if (showChild) {
                          _rotationController.reverse(from: 0.5);
                          _expandController.reverse();
                        } else {
                          _rotationController.forward(from: 0.0);
                          _expandController.forward();
                        }
                        showChild = !showChild;
                      }
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 35,
                      width: 55,
                      child: Container(),
                    ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  color: widget.isWarning
                                      ? const Color(0xFFF85409)
                                      : null),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 35,
                      width: 55,
                      child: widget.shouldAllowHiding
                          ? Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: RotationTransition(
                                turns: Tween(begin: 0.0, end: 1.0)
                                    .animate(_rotationController),
                                child: const Icon(Icons.keyboard_arrow_down),
                                
                                
                              ),
                            )
                          : Container(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizeTransition(
            axisAlignment: 1.0,
            sizeFactor: CurvedAnimation(
              parent: _expandController,
              curve: Curves.fastOutSlowIn,
            ),
            child: Material(
              child: Column(
                children: [
                  const Divider(),
                  Visibility(
                    visible: !widget.removeInnerPadding,
                    child: const SizedBox(height: 5),
                  ),
                  widget.child,
                  Visibility(
                    visible: !widget.removeInnerPadding,
                    child: const SizedBox(height: 5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
