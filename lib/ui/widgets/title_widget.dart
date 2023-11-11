import 'package:flutter/material.dart';

/// The [TitleWidget] is a very simple widget that displays a title with
/// instructions on how to interact with the widget
class TitleWidget extends StatelessWidget {
  /// Creates a [TitleWidget]
  const TitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Text(
          'Drag to rotate',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
