import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:soplay/core/tv/tv.dart';

/// Keeps repository entry visible beside the library on a landscape TV.
class RepositoryPageBody extends StatelessWidget {
  const RepositoryPageBody({
    super.key,
    required this.form,
    required this.library,
  });

  final List<Widget> form;
  final List<Widget> library;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!isTvPlatform || constraints.maxWidth < 760) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [...form, const SizedBox(height: 24), ...library],
          );
        }

        return Row(
          children: [
            Expanded(
              child: ListView(
                primary: false,
                padding: const EdgeInsets.fromLTRB(40, 16, 16, 32),
                children: form,
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              flex: 2,
              child: ListView(
                primary: false,
                padding: const EdgeInsets.fromLTRB(24, 16, 40, 32),
                children: library,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A separate confirmation keeps one accidental OK from removing a repo.
Future<bool> confirmRepositoryRemoval(BuildContext context, String url) async {
  if (!isTvPlatform) return true;
  final strings = MaterialLocalizations.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: Text('general.remove'.tr()),
          content: Text(url, maxLines: 4, overflow: TextOverflow.ellipsis),
          actions: [
            TextButton(
              autofocus: true,
              onPressed: () => Navigator.of(dialog).pop(false),
              child: Text(strings.cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialog).pop(true),
              child: Text('general.remove'.tr()),
            ),
          ],
        ),
      ) ??
      false;
}
