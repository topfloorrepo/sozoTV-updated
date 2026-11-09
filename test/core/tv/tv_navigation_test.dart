import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soplay/core/system/platform_utils.dart';
import 'package:soplay/core/tv/tv.dart';
import 'package:soplay/core/tv/tv_text_entry.dart';

Widget _app(Widget child) => MaterialApp(
  builder: (_, navigator) => TvShortcuts(child: navigator!),
  home: Scaffold(body: child),
);

void main() {
  setUp(() => debugSetTvPlatform(true));
  tearDown(() => debugSetTvPlatform(false));

  testWidgets('remote OK activates a Material control once per press', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      _app(
        TextButton(
          autofocus: true,
          onPressed: () => presses++,
          child: const Text('Use source'),
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.select);
    await tester.sendKeyRepeatEvent(LogicalKeyboardKey.select);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.select);
    expect(presses, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    expect(presses, 2);
  });

  testWidgets('repository URL editor applies on Done and discards on Back', (
    tester,
  ) async {
    final controller = TextEditingController();
    final edits = <String>[];
    await tester.pumpWidget(
      _app(
        Column(
          children: [
            TvTextEntry(
              autofocus: true,
              field: TextField(
                controller: controller,
                onChanged: edits.add,
                decoration: const InputDecoration(labelText: 'Repository URL'),
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('Add source')),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'https://example.org/index');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(controller.text, 'https://example.org/index');
    expect(edits, ['https://example.org/index']);
    expect(find.byType(TextField), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'discard me');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(controller.text, 'https://example.org/index');
    expect(edits, hasLength(1));

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
