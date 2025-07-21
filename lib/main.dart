import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const AdditionGame());
}

class AdditionGame extends StatelessWidget {
  const AdditionGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Addition Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int num1 = 0;
  int num2 = 0;
  int correctAnswer = 0;
  List<int> options = [];

  String message = '';
  Color messageColor = Colors.green;
  bool answered = false;

  int questionCount = 0;
  int score = 0;
  int attempts = 0;
  bool showSummary = false;

  @override
  void initState() {
    super.initState();
    generateQuestion();
  }

  void generateQuestion() {
    Random rand = Random();
    num1 = rand.nextInt(10);
    num2 = rand.nextInt(10);
    correctAnswer = num1 + num2;

    options = [correctAnswer];
    while (options.length < 3) {
      int wrong = rand.nextInt(20);
      if (!options.contains(wrong)) {
        options.add(wrong);
      }
    }
    options.shuffle();
    message = '';
    messageColor = Colors.green;
    answered = false;
    attempts = 0;
  }

  void checkAnswer(int selected) {
    if (answered) return;
    setState(() {
      answered = true;
      attempts++;
      if (selected == correctAnswer) {
        message = '✅ Correct!';
        messageColor = Colors.green;
        score++;
        questionCount++;
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            if (questionCount >= 10) {
              setState(() {
                showSummary = true;
              });
            } else {
              setState(() {
                generateQuestion();
              });
            }
          }
        });
      } else {
        message = '❌ Incorrect!';
        messageColor = Colors.red;
        questionCount++;
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            if (questionCount >= 10) {
              setState(() {
                showSummary = true;
              });
            } else {
              setState(() {
                generateQuestion();
              });
            }
          }
        });
      }
    });
  }

  void restartGame() {
    setState(() {
      score = 0;
      questionCount = 0;
      showSummary = false;
      generateQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Addition Game',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 4, color: Colors.black45, offset: Offset(2, 2))
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background.jpg',
            fit: BoxFit.cover,
          ),
          if (showSummary)
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Game Over!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'You answered $score out of 10 correctly!',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: restartGame,
                      child: const Text(
                        'Play Again',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'What is $num1 + $num2 ?',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                      blurRadius: 4,
                                      color: Colors.black45,
                                      offset: Offset(2, 2))
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            for (var option in options)
                              ElevatedButton(
                                onPressed: answered ? null : () => checkAnswer(option),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 15),
                                ),
                                child: Text(
                                  '$option',
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            const SizedBox(height: 30),
                            Text(
                              message,
                              style: TextStyle(
                                fontSize: 24,
                                color: messageColor,
                                fontWeight: FontWeight.bold,
                                shadows: const [
                                  Shadow(
                                      blurRadius: 4,
                                      color: Colors.black45,
                                      offset: Offset(2, 2))
                                ],
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Scoreboard on the right
                  Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 10, top: 30, bottom: 30),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          'Score',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$score / $questionCount',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Q#',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          '${questionCount + (answered ? 0 : 1)} / 10',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}