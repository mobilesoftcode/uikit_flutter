import 'package:flutter/material.dart';

/// A simple loader showing a ring gif animation centerd in the screen.
class Loader extends StatelessWidget {
  const Loader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Image.asset(
      'assets/loader.gif',
      package: "uikit_flutter",
      height: 70,
      width: 70,
      color: Theme.of(context).primaryColor,
    ));
  }
}
