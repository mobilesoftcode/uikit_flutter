import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ExpandableText extends StatefulWidget {
  final TextSpan textSpan;
  final Text seeMore;
  final Text seeLess;
  final int maxLines;

  const ExpandableText({
    super.key,
    required this.textSpan,
    required this.maxLines,
    this.seeMore = const Text(
      "Show more",
      style: TextStyle(
          fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
    ),
    this.seeLess = const Text(
      "Show less",
      style: TextStyle(
          fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
    ),
  });

  @override
  createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  static const String _ellipsis = "\u2026\u0020";

  String get _lineEnding => "$_ellipsis${widget.seeMore.data}";

  bool _isExpanded = false;

  GestureRecognizer get _tapRecognizer => TapGestureRecognizer()
    ..onTap = () {
      setState(() {
        _isExpanded = !_isExpanded;
      });
    };

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 100),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxLines = widget.maxLines;
    
          final richText = Text.rich(
            widget.textSpan,
            style: widget.textSpan.style,
          ).build(context) as RichText;
          final boxes = richText.measure(
              context,
              constraints.copyWith(
                  minWidth: constraints.minWidth,
                  maxWidth: constraints.maxWidth));
    
          if (boxes.length <= maxLines || _isExpanded) {
            List<TextSpan> children = [widget.textSpan];
            if (_isExpanded) {
              children.add(TextSpan(
                  text: widget.seeLess.data,
                  style: widget.seeLess.style,
                  recognizer: _tapRecognizer));
            }
            return RichText(text: TextSpan(children: children));
          } else {
            final croppedText = _ellipsizeText(boxes);
            final ellipsizedText =
                _buildEllipsizedText(croppedText, _tapRecognizer);
    
            if (ellipsizedText.measure(context, constraints).length <=
                maxLines) {
              return ellipsizedText;
            } else {
              final fixedEllipsizedText = croppedText.substring(
                  0, (croppedText.length - _lineEnding.length).abs());
              return _buildEllipsizedText(fixedEllipsizedText, _tapRecognizer);
            }
          }
        },
      ),
    );
  }

  String _ellipsizeText(List<TextBox> boxes) {
    var text = widget.textSpan.text ?? "";
    widget.textSpan.children?.forEach((element) {
      text += element.toPlainText();
    });
    final maxLines = widget.maxLines;

    double calculateLinesLength(List<TextBox> boxes) => boxes
        .map((box) => box.right - box.left)
        .reduce((acc, value) => acc += value);

    final requiredLength = calculateLinesLength(boxes.sublist(0, maxLines));
    final totalLength = calculateLinesLength(boxes);

    final requiredTextFraction = requiredLength / totalLength;
    return text.substring(0, (text.length * requiredTextFraction).floor());
  }

  RichText _buildEllipsizedText(String text, GestureRecognizer tapRecognizer) =>
      RichText(
        text: TextSpan(
          text: "$text$_ellipsis",
          style: widget.textSpan.style,
          children: [
            TextSpan(
                text: widget.seeMore.data,
                style: widget.seeMore.style,
                recognizer: tapRecognizer)
          ],
        ),
      );
}

extension _TextMeasurer on RichText {
  List<TextBox> measure(BuildContext context, Constraints constraints) {
    final renderObject = createRenderObject(context)..layout(constraints);
    return renderObject.getBoxesForSelection(
      TextSelection(
        baseOffset: 0,
        extentOffset: text.toPlainText().length,
      ),
    );
  }
}
