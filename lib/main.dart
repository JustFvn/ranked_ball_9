import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const RankedBallGame());

class RankedBallGame extends StatelessWidget {
  const RankedBallGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ranked Ball Game',
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late SharedPreferences prefs;
  int score = 0;
  late AnimationController _ctrl; // 彈跳動畫控制器

  final ranks = [
    {'name': '木球', 'min': 0, 'max': 1000, 'color': Colors.brown},
    {'name': '石球', 'min': 1000, 'max': 5000, 'color': Colors.grey},
    {'name': '銅球', 'min': 5000, 'max': 10000, 'color': Colors.orange},
    {'name': '鐵球', 'min': 10000, 'max': 20000, 'color': Colors.blueGrey},
    {'name': '金球', 'min': 20000, 'max': 40000, 'color': Colors.amber},
    {'name': '綠寶球', 'min': 40000, 'max': 70000, 'color': Colors.green},
    {'name': '紫晶球', 'min': 70000, 'max': 100000, 'color': Colors.purple},
    {'name': '鑽球', 'min': 100000, 'max': 1 << 31, 'color': Colors.cyan},
  ];

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: .9,
      upperBound: 1.1,
    )..value = 1;
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() => score = prefs.getInt('score') ?? 0);
  }

  void _tap() {
    setState(() {
      score += 1;
      prefs.setInt('score', score);
      _ctrl.forward(from: .9);
    });
  }

  Map<String, dynamic> get cur =>
      ranks.lastWhere((r) => score >= r['min'] && score < r['max']);
  Map<String, dynamic>? get next {
    if (cur['name'] == '鑽球') return null;
    return ranks[ranks.indexOf(cur) + 1];
  }

  @override
  Widget build(BuildContext ctx) {
    final prog = next == null
        ? 1.0
        : (score - cur['min']) / (next!['min'] - cur['min']);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text('分數: $score', style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Stack(
                children: [
                  LinearProgressIndicator(
                    value: prog.clamp(0.0, 1.0),
                    minHeight: 26,
                    color: cur['color'],
                    backgroundColor: Colors.white12,
                  ),
                  Positioned(
                    left: 8,
                    top: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cur['name'], style: const TextStyle(fontSize: 13)),
                        Text('${cur['min']}',
                            style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                  if (next != null)
                    Positioned(
                      right: 8,
                      top: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(next!['name'],
                              style: const TextStyle(fontSize: 13)),
                          Text('${next!['min']}',
                              style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _tap,
              child: ScaleTransition(
                scale: _ctrl,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cur['color'],
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
