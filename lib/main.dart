import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const AdditionGame());
}

class AdditionGame extends StatelessWidget {
  const AdditionGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tom & Jerry Math Game',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'ComicSans',
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cardWidth = w < 700 ? w * 0.92 : 600.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade300,
              Colors.purple.shade200,
              Colors.pink.shade200,
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: cardWidth,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
              border: Border.all(color: Colors.orange.shade700, width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tom & Jerry',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.yellow.shade700,
                        offset: const Offset(3, 3),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Math Addition Game',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: cardWidth * 0.7,
                    height: (cardWidth * 0.7) * 0.6,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange.shade400, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: Image.asset(
                        'assets/tom_jerry_welcome.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => const Center(child: Text('Image missing', style: TextStyle(fontSize: 16))),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue.shade300, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'How to Play:',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '• Answer 10 addition questions correctly\n'
                        '• You have 10-30 seconds depending on grade\n'
                        '• Choose your grade level to start\n'
                        '• Try to get a perfect score!',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade800,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const GameScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade500,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'NEXT',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum Difficulty { grade1, grade2, grade3, grade4, grade5 }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // don't auto-start; user selects grade via selector
  }

  int _getTimeLimitForDifficulty(Difficulty d) {
    switch (d) {
      case Difficulty.grade1:
        return 10;
      case Difficulty.grade2:
        return 15;
      case Difficulty.grade3:
        return 20;
      case Difficulty.grade4:
        return 25;
      case Difficulty.grade5:
        return 30;
    }
  }

  void startTimer() {
    _timer?.cancel();
    if (selectedDifficulty == null) return;
    setState(() {
      timer = _getTimeLimitForDifficulty(selectedDifficulty!);
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || answered || showSummary || selectedDifficulty == null) {
        t.cancel();
        return;
      }
      setState(() {
        timer--;
        if (timer <= 0) {
          answered = true;
          message = '⏰ Time\'s up!';
          messageColor = Colors.red;
          questionCount++;
          t.cancel();
          Future.delayed(const Duration(seconds: 1), () {
            if (!mounted) return;
            if (questionCount >= 10) {
              setState(() => showSummary = true);
            } else {
              setState(() => generateQuestion());
            }
          });
        }
      });
    });
  }

  void generateQuestion() {
    if (selectedDifficulty == null) return;
    Random rand = Random();
    int maxNum;
    switch (selectedDifficulty!) {
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
    }

    final newNum1 = rand.nextInt(maxNum) + 1;
    final newNum2 = rand.nextInt(maxNum) + 1;
    final newCorrect = newNum1 + newNum2;

    final newOptions = <int>[newCorrect];
    while (newOptions.length < 4) {
      int wrong = newCorrect + (rand.nextInt(6) + 1) * (rand.nextBool() ? 1 : -1);
      if (wrong > 0 && wrong != newCorrect && !newOptions.contains(wrong)) newOptions.add(wrong);
    }
    newOptions.shuffle();

    setState(() {
      num1 = newNum1;
      num2 = newNum2;
      correctAnswer = newCorrect;
      options = newOptions;
      message = '';
      messageColor = Colors.green;
      answered = false;
    });

    startTimer();
  }

  void checkAnswer(int selected) {
    if (answered) return;
    _timer?.cancel();
    setState(() {
      answered = true;
      if (selected == correctAnswer) {
        message = '✅ Correct!';
        messageColor = Colors.green;
        score++;
      } else {
        message = '❌ Incorrect!';
        messageColor = Colors.red;
      }
      questionCount++;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (questionCount >= 10) {
        setState(() => showSummary = true);
      } else {
        setState(() => generateQuestion());
      }
    });
  }

  void restartGame() {
    _timer?.cancel();
    setState(() {
      score = 0;
      questionCount = 0;
      showSummary = false;
      message = '';
      answered = false;
      selectedDifficulty = null;
    });
  }

  void backToMenu() {
    _timer?.cancel();
    setState(() {
      selectedDifficulty = null;
      showSummary = false;
      questionCount = 0;
      score = 0;
      message = '';
      answered = false;
    });
  }

  Future<void> exitGame() async {
    final uri = Uri.parse('https://hubertmucyo.github.io/gamify/');
    try {
      // Try to open externally; falls back to pop if it fails.
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Navigator.of(context).maybePop();
      }
    } catch (_) {
      Navigator.of(context).maybePop();
    }
  }

  Widget gradeCard(String grade, Difficulty difficulty, Color cardColor, Color accentColor, String imagePath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDifficulty = difficulty;
          generateQuestion();
        });
      },
      child: Container(
        width: 200,
        height: 240,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cardColor, cardColor.withAlpha((0.7 * 255).round())],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: accentColor, width: 3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: accentColor, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, st) => const Center(child: Text('Image', style: TextStyle(fontSize: 12))),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              grade,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Color.fromRGBO(0, 0, 0, 0.5),
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'TAP TO PLAY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget difficultySelector() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.orange.shade200,
            Colors.yellow.shade200,
            Colors.blue.shade200,
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.2),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Text(
                  '🎯 Choose Your Grade Level 🎯',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: [
                  gradeCard('Grade 1', Difficulty.grade1, Colors.green.shade400, Colors.green.shade800, 'assets/grade1.jpg'),
                  gradeCard('Grade 2', Difficulty.grade2, Colors.blue.shade400, Colors.blue.shade800, 'assets/grade2.jpg'),
                  gradeCard('Grade 3', Difficulty.grade3, Colors.purple.shade400, Colors.purple.shade800, 'assets/grade3.jpg'),
                  gradeCard('Grade 4', Difficulty.grade4, Colors.orange.shade400, Colors.orange.shade800, 'assets/grade4.jpg'),
                  gradeCard('Grade 5', Difficulty.grade5, Colors.red.shade400, Colors.red.shade800, 'assets/grade5.jpg'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade300,
                  Colors.purple.shade200,
                  Colors.pink.shade200,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                if (selectedDifficulty == null)
                  Expanded(child: difficultySelector())
                else if (showSummary)
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                            border: Border.all(color: Colors.orange.shade700, width: 3),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                score >= 8 ? '🎉 Awesome! 🎉' : score >= 5 ? '👍 Good Try!' : '💪 Keep Practicing!',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text('Score: $score / 10', style: const TextStyle(fontSize: 24)),
                              const SizedBox(height: 12),
                              ElevatedButton(onPressed: restartGame, child: const Text('Play Again')),
                              const SizedBox(height: 8),
                              ElevatedButton(onPressed: backToMenu, child: const Text('Back to Menu')),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                              margin: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha((0.95 * 255).round()),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.2),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                                border: Border.all(color: Colors.orange.shade400, width: 3),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'What is $num1 + $num2 ?',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: timer <= 3 ? Colors.red.shade100 : Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: timer <= 3 ? Colors.red : Colors.blue,
                                        width: 3,
                                      ),
                                    ),
                                    child: Text(
                                      '⏱️ Time: $timer s',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: timer <= 3 ? Colors.red.shade800 : Colors.blue.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...options.map((option) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: ElevatedButton(
                                          onPressed: answered ? null : () => checkAnswer(option),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange.shade400,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 48,
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            elevation: 5,
                                          ),
                                          child: Text(
                                            '$option',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )),
                                  const SizedBox(height: 12),
                                  if (message.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: messageColor.withAlpha((0.2 * 255).round()),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: messageColor, width: 2),
                                      ),
                                      child: Text(
                                        message,
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: messageColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Optional small scoreboard column can be added here if desired
                      ],
                    ),
                  ),
                SafeArea(
                  top: false,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
                    color: Colors.brown.shade900, // darker background for contrast
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: restartGame,
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text('Restart', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade900,
                            elevation: 6,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: backToMenu,
                          icon: const Icon(Icons.home, color: Colors.white),
                          label: const Text('Menu', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            elevation: 6,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: exitGame,
                          icon: const Icon(Icons.exit_to_app, color: Colors.white),
                          label: const Text('Exit', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade900,
                            elevation: 6,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
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