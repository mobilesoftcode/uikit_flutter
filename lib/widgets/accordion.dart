import 'package:flutter/material.dart';

/// Accordion widget with title and a [Widget] to be shown when expanded
class Accordion extends StatefulWidget {
  /// The text to show when the accordion is collapsed. It is visible also when
  /// the accordion is expanded.
  final String title;

  /// The [Widget] to show when the accordion is expanded.
  final Widget child;
  
  /// Accordion widget with title and a [Widget] to be shown when expanded.
  /// The accordion is collapsed by default.
  const Accordion({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  State<Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> with TickerProviderStateMixin {
  late bool _showChild = false;

  /// The controller of the rotating animation of chevron when tapped
  late final AnimationController _rotationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    upperBound: 0.5,
  );

  /// The controller of expandable child widget when chevron is tapped
  late final AnimationController _expandController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 200));

  @override
  void dispose() {
    _rotationController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _changeTileView() {
    if (_showChild) {
      _rotationController.reverse(from: 0.5);
      _expandController.reverse();
    } else {
      _rotationController.forward(from: 0.0);
      _expandController.forward();
    }
    setState(() {
      _showChild = !_showChild;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            child: GestureDetector(
              onTap: () {
                _changeTileView();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  ExcludeSemantics(
                    child: IconButton(
                      icon: RotationTransition(
                        turns: Tween(begin: 0.0, end: 1.0)
                            .animate(_rotationController),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                        ),
                      ),
                      onPressed: () {
                        _changeTileView();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          FocusScope(
            child: SizeTransition(
              axisAlignment: 1.0,
              sizeFactor: CurvedAnimation(
                parent: _expandController,
                curve: Curves.fastOutSlowIn,
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  widget.child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
