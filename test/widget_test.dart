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

  testWidgets('Four answer buttons are shown', (WidgetTester tester) async {
    await tester.pumpWidget(const AdditionGame());
    // There should be 4 ElevatedButtons for the options
    expect(find.byType(ElevatedButton), findsNWidgets(4));
  });

  testWidgets('Correct answer shows success message', (WidgetTester tester) async {
    await tester.pumpWidget(const AdditionGame());

    final questionFinder = find.textContaining('What is');
    expect(questionFinder, findsOneWidget);

    final questionText = tester.widget<Text>(questionFinder).data!;
    final regex = RegExp(r'What is (\d+) \+ (\d+) \?');
    final match = regex.firstMatch(questionText);
    expect(match, isNotNull);

    final num1 = int.parse(match!.group(1)!);
    final num2 = int.parse(match.group(2)!);
    final correctAnswer = num1 + num2;

    await tester.tap(find.widgetWithText(ElevatedButton, '$correctAnswer'));
    await tester.pump();

    expect(find.text('✅ Correct!'), findsOneWidget);
  });

  testWidgets('Wrong answer shows error message', (WidgetTester tester) async {
    await tester.pumpWidget(const AdditionGame());

    final questionFinder = find.textContaining('What is');
    expect(questionFinder, findsOneWidget);

    final questionText = tester.widget<Text>(questionFinder).data!;
    final regex = RegExp(r'What is (\d+) \+ (\d+) \?');
    final match = regex.firstMatch(questionText);
    expect(match, isNotNull);

    final num1 = int.parse(match!.group(1)!);
    final num2 = int.parse(match.group(2)!);
    final correctAnswer = num1 + num2;

    final optionButtons = tester.widgetList<ElevatedButton>(find.byType(ElevatedButton));
    for (final button in optionButtons) {
      final buttonText = (button.child as Text).data!;
      if (buttonText != '$correctAnswer') {
        await tester.tap(find.widgetWithText(ElevatedButton, buttonText));
        await tester.pump();
        expect(find.text('❌ Incorrect!'), findsOneWidget);
        break;
      }
    }
  });
}