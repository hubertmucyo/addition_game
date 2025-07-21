// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:addition_game/main.dart';

void main() {
  testWidgets('App title is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const AdditionGame());

    expect(find.text('Addition Game'), findsOneWidget);
  });

  testWidgets('Question text is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const AdditionGame());

    expect(find.textContaining('What is'), findsOneWidget);
    // Should show a question like "What is X + Y ?"
  });

  testWidgets('Three answer buttons are shown', (WidgetTester tester) async {
    await tester.pumpWidget(const AdditionGame());

    // There should be 3 ElevatedButtons for the options
    expect(find.byType(ElevatedButton), findsNWidgets(3));
  });

  testWidgets('Correct answer shows success message', (WidgetTester tester) async {
    await tester.pumpWidget(const AdditionGame());

    // Find the question text and extract the numbers
    final questionFinder = find.textContaining('What is');
    expect(questionFinder, findsOneWidget);

    final questionText = tester.widget<Text>(questionFinder).data!;
    final regex = RegExp(r'What is (\d+) \+ (\d+) \?');
    final match = regex.firstMatch(questionText);
    expect(match, isNotNull);

    final num1 = int.parse(match!.group(1)!);
    final num2 = int.parse(match.group(2)!);
    final correctAnswer = num1 + num2;

    // Tap the correct answer button
    await tester.tap(find.widgetWithText(ElevatedButton, '$correctAnswer'));
    await tester.pump();

    expect(find.text('✅ Correct!'), findsOneWidget);
  });

  testWidgets('Wrong answer shows error message', (WidgetTester tester) async {
    await tester.pumpWidget(const AdditionGame());

    // Find the question text and extract the numbers
    final questionFinder = find.textContaining('What is');
    expect(questionFinder, findsOneWidget);

    final questionText = tester.widget<Text>(questionFinder).data!;
    final regex = RegExp(r'What is (\d+) \+ (\d+) \?');
    final match = regex.firstMatch(questionText);
    expect(match, isNotNull);

    final num1 = int.parse(match!.group(1)!);
    final num2 = int.parse(match.group(2)!);
    final correctAnswer = num1 + num2;

    // Find all option buttons
    final optionButtons = tester.widgetList<ElevatedButton>(find.byType(ElevatedButton));
    // Tap the first wrong answer
    for (final button in optionButtons) {
      final buttonText = (button.child as Text).data!;
      if (buttonText != '$correctAnswer') {
        await tester.tap(find.widgetWithText(ElevatedButton, buttonText));
        await tester.pump();
        expect(find.text('❌ Try Again!'), findsOneWidget);
        break;
      }
    }
  });
  }