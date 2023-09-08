import 'package:flutter/material.dart';
import 'package:uikit_flutter/src/utils/colors.dart';

/// A simple loader showing a ring gif animation centerd in the screen.
class Loader extends StatelessWidget {
  const Loader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Image.asset('assets/double_ring_loading_io.gif',
            package: "uikit_flutter",
            height: 70,
            width: 70,
            color: ColorsPalette.primaryBlue));
  }
}
