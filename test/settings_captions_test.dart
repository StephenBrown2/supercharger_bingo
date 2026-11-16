import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/screens/settings_screen.dart';
import 'package:supercharger_bingo/services/database_service.dart';

import 'support/test_sqlite3.dart';

/// Loads the SDK's bundled Roboto so text measures like it does on a phone.
Future<void> loadRoboto() async {
  final root = Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter';
  final dir = '$root/bin/cache/artifacts/material_fonts';
  final loader = FontLoader('Roboto');
  for (final weight in ['Regular', 'Medium']) {
    final bytes = File('$dir/Roboto-$weight.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    registerTestSqlite3();
    await DatabaseService.initialize(
      database: AppDatabase(NativeDatabase.memory()),
    );
    await loadRoboto();
  });

  testWidgets('notification grouping help explains how to exclude the app', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();
    final help = find.byTooltip('Notification grouping help');
    await tester.scrollUntilVisible(help, 300);
    final before =
        (await DatabaseService.getUserSettings()).notifyFirstEligible;
    await tester.tap(help);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Suggested'), findsOneWidget);
    expect(find.textContaining('Don\'t include these apps'), findsOneWidget);
    expect(find.textContaining('Uncheck Supercharger Bingo'), findsOneWidget);
    expect(
      (await DatabaseService.getUserSettings()).notifyFirstEligible,
      before,
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('every setting has a caption of at most two lines on a Pixel 9', (
    tester,
  ) async {
    // Pixel 9: 1080 x 2424 px at 2.625 = 411 x 923 dp.
    tester.view.physicalSize = const Size(1080, 2424);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    // The longest variants: a username, a sync date, the longest theme name.
    await DatabaseService.updateUserSettings(
      UserSettingsTableCompanion(
        username: const Value('supercharger_enthusiast'),
        lastXlsxSyncAt: Value(DateTime(2026, 11, 14)),
        appAppearance: const Value(AppAppearance.materialYou),
        notificationRadiusKm: const Value(1000),
      ),
    );

    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();

    final list = find.byType(Scrollable).first;
    final checked = <String>{};
    final problems = <String>[];
    void check() {
      for (final tile in tester.widgetList<ListTile>(find.byType(ListTile))) {
        final title = (tile.title as Text?)?.data ?? '?';
        if (!checked.add(title)) continue;
        final subtitle = tile.subtitle;
        if (subtitle == null) {
          problems.add('$title: no caption');
          continue;
        }
        final paragraph = tester.renderObject<RenderParagraph>(
          find.descendant(
            of: find.byWidget(subtitle),
            matching: find.byType(RichText),
          ),
        );
        final painter = TextPainter(
          text: paragraph.text,
          textDirection: TextDirection.ltr,
          textScaler: paragraph.textScaler,
        )..layout(maxWidth: paragraph.constraints.maxWidth);
        final lines = painter.computeLineMetrics().length;
        painter.dispose();
        if (lines > 2) problems.add('$title: $lines lines');
      }
    }

    check();
    while (true) {
      final before = tester.state<ScrollableState>(list).position.pixels;
      await tester.drag(list, const Offset(0, -400));
      await tester.pumpAndSettle();
      check();
      if (tester.state<ScrollableState>(list).position.pixels == before) break;
    }

    expect(problems, isEmpty);
  });
}
