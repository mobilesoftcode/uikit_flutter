import 'dart:async';

import 'package:flutter/material.dart';

class TimePicker extends StatefulWidget {
  final bool roundBorder;
  final double maxWidth;
  final double maxHeight;
  final Color colorBackground;
  final TextStyle style;
  final TextStyle selectedStyle;
  final String hoursSemanticLabel;
  final String minutesSemanticLabel;
  final DateTime? initialTime;
  final Function(DateTime) onTimeSelected;
  final bool selectAtStart;
  final Duration? debouncingWindow;
  final double minutesOffAxisFraction;
  final double hoursOffAxisFraction;
  final double diameterRatio;
  final double itemExtent;
  final double separatorPadding;

  const TimePicker({
    super.key,
    this.roundBorder = false,
    this.maxWidth = 180,
    this.maxHeight = 200,
    this.colorBackground = Colors.transparent,
    this.style = const TextStyle(
        color: Colors.black, fontSize: 12, fontWeight: FontWeight.normal),
    this.selectedStyle = const TextStyle(
        color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
    required this.hoursSemanticLabel,
    required this.minutesSemanticLabel,
    this.minutesOffAxisFraction = 1.0,
    this.hoursOffAxisFraction = -1.0,
    this.diameterRatio = 1.1,
    this.itemExtent = 25.0,
    this.initialTime,
    required this.onTimeSelected,
    this.selectAtStart = false,
    this.debouncingWindow = const Duration(milliseconds: 300),
    this.separatorPadding = 0.0,
  });

  @override
  State<TimePicker> createState() => TimePickerState();
}

class TimePickerState extends State<TimePicker> {
  int hours = 24;
  int minutes = 60;
  late int hourSelected;
  late int minuteSelected;
  late DateTime initialTime;
  late final _Debouncer? _debouncer;

  @override
  void initState() {
    super.initState();
    initialTime = widget.initialTime ?? DateTime.now();
    hourSelected = initialTime.hour;
    minuteSelected = initialTime.minute;
    if (widget.selectAtStart) {
      widget.onTimeSelected(initialTime);
    }
    Duration? debouncingWindow = widget.debouncingWindow;

    _debouncer = debouncingWindow == null
        ? null
        : _Debouncer(duration: debouncingWindow);
  }

  @override
  Widget build(BuildContext context) {
    Color colorBackground = widget.colorBackground == Colors.transparent
        ? widget.colorBackground
        : widget.colorBackground.withOpacity(0.2); // Sfondo semitrasparente

    return Container(
      decoration: widget.roundBorder
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(
                  10), // Imposta il raggio di curvatura dei bordi
              color: colorBackground,
            )
          : BoxDecoration(
              color: colorBackground,
            ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.maxWidth,
          maxHeight: widget.maxHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _ListWheelScrollViewDigits(
                  // scrollview ore
                  style: widget.style,
                  selectedStyle: widget.selectedStyle,
                  itemCount: hours,
                  initialValue: initialTime.hour,
                  semanticLabel: widget.hoursSemanticLabel,
                  semanticValueBuilder: (hours) {
                    return "${hours.toString().padLeft(2, '0')}:${minuteSelected.toString().padLeft(2, '0')}";
                  },
                  offAxisFraction: widget.hoursOffAxisFraction,
                  diameterRatio: widget.diameterRatio,
                  itemExtent: widget.itemExtent,
                  onDigitSelected: (value) {
                    setState(() {
                      hourSelected = value;
                      _debounceAction(() => widget.onTimeSelected(
                          //Restituisce ora selezionata
                          DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day,
                              hourSelected,
                              minuteSelected)));
                    });
                  }),

              ExcludeSemantics(
                child: _ListWheelSeparator(
                    padding: widget.separatorPadding,
                    style: widget.selectedStyle),
              ), // separatore

              _ListWheelScrollViewDigits(
                  // scrollview minuti
                  style: widget.style,
                  selectedStyle: widget.selectedStyle,
                  itemCount: minutes,
                  initialValue: initialTime.minute,
                  semanticLabel: widget.minutesSemanticLabel,
                  semanticValueBuilder: (minutes) {
                    return "${hourSelected.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
                  },
                  offAxisFraction: widget.minutesOffAxisFraction,
                  diameterRatio: widget.diameterRatio,
                  itemExtent: widget.itemExtent,
                  onDigitSelected: (value) {
                    setState(() {
                      minuteSelected = value;
                      widget.onTimeSelected(
                          //Restituisce ora selezionata
                          DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day,
                              hourSelected,
                              minuteSelected));
                    });
                  }),
            ],
          ),
        ),
      ),
    );
  }

  void _debounceAction(VoidCallback action) {
    if (_debouncer != null) {
      _debouncer!.run(action);
    } else {
      action.call();
    }
  }
}

class _Debouncer {
  final Duration duration;
  Timer? _timer;

  _Debouncer({required this.duration});

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(duration, action);
  }
}

// COMPONENTE SEPARATORE
class _ListWheelSeparator extends StatelessWidget {
  const _ListWheelSeparator({required this.padding, required this.style});

  final double padding;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: padding),
          Text(
            ":",
            style: style,
          ),
          SizedBox(width: padding),
        ],
      ),
    );
  }
}

// COMPONENTE SCROLLVIEW
class _ListWheelScrollViewDigits extends StatefulWidget {
  final int initialValue;
  final TextStyle style;
  final TextStyle selectedStyle;
  final int itemCount;
  final ValueChanged<int> onDigitSelected;
  final String semanticLabel;
  final String Function(int) semanticValueBuilder;
  final double offAxisFraction;
  final double diameterRatio;
  final double itemExtent;

  const _ListWheelScrollViewDigits({
    this.initialValue = 0,
    required this.style,
    required this.selectedStyle,
    required this.itemCount,
    required this.onDigitSelected,
    required this.semanticLabel,
    required this.semanticValueBuilder,
    required this.offAxisFraction,
    required this.diameterRatio,
    required this.itemExtent,
  });

  @override
  State<_ListWheelScrollViewDigits> createState() =>
      _ListWheelScrollViewDigitsState();
}

class _ListWheelScrollViewDigitsState
    extends State<_ListWheelScrollViewDigits> {
  late int digitSelected;
  late FixedExtentScrollController controller;

  @override
  void initState() {
    super.initState();
    digitSelected = widget.initialValue;
    controller = FixedExtentScrollController(
        initialItem: widget.initialValue); // Valore iniziale selezionato
    WidgetsBinding.instance.addPostFrameCallback((_) {
      digitSelected = widget.initialValue;
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void _handleSelectedItemChanged(int index) {
    widget.onDigitSelected(index);
    digitSelected = index;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Semantics(
        label: widget.semanticLabel,
        excludeSemantics: true,
        onIncrease: () => controller.jumpToItem(digitSelected + 1),
        value: widget.semanticValueBuilder(digitSelected),
        increasedValue: () {
          var newValue = digitSelected + 1;
          if (newValue == widget.itemCount) {
            newValue = 0;
          }
          return widget.semanticValueBuilder(newValue);
        }(),
        decreasedValue: () {
          var newValue = digitSelected - 1;
          if (newValue == 0) {
            newValue = widget.itemCount;
          }
          return widget.semanticValueBuilder(newValue);
        }(),
        onDecrease: () => controller.jumpToItem(digitSelected - 1),
        child: ListWheelScrollView.useDelegate(
          controller: controller,
          offAxisFraction: widget.offAxisFraction,
          //inclinazione dx
          diameterRatio: widget.diameterRatio,
          itemExtent:
              widget.itemExtent * MediaQuery.textScalerOf(context).scale(1),
          // dim item
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) {
            _handleSelectedItemChanged(index);
          },
          childDelegate: ListWheelChildLoopingListDelegate(
              children: _listWheelChildren(widget.style, widget.selectedStyle,
                  widget.itemCount, digitSelected)),
        ),
      ),
    );
  }

// LISTA ELEMENTI SCROLLVIEW
  List<Widget> _listWheelChildren(TextStyle style, TextStyle selectedStyle,
      int numChild, int digitSelected) {
    return List.generate(numChild, (index) {
      return _HoursDigit(
          style: style,
          selectedStyle: selectedStyle,
          index: index,
          digitSelected: digitSelected);
    });
  }
}

// ELEMENTO SCROLLVIEW
class _HoursDigit extends StatelessWidget {
  const _HoursDigit(
      {required this.style,
      required this.selectedStyle,
      required this.index,
      required this.digitSelected});

  final TextStyle style;
  final TextStyle selectedStyle;
  final int index;
  final int digitSelected;

  @override
  Widget build(BuildContext context) {
    final isSelected = index == digitSelected;

    final textStyle = isSelected ? selectedStyle : style;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: index == digitSelected
              ? const BorderSide(color: Colors.black)
              : BorderSide.none,
          bottom: index == digitSelected
              ? const BorderSide(color: Colors.black)
              : BorderSide.none,
        ),
      ),
      child: Text(
        index.toString().padLeft(2, '0'),
        textAlign: TextAlign.center,
        style: textStyle,
      ),
    );
  }
}
