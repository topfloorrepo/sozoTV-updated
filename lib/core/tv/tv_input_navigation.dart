import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tv.dart';

/// Lets the remote leave a single-line input after dismissing the keyboard.
class TvInputNavigation extends StatelessWidget {
  const TvInputNavigation({
    super.key,
    required this.focusNode,
    required this.child,
  });

  final FocusNode focusNode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isTvPlatform) return child;
    return Focus(
      canRequestFocus: false,
      onKeyEvent: (_, event) {
        if (event is KeyUpEvent ||
            !focusNode.hasPrimaryFocus ||
            MediaQuery.viewInsetsOf(context).bottom > 0) {
          return KeyEventResult.ignored;
        }
        final key = event.logicalKey;
        if (TvKeys.isVertical(key)) {
          focusNode.focusInDirection(
            key == LogicalKeyboardKey.arrowDown
                ? TraversalDirection.down
                : TraversalDirection.up,
          );
          return KeyEventResult.handled;
        }
        if (event is KeyDownEvent && key == LogicalKeyboardKey.select) {
          SystemChannels.textInput.invokeMethod<void>('TextInput.show');
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}
