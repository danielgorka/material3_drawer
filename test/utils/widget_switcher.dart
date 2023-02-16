import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

typedef ToggleWidgetBuilder = Widget Function(
  BuildContext context,
  bool toggle,
);

class WidgetSwitcher extends StatefulWidget {
  const WidgetSwitcher({
    required this.builder,
    super.key,
  });

  final ToggleWidgetBuilder builder;

  static Future<void> toggle(WidgetTester tester) {
    return tester.tap(find.byType(WidgetSwitcher));
  }

  @override
  State<WidgetSwitcher> createState() => _WidgetSwitcherState();
}

class _WidgetSwitcherState extends State<WidgetSwitcher> {
  bool toggle = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.builder(context, toggle),
        ElevatedButton(
          onPressed: () => setState(() => toggle = !toggle),
          child: Container(),
        ),
      ],
    );
  }
}
