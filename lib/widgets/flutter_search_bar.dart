import 'package:flutter/material.dart';

import '../src/utils/colors.dart';

/// A simple search bar.
class FlutterSearchBar extends StatefulWidget {
  /// The `String` argument is the actual text in the search bar.
  /// This method is called whenever the text changes.
  /// It can be used, for instance, to filter content depending on text input.
  final Function(String) onChangeText;

  final Function()? onFilterTap;

  final Function(String)? onOrderArrowTap;

  final Color? searchBarColor;

  /// A simple search bar.
  /// Using [onChangeText] you can take appropriate actions when
  /// the input text is changed.
  const FlutterSearchBar(
      {Key? key,
      required this.onChangeText,
      this.onFilterTap,
      this.onOrderArrowTap,
      this.searchBarColor})
      : super(key: key);

  @override
  createState() => _FlutterSearchBarState();
}

class _FlutterSearchBarState extends State<FlutterSearchBar>
    with TickerProviderStateMixin {
  /// The controller of the rotating animation of chevron when tapped
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      upperBound: 0.5,
    );
  }

  final TextEditingController _textController = TextEditingController();
  bool isOrderArrowOnDescent = true;
  var orderArrowCurrentValue = "descending";

  final ValueNotifier<bool> _showCancelIcon = ValueNotifier(false);

  @override
  void dispose() {
    _rotationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 60,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                onChanged: (value) {
                  _showCancelIcon.value = value.isNotEmpty;
                  widget.onChangeText(value);
                },
                style: const TextStyle(color: ColorsPalette.primaryGrey),
                keyboardType: TextInputType.text,
                cursorColor: ColorsPalette.primaryGrey,
                textInputAction: TextInputAction.go,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: "Cerca",
                  contentPadding: const EdgeInsets.all(0),
                  filled: true,
                  fillColor:
                      widget.searchBarColor ?? Theme.of(context).cardColor,
                  hintStyle: const TextStyle(color: ColorsPalette.primaryGrey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: widget.searchBarColor ??
                            Theme.of(context).cardColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: widget.searchBarColor ??
                            Theme.of(context).cardColor),
                  ),
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: widget.searchBarColor ??
                            Theme.of(context).cardColor),
                  ),
                  labelStyle: const TextStyle(color: ColorsPalette.primaryGrey),
                  focusColor:
                      widget.searchBarColor ?? Theme.of(context).cardColor,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.search),
                  ),
                  suffixIcon: ValueListenableBuilder<bool>(
                      valueListenable: _showCancelIcon,
                      builder: (context, showCancelIcon, child) {
                        if (showCancelIcon) {
                          return Padding(
                            padding: const EdgeInsets.all(0),
                            child: IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: ColorsPalette.primaryGrey,
                              ),
                              onPressed: () {
                                _showCancelIcon.value = false;
                                _textController.clear();
                                widget.onChangeText("");
                              },
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                ),
                controller: _textController,
              ),
            ),
            widget.onOrderArrowTap != null
                ? Padding(
                    padding: const EdgeInsets.all(0),
                    child: RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0)
                          .animate(_rotationController),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_downward_rounded),
                        onPressed: () {
                          isOrderArrowOnDescent = !isOrderArrowOnDescent;
                          if (isOrderArrowOnDescent) {
                            orderArrowCurrentValue = "descending";
                            _rotationController.reverse(from: 0.5);
                          } else {
                            orderArrowCurrentValue = "ascending";
                            _rotationController.forward(from: 0.0);
                          }
                          widget.onOrderArrowTap!(orderArrowCurrentValue);
                        },
                      ),
                    ))
                : Container(),
            widget.onFilterTap != null
                ? Padding(
                    padding: const EdgeInsets.all(0),
                    child: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        widget.onFilterTap!();
                      },
                    ))
                : Container()
          ],
        ));
  }
}
