import 'package:airesume/app_scroll_behavior.dart';
import 'package:airesume/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Android home scrolls without stretching at either edge', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 520);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AiresumeApp());

    final list = find.byType(ListView);
    final position = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position;
    final heading = find.text('Make your next move\nwith confidence.');
    final headingBounds = tester.getRect(heading);
    expect(find.byType(StretchingOverscrollIndicator), findsNothing);

    final topDrag = await tester.startGesture(tester.getCenter(list));
    await topDrag.moveBy(const Offset(0, 180));
    await tester.pump();
    expect(position.pixels, position.minScrollExtent);
    expect(tester.getRect(heading), headingBounds);
    await topDrag.up();
    await tester.pumpAndSettle();

    await tester.drag(list, const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(position.pixels, greaterThan(position.minScrollExtent));

    await tester.drag(list, const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(position.pixels, position.maxScrollExtent);
    final footer = find.text('Pasted text is checked locally on this device.');
    final footerBounds = tester.getRect(footer);

    final bottomDrag = await tester.startGesture(tester.getCenter(list));
    await bottomDrag.moveBy(const Offset(0, -180));
    await tester.pump();
    expect(position.pixels, position.maxScrollExtent);
    expect(tester.getRect(footer), footerBounds);
    expect(find.byType(StretchingOverscrollIndicator), findsNothing);
    await bottomDrag.up();
    await tester.pumpAndSettle();
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('desktop scrolling retains the Material scrollbar', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        scrollBehavior: const AppScrollBehavior(),
        theme: ThemeData(platform: TargetPlatform.windows),
        home: Scaffold(
          body: ListView(
            children: const [SizedBox(height: 2000, child: Text('Resume'))],
          ),
        ),
      ),
    );

    expect(find.byType(Scrollbar), findsOneWidget);
    expect(find.byType(StretchingOverscrollIndicator), findsNothing);
  });
}
