import 'package:flutter/material.dart' hide NavigationDrawer;
import 'package:flutter_test/flutter_test.dart';
import 'package:material3_drawer/src/navigation_drawer.dart';

import '../utils/widget_switcher.dart';

void main() {
  group(
    'NavigationDrawer',
    () {
      bool isSmallLabelVisible(WidgetTester tester, String label) {
        final finder = find.ancestor(
          of: find.text(label).last,
          matching: find.byType(SizeTransition),
        );
        final sizeTransition = tester.widget<SizeTransition>(finder);
        return sizeTransition.sizeFactor.value != 0;
      }

      bool isLargeLabelVisible(WidgetTester tester, String label) {
        final finder = find.ancestor(
          of: find.text(label).first,
          matching: find.byType(SizeTransition),
        );
        final sizeTransition = tester.widget<SizeTransition>(finder);
        return sizeTransition.sizeFactor.value != 0;
      }

      final items = [
        NavigationDrawerItem(
          label: 'Item 1',
          icon: const Icon(Icons.looks_one),
          indicator: '2',
        ),
        NavigationDrawerItem(
          label: 'Item 2',
          icon: const Icon(Icons.looks_two),
        ),
        NavigationDrawerItem(
          label: 'Item 3',
          icon: const Icon(Icons.looks_3),
        ),
      ];

      testWidgets(
        'should show all large labels, icons and large indicators '
        'when drawer is expanded',
        (tester) async {
          // act
          await tester.pumpWidget(
            MaterialApp(
              home: NavigationDrawer(
                items: items,
              ),
            ),
          );
          await tester.pumpAndSettle();

          // assert
          expect(isLargeLabelVisible(tester, 'Item 1'), isTrue);
          expect(isSmallLabelVisible(tester, 'Item 1'), isFalse);

          expect(isLargeLabelVisible(tester, 'Item 2'), isTrue);
          expect(isSmallLabelVisible(tester, 'Item 2'), isFalse);

          expect(isLargeLabelVisible(tester, 'Item 3'), isTrue);
          expect(isSmallLabelVisible(tester, 'Item 3'), isFalse);

          expect(find.byIcon(Icons.looks_one), findsOneWidget);
          expect(find.byIcon(Icons.looks_two), findsOneWidget);
          expect(find.byIcon(Icons.looks_3), findsOneWidget);

          final finder = find.byType(Badge).first;
          final badge = tester.widget<Badge>(finder);
          expect(badge.isLabelVisible, isFalse);
          expect(find.text('2'), findsOneWidget);
        },
      );

      testWidgets(
        'should show all small labels, icons and badge indicators '
        'when drawer is collapsed and showRailLabel is true',
        (tester) async {
          // act
          await tester.pumpWidget(
            MaterialApp(
              home: NavigationDrawer(
                initialState: DrawerState.collapsed,
                items: items,
              ),
            ),
          );

          // assert
          expect(isLargeLabelVisible(tester, 'Item 1'), isFalse);
          expect(isSmallLabelVisible(tester, 'Item 1'), isTrue);

          expect(isLargeLabelVisible(tester, 'Item 2'), isFalse);
          expect(isSmallLabelVisible(tester, 'Item 2'), isTrue);

          expect(isLargeLabelVisible(tester, 'Item 3'), isFalse);
          expect(isSmallLabelVisible(tester, 'Item 3'), isTrue);

          expect(find.byIcon(Icons.looks_one), findsOneWidget);
          expect(find.byIcon(Icons.looks_two), findsOneWidget);
          expect(find.byIcon(Icons.looks_3), findsOneWidget);

          final finder = find.byType(Badge).first;
          final badge = tester.widget<Badge>(finder);
          expect(badge.isLabelVisible, isTrue);
          expect(find.text('2'), findsOneWidget);
        },
      );

      testWidgets(
        'should show no labels, all icons and small indicators '
        'when drawer is collapsed and showRailLabel is false',
        (tester) async {
          // act
          await tester.pumpWidget(
            MaterialApp(
              home: NavigationDrawer(
                initialState: DrawerState.collapsed,
                items: items,
                showRailLabel: false,
              ),
            ),
          );

          // assert
          expect(isLargeLabelVisible(tester, 'Item 1'), isFalse);
          expect(isSmallLabelVisible(tester, 'Item 1'), isFalse);

          expect(isLargeLabelVisible(tester, 'Item 2'), isFalse);
          expect(isSmallLabelVisible(tester, 'Item 2'), isFalse);

          expect(isLargeLabelVisible(tester, 'Item 3'), isFalse);
          expect(isSmallLabelVisible(tester, 'Item 3'), isFalse);

          expect(find.byIcon(Icons.looks_one), findsOneWidget);
          expect(find.byIcon(Icons.looks_two), findsOneWidget);
          expect(find.byIcon(Icons.looks_3), findsOneWidget);

          final finder = find.byType(Badge).first;
          final badge = tester.widget<Badge>(finder);
          expect(badge.isLabelVisible, isTrue);
          expect(find.text('2'), findsOneWidget);
        },
      );

      testWidgets(
        'should show header when drawer is expanded',
        (tester) async {
          // arrange
          const header = Text('Header');

          // act
          await tester.pumpWidget(
            MaterialApp(
              home: NavigationDrawer(
                items: items,
                headerBuilder: (context, anim) => header,
              ),
            ),
          );

          // assert
          expect(find.byWidget(header), findsOneWidget);
        },
      );

      testWidgets(
        'should show header when drawer is collapsed',
        (tester) async {
          // arrange
          const header = Text('Header');

          // act
          await tester.pumpWidget(
            MaterialApp(
              home: NavigationDrawer(
                initialState: DrawerState.collapsed,
                items: items,
                headerBuilder: (context, anim) => header,
              ),
            ),
          );

          // assert
          expect(find.byWidget(header), findsOneWidget);
        },
      );

      testWidgets(
        'should not show menu button when type is standard',
        (tester) async {
          // act
          await tester.pumpWidget(
            MaterialApp(
              home: NavigationDrawer(
                items: items,
              ),
            ),
          );

          // assert
          expect(find.byIcon(Icons.menu), findsNothing);
        },
      );

      testWidgets(
        'should collapse drawer on menu button pressed '
        'when drawer was expanded',
        (tester) async {
          // act
          await tester.pumpWidget(
            MaterialApp(
              home: NavigationDrawer(
                collapsible: true,
                items: items,
              ),
            ),
          );

          await tester.tap(find.byIcon(Icons.menu));

          // assert expanded only
          expect(isLargeLabelVisible(tester, 'Item 1'), isTrue);
          expect(isSmallLabelVisible(tester, 'Item 1'), isFalse);

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));

          // assert during animation
          expect(isLargeLabelVisible(tester, 'Item 1'), isTrue);
          expect(isSmallLabelVisible(tester, 'Item 1'), isTrue);

          await tester.pumpAndSettle();

          // assert collapsed only
          expect(isLargeLabelVisible(tester, 'Item 1'), isFalse);
          expect(isSmallLabelVisible(tester, 'Item 1'), isTrue);
        },
      );

      testWidgets(
        'should expand drawer on menu button pressed '
        'when drawer was collapsed',
        (tester) async {
          // act
          await tester.pumpWidget(
            MaterialApp(
              home: NavigationDrawer(
                initialState: DrawerState.collapsed,
                collapsible: true,
                items: items,
              ),
            ),
          );

          await tester.tap(find.byIcon(Icons.menu));

          // assert collapsed only
          expect(isLargeLabelVisible(tester, 'Item 1'), isFalse);
          expect(isSmallLabelVisible(tester, 'Item 1'), isTrue);

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));

          // assert during animation
          expect(isLargeLabelVisible(tester, 'Item 1'), isTrue);
          expect(isSmallLabelVisible(tester, 'Item 1'), isTrue);

          await tester.pumpAndSettle();

          // assert expanded only
          expect(isLargeLabelVisible(tester, 'Item 1'), isTrue);
          expect(isSmallLabelVisible(tester, 'Item 1'), isFalse);
        },
      );

      testWidgets(
        'should show elevation overlay on selected item',
        (tester) async {
          // arrange
          void assertColored(
            String label, {
            required bool colored,
          }) {
            final finder = find.ancestor(
              of: find.text(label).first,
              matching: find.byType(AnimatedContainer),
            );
            final context = tester.element(finder);
            final animatedContainer = tester.widget<AnimatedContainer>(finder);
            final boxDecoration =
                animatedContainer.decoration! as BoxDecoration;

            expect(
              boxDecoration.color,
              colored
                  ? ElevationOverlay.applySurfaceTint(
                      Colors.transparent,
                      Theme.of(context).colorScheme.primary,
                      6,
                    )
                  : isNull,
            );
          }

          // act
          await tester.pumpWidget(
            MaterialApp(
              home: NavigationDrawer(
                items: items,
                selectedIndex: 1,
              ),
            ),
          );

          // assert
          assertColored('Item 1', colored: false);
          assertColored('Item 2', colored: true);
          assertColored('Item 3', colored: false);
        },
      );

      testWidgets(
        'should call onItemTap on item tap',
        (tester) async {
          // arrange
          final taps = <int>[];

          // act
          await tester.pumpWidget(
            MaterialApp(
              home: NavigationDrawer(
                items: items,
                onItemTap: taps.add,
              ),
            ),
          );

          await tester.tap(find.text('Item 1').first);
          await tester.tap(find.text('Item 2').first);
          await tester.tap(find.text('Item 3').first);
          await tester.tap(find.text('Item 1').first);
          await tester.tap(find.text('Item 1').first);
          await tester.pumpAndSettle();

          // assert
          expect(taps, [0, 1, 2, 0, 0]);
        },
      );

      testWidgets(
        'should expand or collapse when initialState was changed',
        (tester) async {
          // act
          await tester.pumpWidget(
            MaterialApp(
              home: WidgetSwitcher(
                builder: (context, toggle) {
                  return NavigationDrawer(
                    initialState:
                        toggle ? DrawerState.expanded : DrawerState.collapsed,
                    items: items,
                  );
                },
              ),
            ),
          );

          // Expand
          await WidgetSwitcher.toggle(tester);

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));

          // assert during animation
          expect(isLargeLabelVisible(tester, 'Item 1'), isTrue);
          expect(isSmallLabelVisible(tester, 'Item 1'), isTrue);

          await tester.pumpAndSettle();

          // assert expanded only
          expect(isLargeLabelVisible(tester, 'Item 1'), isTrue);
          expect(isSmallLabelVisible(tester, 'Item 1'), isFalse);

          // Collapse
          await WidgetSwitcher.toggle(tester);

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));

          // assert during animation
          expect(isLargeLabelVisible(tester, 'Item 1'), isTrue);
          expect(isSmallLabelVisible(tester, 'Item 1'), isTrue);

          await tester.pumpAndSettle();

          // assert collapsed only
          expect(isLargeLabelVisible(tester, 'Item 1'), isFalse);
          expect(isSmallLabelVisible(tester, 'Item 1'), isTrue);
        },
      );
    },
  );
}
