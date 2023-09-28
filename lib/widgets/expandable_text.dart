import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ExpandableText extends StatefulWidget {
  final TextSpan textSpan;
  final TextSpan moreSpan;
  final int maxLines;

  const ExpandableText({
    super.key,
    required this.textSpan,
    required this.maxLines,
    required this.moreSpan,
  });

  @override
  createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  static const String _ellipsis = "\u2026\u0020";

  String get _lineEnding => "$_ellipsis${widget.moreSpan.text}";

  bool _isExpanded = false;

  GestureRecognizer get _tapRecognizer => TapGestureRecognizer()
    ..onTap = () {
      setState(() {
        _isExpanded = !_isExpanded;
      });
    };

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final maxLines = widget.maxLines;

          final richText = Text.rich(
            widget.textSpan,
            style: widget.textSpan.style,
          ).build(context) as RichText;
          final boxes = richText.measure(context,
              constraints.copyWith(maxWidth: constraints.maxWidth - 30));

          if (boxes.length <= maxLines || _isExpanded) {
            return RichText(text: widget.textSpan);
          } else {
            final croppedText = _ellipsizeText(boxes);
            final ellipsizedText =
                _buildEllipsizedText(croppedText, _tapRecognizer);

            if (ellipsizedText.measure(context, constraints).length <=
                maxLines) {
              return ellipsizedText;
            } else {
              final fixedEllipsizedText = croppedText.substring(
                  0, croppedText.length - _lineEnding.length);
              return _buildEllipsizedText(fixedEllipsizedText, _tapRecognizer);
            }
          }
        },
      );

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
          children: [widget.moreSpan],
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
