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

enum Difficulty { grade1, grade2, grade3, grade4, grade5 }

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
  bool showSummary = false;

  Difficulty? selectedDifficulty;
  int timer = 10;
  late VoidCallback _timerCallback;

  @override
  void initState() {
    super.initState();
    _timerCallback = () {
      if (mounted && !answered && !showSummary && selectedDifficulty != null) {
        setState(() {
          timer--;
          if (timer <= 0) {
            answered = true;
            message = '⏰ Time\'s up!';
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
    };
  }

  void startTimer() {
    timer = 10;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || answered || showSummary || selectedDifficulty == null) return false;
      _timerCallback();
      return timer > 0 && !answered && !showSummary;
    });
  }

  void generateQuestion() {
    Random rand = Random();
    int maxNum = 10;
    switch (selectedDifficulty) {
      case Difficulty.grade1:
        maxNum = 10;
        break;
      case Difficulty.grade2:
        maxNum = 50;
        break;
      case Difficulty.grade3:
        maxNum = 200;
        break;
      case Difficulty.grade4:
        maxNum = 1000;
        break;
      case Difficulty.grade5:
        maxNum = 9999;
        break;
      default:
        maxNum = 10;
    }
    num1 = rand.nextInt(maxNum) + 1;
    num2 = rand.nextInt(maxNum) + 1;
    correctAnswer = num1 + num2;

    // Generate 4 tricky options close to the correct answer
    options = [correctAnswer];
    Set<int> usedLastDigits = {correctAnswer % 10};
    while (options.length < 4) {
      int offset = rand.nextInt(6) + 1; // 1 to 6 away
      int sign = rand.nextBool() ? 1 : -1;
      int wrong = correctAnswer + (offset * sign);

      // Try to make last digit same as correct answer for extra trickiness
      if (rand.nextBool()) {
        int lastDigit = correctAnswer % 10;
        int base = (wrong ~/ 10) * 10;
        wrong = base + lastDigit;
        // If that makes it equal to correctAnswer, adjust by +/- 10
        if (wrong == correctAnswer) {
          wrong += rand.nextBool() ? 10 : -10;
        }
      }

      // Ensure wrong answer is in valid range and not duplicate
      if (wrong > 0 && wrong <= maxNum * 2 && !options.contains(wrong)) {
        options.add(wrong);
        usedLastDigits.add(wrong % 10);
      }
    }
    options.shuffle();
    message = '';
    messageColor = Colors.green;
    answered = false;
    startTimer();
  }

  void checkAnswer(int selected) {
    if (answered) return;
    setState(() {
      answered = true;
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
      message = '';
      answered = false;
      generateQuestion();
    });
  }

  void backToMenu() {
    setState(() {
      selectedDifficulty = null;
      showSummary = false;
      questionCount = 0;
      score = 0;
      message = '';
      answered = false;
    });
  }

  void exitGame() {
    Navigator.of(context).maybePop();
  }

  Widget difficultySelector() {
    return Center(
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
              'Select Difficulty Level',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedDifficulty = Difficulty.grade1;
                  generateQuestion();
                });
              },
              child: const Text('Grade 1 (1-10)'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedDifficulty = Difficulty.grade2;
                  generateQuestion();
                });
              },
              child: const Text('Grade 2 (1-50)'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedDifficulty = Difficulty.grade3;
                  generateQuestion();
                });
              },
              child: const Text('Grade 3 (1-200)'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedDifficulty = Difficulty.grade4;
                  generateQuestion();
                });
              },
              child: const Text('Grade 4 (1-1000)'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedDifficulty = Difficulty.grade5;
                  generateQuestion();
                });
              },
              child: const Text('Grade 5 (1-9999)'),
            ),
          ],
        ),
      ),
    );
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
          if (selectedDifficulty == null)
            difficultySelector()
          else if (showSummary)
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
                        'Restart',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: backToMenu,
                      child: const Text(
                        'Back to Menu',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SafeArea(
              child: Column(
                children: [
                  Expanded(
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
                                  const SizedBox(height: 10),
                                  Text(
                                    'Time left: $timer s',
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: timer <= 3 ? Colors.red : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
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
                                  ),
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
                  // Buttons at the bottom
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: restartGame,
                          child: const Text('Restart'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: backToMenu,
                          child: const Text('Back to Menu'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: exitGame,
                          child: const Text('Exit'),
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