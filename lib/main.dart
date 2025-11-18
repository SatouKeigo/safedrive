import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const DriveCheckApp());

/// アプリ状態
class AppState extends ChangeNotifier {
  bool mph = false;
  final List<HistoryItem> history = [];

  void toggleUnit(bool useMph) {
    mph = useMph;
    notifyListeners();
  }

  void addHistory(HistoryItem h) {
    history.insert(0, h);
    notifyListeners();
  }
}

class HistoryItem {
  final DateTime date;
  final double maxG;
  final double minG;
  final int score;
  HistoryItem(this.date, this.maxG, this.minG, this.score);
}

/// InheritedNotifier ラッパー
class AppProvider extends InheritedNotifier<AppState> {
  const AppProvider({
    super.key,
    required AppState notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppProvider>()!.notifier!;
}

/// カラーとテキストの共通定義
class AppColors {
  static const bgTop = Color(0xFF0B0F1D);
  static const bgBottom = Color(0xFF1A213B);
  static const accent = Color(0xFFFF6A00);
  static const start = Color(0xFF2ECC71);
}

class AppText {
  static const title = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );
  static const label = TextStyle(
    color: Colors.white70,
    fontSize: 14,
    letterSpacing: 0.3,
  );
  static const numberLarge = TextStyle(
    color: Colors.white,
    fontSize: 32,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.2,
  );
  static const numberMid = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );
}

class DriveCheckApp extends StatefulWidget {
  const DriveCheckApp({super.key});
  @override
  State<DriveCheckApp> createState() => _DriveCheckAppState();
}

class _DriveCheckAppState extends State<DriveCheckApp> {
  final AppState state = AppState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DriveCheck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: AppColors.bgTop,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      // アプリ全体に状態を差し込む
      builder: (context, child) => AppProvider(notifier: state, child: child!),

      // 初期画面は HomePage
      home: const HomePage(),

      routes: {
        '/check': (_) => const CheckPage(),
        '/result': (_) => const ResultPage(),
        '/history': (_) => const HistoryPage(),
        '/settings': (_) => const SettingsPage(),
      },
    );
  }
}

/// 共通UI
class GradientScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? bottom;
  const GradientScaffold({
    super.key,
    required this.title,
    required this.children,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgTop, AppColors.bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) {
              final h = c.maxHeight;
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: h * 0.015,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: AppText.title),
                    SizedBox(height: h * 0.012),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(children: children),
                      ),
                    ),
                    if (bottom != null) ...[
                      SizedBox(height: h * 0.02),
                      bottom!,
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AccentButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final bool wide;
  final IconData? icon;
  const AccentButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.accent,
    this.wide = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
        ],
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: wide ? 140 : 0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 6,
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

/// Home（STARTボタンアニメ付き）
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final state = AppProvider.of(context);
    return GradientScaffold(
      title: 'DriveCheck',
      children: [
        const SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTapDown: (_) => setState(() => scale = 0.96),
            onTapCancel: () => setState(() => scale = 1.0),
            onTapUp: (_) {
              setState(() => scale = 1.0);
              Navigator.pushNamed(context, '/check');
            },
            child: AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 90),
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black54, blurRadius: 24, spreadRadius: 2),
                  ],
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFF3BE07A),
                      AppColors.start,
                    ],
                    center: Alignment(-0.2, -0.2),
                    radius: 0.9,
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'START',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          state.history.isNotEmpty
              ? '前回スコア: ${state.history.first.score}点'
              : '前回スコアなし',
          textAlign: TextAlign.center,
          style: AppText.label,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AccentButton(
              text: '履歴',
              onPressed: () => Navigator.pushNamed(context, '/history'),
              wide: true,
              icon: Icons.history,
            ),
            AccentButton(
              text: '設定',
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              wide: true,
              icon: Icons.settings,
            ),
          ],
        ),
      ],
    );
  }
}

/// Check（レーダー付き）
class CheckPage extends StatefulWidget {
  const CheckPage({super.key});
  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  Timer? timer;
  Duration elapsed = Duration.zero;
  double speed = 0;
  double maxG = 0, minG = 0;
  final rand = Random();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {
        elapsed += const Duration(milliseconds: 100);
        speed = 20 + 20 * sin(elapsed.inMilliseconds / 900);
        final g = (rand.nextDouble() * 2 - 1).abs() * 0.6;
        maxG = max(maxG, g);
        minG = minG == 0 ? g : min(minG, g);
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppProvider.of(context);
    final displaySpeed = state.mph ? speed * 0.621 : speed;
    final unit = state.mph ? 'mph' : 'km/h';

    return GradientScaffold(
      title: 'Check',
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: CustomPaint(
            painter: RadarPainter(
              progress: (elapsed.inMilliseconds % 2000) / 2000.0,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _formatTime(elapsed),
          style: AppText.numberLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '${displaySpeed.toStringAsFixed(1)} $unit',
          style: AppText.numberMid.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Center(
          child: AccentButton(
            text: 'STOP',
            onPressed: () {
              final score = max(0, 100 - (maxG * 60).round());
              state.addHistory(
                HistoryItem(DateTime.now(), maxG, minG, score),
              );
              Navigator.pushReplacementNamed(context, '/result');
            },
          ),
        ),
      ],
    );
  }
}

class RadarPainter extends CustomPainter {
  final double progress; // 0.0〜1.0

  RadarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = min(size.width, size.height) / 2 - 8;

    // 同心円
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white24
      ..strokeWidth = 2;
    for (var r = radius; r > 0; r -= radius / 4) {
      canvas.drawCircle(center, r, circlePaint);
    }

    // 十字ライン
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      circlePaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      circlePaint,
    );

    // スイープ線
    final sweepPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white60;
    final angle = progress * 2 * pi;
    final end = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );
    canvas.drawLine(center, end, sweepPaint);

    // 中央ドット
    final dotPaint = Paint()..color = AppColors.accent;
    canvas.drawCircle(center, 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Result（改良版）
class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppProvider.of(context);
    final last = state.history.isNotEmpty ? state.history.first : null;
    final score = (last?.score ?? 0).toDouble();

    return GradientScaffold(
      title: 'Result',
      children: [
        const SizedBox(height: 20),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 14,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    score > 80
                        ? Colors.greenAccent
                        : score > 50
                            ? Colors.orangeAccent
                            : Colors.redAccent,
                  ),
                ),
              ),
              Text(
                '${score.toInt()}点',
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        _dataCard('最大G', last?.maxG ?? 0),
        _dataCard('最小G', last?.minG ?? 0),
        const SizedBox(height: 30),
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child:
              const Text('マップ（後で追加）', style: TextStyle(color: Colors.white60)),
        ),
      ],
      bottom: AccentButton(
        text: 'HOME',
        onPressed: () =>
            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
      ),
    );
  }

  Widget _dataCard(String label, double value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Text('${value.toStringAsFixed(2)} G',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// History
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppProvider.of(context);
    return GradientScaffold(
      title: '履歴',
      children: [
        if (state.history.isEmpty)
          const Text('履歴なし', style: TextStyle(color: Colors.white54))
        else
          ...state.history.map((h) => ListTile(
                title: Text(_dateStr(h.date),
                    style: const TextStyle(color: Colors.white)),
                trailing: Text('${h.score}点',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              )),
      ],
      bottom: AccentButton(
        text: 'HOME',
        onPressed: () =>
            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
      ),
    );
  }
}

/// Settings
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppProvider.of(context);
    return GradientScaffold(
      title: '設定',
      children: [
        const Text('速度単位', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('km/h')),
            ButtonSegment(value: true, label: Text('mph')),
          ],
          selected: {state.mph},
          onSelectionChanged: (s) => state.toggleUnit(s.first),
        ),
      ],
      bottom: AccentButton(
        text: 'HOME',
        onPressed: () =>
            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
      ),
    );
  }
}

String _formatTime(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}

String _dateStr(DateTime dt) =>
    '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
