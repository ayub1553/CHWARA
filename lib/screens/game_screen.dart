// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unnecessary_underscores

import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math';
import '../models/game_models.dart';
import '../services/storage_service.dart';

class GameScreen extends StatefulWidget {
  final int gridSize;
  final String p1Name, p2Name;
  final bool isVsAi;
  const GameScreen({
    super.key,
    required this.gridSize,
    required this.p1Name,
    required this.p2Name,
    this.isVsAi = false,
  });
  @override
  State<GameScreen> createState() => _GameScreenState();
}

String toKurdishNumbers(int number) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const kurdish = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  String input = number.toString();
  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], kurdish[i]);
  }
  return input;
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  List<Line> lines = [];
  List<Box> boxes = [];
  int p1Score = 0, p2Score = 0;
  bool isP1Turn = true;
  bool gameEnded = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      lines = [];
      boxes = [];
      p1Score = 0;
      p2Score = 0;
      gameEnded = false;
      isP1Turn = Random().nextBool();
      for (int i = 0; i < widget.gridSize - 1; i++) {
        for (int j = 0; j < widget.gridSize - 1; j++) {
          boxes.add(
            Box(
              i,
              j,
              AnimationController(
                vsync: this,
                duration: const Duration(milliseconds: 300),
              ),
            ),
          );
        }
      }
    });
    if (!isP1Turn && widget.isVsAi) {
      _triggerAiMove();
    }
  }

  void _addLine(int r1, int c1, int r2, int c2) {
    if (lines.any(
      (l) => l.r1 == r1 && l.c1 == c1 && l.r2 == r2 && l.c2 == c2,
    )) {
      return;
    }

    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final newLine = Line(
      r1,
      c1,
      r2,
      c2,
      isP1Turn ? Colors.blue : Colors.red,
      ctrl,
    );

    setState(() {
      lines.add(newLine);
      ctrl.forward();
      bool boxFilled = false;

      for (var box in boxes) {
        if (box.owner == null && box.checkComplete(lines)) {
          box.owner = isP1Turn ? 1 : 2;
          box.controller.forward();
          isP1Turn ? p1Score++ : p2Score++;
          boxFilled = true;
        }
      }

      if (!boxFilled) {
        isP1Turn = !isP1Turn;

        if (!isP1Turn && widget.isVsAi && !gameEnded) {
          Future.delayed(const Duration(milliseconds: 500), _triggerAiMove);
        }
      } else {
        if (!isP1Turn && widget.isVsAi && !gameEnded) {
          Future.delayed(const Duration(milliseconds: 500), _triggerAiMove);
        }
      }

      _checkWinner();
    });
  }

 void _triggerAiMove() {
    if (gameEnded) return;

    // Fix: Added 'this' as the second argument
    final ai = DotsAI(widget.gridSize, this); 
    final move = ai.getBestMove(lines, boxes);

    if (move != null) {
      // Mean AI "thinks" faster when it's about to crush you
      int thinkingTime = 400 + Random().nextInt(400);

      Future.delayed(Duration(milliseconds: thinkingTime), () {
        if (mounted) _addLine(move.r1, move.c1, move.r2, move.c2);
      });
    }
  }
  Future<void> _checkWinner() async {
    if (boxes.every((b) => b.owner != null) && !gameEnded) {
      gameEnded = true;

      int diff = (p1Score - p2Score).abs();

      String kP1Score = toKurdishNumbers(p1Score);
      String kP2Score = toKurdishNumbers(p2Score);
      String kDiff = toKurdishNumbers(diff);

      String result = p1Score == p2Score
          ? "یەکسانن!"
          : (p1Score > p2Score
                ? "${widget.p1Name} بردیەوە !"
                : "${widget.p2Name} بردیەوە !");

      String diffText = p1Score == p2Score
          ? "بە تەواوی یەکسانن"
          : "بردنەوە بە جیاوازی $kDiff خاڵ";

      final String matchData =
          "$result|${widget.p1Name} ⚔️ ${widget.p2Name}|${widget.gridSize}|${DateTime.now().toString()}";
      await StorageService.saveMatch(matchData, widget.gridSize);
      await StorageService.updateStats(
        widget.p1Name,
        p1Score > p2Score,
        p1Score,
      );
      await StorageService.updateStats(
        widget.p2Name,
        p2Score > p1Score,
        p2Score,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.amber,
              size: 60,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  result,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "$kP1Score - $kP2Score",
                  style: const TextStyle(
                    fontSize: 26,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    diffText,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16, 
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(c);
                  Navigator.pop(context);
                },
                child: const Text(
                  "پەڕەی سەرەکی",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(c);
                  _resetGame();
                },
                child: const Text(
                  "دوبارە کردنەوە",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  void _handleTap(Offset pos, double bSize) {
    if (widget.isVsAi && !isP1Turn) return;
    double sp = bSize / (widget.gridSize - 1);
    for (int i = 0; i < widget.gridSize; i++) {
      for (int j = 0; j < widget.gridSize; j++) {
        if (j < widget.gridSize - 1) {
          if (Rect.fromLTRB(
            j * sp + 10,
            i * sp - 30,
            (j + 1) * sp - 10,
            i * sp + 30,
          ).contains(pos)) {
            _addLine(i, j, i, j + 1);
          }
        }
        if (i < widget.gridSize - 1) {
          if (Rect.fromLTRB(
            j * sp - 30,
            i * sp + 10,
            j * sp + 30,
            (i + 1) * sp - 10,
          ).contains(pos)) {
            _addLine(i, j, i + 1, j);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double bSize = MediaQuery.of(context).size.width - 80;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: (isP1Turn ? Colors.blue.shade900 : Colors.red.shade900)
                    .withOpacity(0.85),
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            _buildProfessionalPlayer(
              name: widget.p1Name,
              score: p1Score,
              isActive: isP1Turn,
              alignment: CrossAxisAlignment.start,
            ),
            Container(
              height: 30,
              width: 1,
              color: Colors.white24,
              margin: const EdgeInsets.symmetric(horizontal: 10),
            ),
            _buildProfessionalPlayer(
              name: widget.p2Name,
              score: p2Score,
              isActive: !isP1Turn,
              alignment: CrossAxisAlignment.end,
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(12),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Stack(
              children: [
                Container(
                  height: 4,
                  width: double.infinity,
                  color: Colors.white10,
                ),
               
                AnimatedAlign(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  alignment: isP1Turn
                      ? AlignmentDirectional.centerStart
                      : AlignmentDirectional.centerEnd,
                  child: Container(
                    height: 4,
                    width: MediaQuery.of(context).size.width * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: GestureDetector(
          onTapDown: (d) => _handleTap(d.localPosition, bSize),
          child: SizedBox(
            
            width: bSize,
            height: bSize,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                ...lines.map((e) => e.controller),
                ...boxes.map((e) => e.controller),
              ]),
              builder: (c, _) => CustomPaint(
                painter: GamePainter(lines, boxes, widget.gridSize),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: 75,
              decoration: BoxDecoration(
                color: (isP1Turn ? Colors.blue.shade900 : Colors.red.shade900)
                    .withOpacity(0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10, width: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    index: 0,
                    icon: Icons.home_rounded,
                    label: "سەرەکی",
                    onTap: () async {
                      bool confirm = await _showConfirm(
                        context,
                        title: "گەڕانەوە؟",
                        content: "دڵنیای دەتەوێت بگەڕێیتەوە بۆ پەڕەی سەرەکی؟",
                        icon: Icons.home_rounded,
                        color: Colors.blueAccent,
                      );
                      if (confirm) Navigator.pop(context);
                    },
                  ),
                  Container(height: 25, width: 1, color: Colors.white10),
                  _buildNavItem(
                    index: 1,
                    icon: Icons.refresh_rounded,
                    label: "نوێکردنەوە",
                    onTap: () async {
                      bool confirm = await _showConfirm(
                        context,
                        title: "دڵنیای؟",
                        content: "ئایا دەتەوێت یاریەکە نوێ بکەیتەوە؟",
                        icon: Icons.refresh_rounded,
                        color: Colors.redAccent,
                      );
                      if (confirm) _resetGame();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildNavItem({
  required int index,
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildProfessionalPlayer({
  required String name,
  required int score,
  required bool isActive,
  required CrossAxisAlignment alignment,
}) {
  return Expanded(
    child: Column(
      crossAxisAlignment: alignment,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 25,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w400,
            color: isActive ? Colors.white : Colors.white60,
            letterSpacing: 0.5,
          ),
          child: Text(name, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withOpacity(0.25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "${toKurdishNumbers(score)} خاڵ",
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.white38,
            ),
          ),
        ),
      ],
    ),
  );
}

Future<bool> _showConfirm(
  BuildContext context, {
  required String title,
  required String content,
  required IconData icon,
  required Color color,
}) async {
  return await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const SizedBox(),
        transitionBuilder: (ctx, anim1, anim2, child) {
          return FadeTransition(
            opacity: anim1,
            child: ScaleTransition(
              scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 40),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        content,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(
                                "نەخێر",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                "بەڵێ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ) ??
      false;
}

class GamePainter extends CustomPainter {
  final List<Line> lines;
  final List<Box> boxes;
  final int gridSize;
  GamePainter(this.lines, this.boxes, this.gridSize);

  @override
  void paint(Canvas canvas, Size size) {
    double sp = size.width / (gridSize - 1);
    double thickness = gridSize > 6 ? 10 : 16;
    double dotRadius = thickness * 0.9;

    final ghost = Paint()
      ..color = Colors.grey.withAlpha(40)
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (j < gridSize - 1) {
          canvas.drawLine(
            Offset(j * sp, i * sp),
            Offset((j + 1) * sp, i * sp),
            ghost,
          );
        }
        if (i < gridSize - 1) {
          canvas.drawLine(
            Offset(j * sp, i * sp),
            Offset(j * sp, (i + 1) * sp),
            ghost,
          );
        }
      }
    }

    for (var box in boxes) {
      if (box.owner != null) {
        final double anim = box.controller.value;
        final color = box.owner == 1 ? Colors.blue : Colors.red;
        canvas.save();
        canvas.clipRect(Rect.fromLTWH(box.c * sp, box.r * sp, sp, sp));
        canvas.drawCircle(
          Offset(box.c * sp + sp / 2, box.r * sp + sp / 2),
          sp * 0.8 * anim,
          Paint()..color = color.withAlpha((100 * anim).toInt()),
        );
        if (anim > 0.5) {
          final tp = TextPainter(
            text: TextSpan(
              text: box.owner == 1 ? "١" : "٢",
              style: TextStyle(
                color: color.withOpacity(anim),
                fontSize: sp * 0.3 * anim,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: ui.TextDirection.ltr,
          )..layout();
          tp.paint(
            canvas,
            Offset(
              box.c * sp + sp / 2 - tp.width / 2,
              box.r * sp + sp / 2 - tp.height / 2,
            ),
          );
        }
        canvas.restore();
      }
    }

    for (var line in lines) {
      final double anim = line.controller.value;
      final Offset p1 = Offset(line.c1 * sp, line.r1 * sp);
      final Offset p2 = Offset(line.c2 * sp, line.r2 * sp);
      final Offset mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      canvas.drawLine(
        Offset.lerp(mid, p1, anim)!,
        Offset.lerp(mid, p2, anim)!,
        Paint()
          ..color = line.color
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.round,
      );
    }

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        canvas.drawCircle(
          Offset(j * sp, i * sp),
          dotRadius,
          Paint()..color = Colors.black,
        );
        canvas.drawCircle(
          Offset(j * sp, i * sp),
          dotRadius * 0.75,
          Paint()..color = Colors.white,
        );
      }
    }
  }

  @override
  bool shouldRepaint(GamePainter old) => true;
}
