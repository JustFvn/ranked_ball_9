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

/// 段位資料模型
class Rank {
  const Rank(this.name, this.min, this.max, this.color);

  final String name;
  final int min;
  final int max;
  final Color color;
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

  late AnimationController _animCtrl;

  /// 段位定義（最後一段上限給很大值）
  final List<Rank> ranks = const [
    Rank('木球', 0, 1000, Colors.brown),
    Rank('石球', 1000, 5000, Colors.grey),
    Rank('銅球', 5000, 10000, Colors.orange),
    Rank('鐵球', 10000, 20000, Colors.blueGrey),
    Rank('金球', 20000, 40000, Colors.amber),
    Rank('綠寶球', 40000, 70000, Colors.green),
    Rank('紫晶球', 70000, 100000, Colors.purple),
    Rank('鑽球', 100000, 1 << 31, Colors.cyan),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: .9,
      upperBound: 1.1,
    )..value = 1;

    _loadScore();
  }

  Future<void> _loadScore() async {
    prefs = await SharedPreferences.getInstance();
    setState(() => score = prefs.getInt('score') ?? 0);
  }

  void _tapBall() {
    setState(() {
      score += 1;
      prefs.setInt('score', score);
      _animCtrl.forward(from: .9);
    });
  }

  Rank get currentRank =>
      ranks.lastWhere((r) => score >= r.min && score < r.max);

  Rank? get nextRank {
    if (currentRank.name == '鑽球') return null;
    final idx = ranks.indexOf(currentRank);
    return ranks[idx + 1];
  }

  double get progress {
    if (nextRank == null) return 1.0;
    return (score - currentRank.min) /
        (nextRank!.min - currentRank.min);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text('分數: $score',
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Stack(
                children: [
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 26,
                    color: currentRank.color,
                    backgroundColor: Colors.white12,
                  ),
                  Positioned(
                    left: 8,
                    top: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentRank.name,
                            style: const TextStyle(fontSize: 13)),
                        Text('${currentRank.min}',
                            style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                  if (nextRank != null)
                    Positioned(
                      right: 8,
                      top: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(nextRank!.name,
                              style: const TextStyle(fontSize: 13)),
                          Text('${nextRank!.min}',
                              style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _tapBall,
              child: ScaleTransition(
                scale: _animCtrl,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentRank.color,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }
}
