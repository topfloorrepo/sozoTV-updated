import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:soplay/core/system/platform_utils.dart';

/// D-pad and media-key vocabulary for the TV build.
///
/// Nothing here runs on phone or desktop: every consumer is behind an
/// `isTvPlatform` guard, and [TvShortcuts] returns its child untouched when the
/// flag is false.
class TvKeys {
  TvKeys._();

  /// DPAD_CENTER arrives as [LogicalKeyboardKey.select]; the rest are what a
  /// keyboard, a game controller or an Android TV box's mouse-mode send.
  static final Set<LogicalKeyboardKey> activate = <LogicalKeyboardKey>{
    LogicalKeyboardKey.select,
    LogicalKeyboardKey.enter,
    LogicalKeyboardKey.numpadEnter,
    LogicalKeyboardKey.space,
    LogicalKeyboardKey.gameButtonA,
  };

  static final Set<LogicalKeyboardKey> directional = <LogicalKeyboardKey>{
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
  };

  static bool isActivate(LogicalKeyboardKey k) => activate.contains(k);

  static bool isDirectional(LogicalKeyboardKey k) => directional.contains(k);

  static bool isHorizontal(LogicalKeyboardKey k) =>
      k == LogicalKeyboardKey.arrowLeft || k == LogicalKeyboardKey.arrowRight;

  static bool isVertical(LogicalKeyboardKey k) =>
      k == LogicalKeyboardKey.arrowUp || k == LogicalKeyboardKey.arrowDown;

  /// BACK is deliberately absent from every map in this file. Android delivers
  /// it as a system back, which the app's existing `PopScope` handlers already
  /// route correctly — intercepting it in Dart would break them.
  static bool isBack(LogicalKeyboardKey k) =>
      k == LogicalKeyboardKey.goBack || k == LogicalKeyboardKey.escape;
}

/// Maps remote buttons to Material activation and consumes auto-repeat before
/// it reaches Flutter's fallback shortcuts. Directional keys can still repeat.
class TvShortcuts extends StatelessWidget {
  const TvShortcuts({super.key, required this.child});

  final Widget child;

  static const Map<ShortcutActivator, Intent> _map =
      <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.select, includeRepeats: false):
            ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.gameButtonA, includeRepeats: false):
            ActivateIntent(),
      };

  @override
  Widget build(BuildContext context) {
    if (!isTvPlatform) return child;
    return Focus(
      canRequestFocus: false,
      onKeyEvent: (_, event) =>
          event is KeyRepeatEvent && TvKeys.isActivate(event.logicalKey)
          ? KeyEventResult.handled
          : KeyEventResult.ignored,
      child: Shortcuts(shortcuts: _map, child: child),
    );
  }
}

/// Scrolls [context]'s render object into view across every enclosing
/// scrollable, so a poster inside a horizontal rail inside a vertical
/// `CustomScrollView` is brought into view on both axes with one call.
///
/// [alignment] 0.5 centres the target (right for horizontal rails); 0.3 puts it
/// in the upper third (right for vertical lists, where the rows below should
/// stay visible).
void tvEnsureVisible(
  BuildContext context, {
  double alignment = 0.5,
  Duration duration = const Duration(milliseconds: 220),
  Curve curve = Curves.easeOutCubic,
}) {
  if (!isTvPlatform) return;
  if (Scrollable.maybeOf(context) == null) return;
  Scrollable.ensureVisible(
    context,
    alignment: alignment,
    duration: duration,
    curve: curve,
  );
}
