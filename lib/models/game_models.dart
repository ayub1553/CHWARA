import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Move {
  final int r1, c1, r2, c2;
  Move(this.r1, this.c1, this.r2, this.c2);
}

class Line {
  final int r1, c1, r2, c2;
  final Color color;
  final AnimationController controller;
  Line(this.r1, this.c1, this.r2, this.c2, this.color, this.controller);
}

class Box {
  final int r, c;
  final AnimationController controller;
  int? owner;
  Box(this.r, this.c, this.controller);

  bool checkComplete(List<Line> lines) {
    bool has(int r1, int c1, int r2, int c2) =>
        lines.any((l) => (l.r1 == r1 && l.c1 == c1 && l.r2 == r2 && l.c2 == c2) ||
                         (l.r1 == r2 && l.c1 == c2 && l.r2 == r1 && l.c2 == c1));
    return has(r, c, r, c + 1) &&
        has(r + 1, c, r + 1, c + 1) &&
        has(r, c, r + 1, c) &&
        has(r, c + 1, r + 1, c + 1);
  }
}

class DotsAI {
  final int gridSize;
  final TickerProvider vsync;
  final Random _random = Random();

  DotsAI(this.gridSize, this.vsync);

  Line? getBestMove(List<Line> currentLines, List<Box> boxes) {
    List<Move> allPossible = _getAllPossibleMoves(currentLines);
    if (allPossible.isEmpty) return null;

    // 1. PRIORITY: CAPTURE (With a "Double-Cross" twist)
    List<Move> captures = allPossible.where((m) => _completesAnyBox(m, currentLines, boxes)).toList();
    if (captures.isNotEmpty) {
      // If there's a long chain (3+ boxes), and we are at the last 2 boxes, 
      // a 'God-Tier' AI might leave them for you to keep control. 
      // For now, let's take all points with high efficiency.
      return _toLine(captures[_random.nextInt(captures.length)]);
    }

    // 2. PRIORITY: THE OPENING (Avoid repetition)
    // If board is < 20% full, pick a random edge move that doesn't create a threat
    if (currentLines.length < (gridSize * gridSize * 0.25)) {
      List<Move> openings = allPossible.where((m) {
        bool isEdge = m.r1 == 0 || m.r1 == gridSize - 1 || m.c1 == 0 || m.c1 == gridSize - 1;
        // Don't put a second line in a box if we can help it
        return isEdge && _getAffectedBoxes(m, boxes).every((b) => _countSides(b, currentLines) == 0);
      }).toList();
      
      if (openings.isNotEmpty) {
        return _toLine(openings[_random.nextInt(openings.length)]);
      }
    }

    // 3. PRIORITY: SAFE MOVES (No gift boxes)
    // A move is safe if it doesn't leave any box with 3 sides.
    List<Move> safeMoves = allPossible.where((m) {
      return _getAffectedBoxes(m, boxes).every((box) => _countSides(box, currentLines) < 2);
    }).toList();

    if (safeMoves.isNotEmpty) {
      // SHUFFLE ensures the AI doesn't play the same way every time
      safeMoves.shuffle();
      // Prefer moves that don't even create a 2nd side
      List<Move> superSafe = safeMoves.where((m) => 
        _getAffectedBoxes(m, boxes).every((box) => _countSides(box, currentLines) == 0)
      ).toList();
      
      return _toLine(superSafe.isNotEmpty ? superSafe[0] : safeMoves[0]);
    }

    // 4. PRIORITY: SACRIFICE MINIMIZATION (The Brain)
    // If forced to give points, simulate the "Chain" to see which mistake is smallest.
    allPossible.sort((a, b) {
      int lossA = _calculateChainLoss(a, currentLines, boxes);
      int lossB = _calculateChainLoss(b, currentLines, boxes);
      // If losses are equal, pick a random one
      if (lossA == lossB) return _random.nextBool() ? -1 : 1;
      return lossA.compareTo(lossB);
    });

    return _toLine(allPossible.first);
  }

  // --- AI SIMULATOR ENGINE ---

  int _calculateChainLoss(Move m, List<Line> currentLines, List<Box> boxes) {
    List<Line> simLines = List.from(currentLines);
    simLines.add(_toLine(m));
    int score = 0;
    bool found;
    
    // DFS Simulation: How many boxes can the opponent take after this move?
    do {
      found = false;
      for (var box in boxes) {
        if (_countSides(box, simLines) == 3) {
          _simulateBoxCompletion(box, simLines);
          score++;
          found = true;
          break; // Opponent takes box and gets another move
        }
      }
    } while (found);
    return score;
  }

  void _simulateBoxCompletion(Box b, List<Line> lines) {
    if (!_exists(b.r, b.c, b.r, b.c + 1, lines)) lines.add(_toLine(Move(b.r, b.c, b.r, b.c + 1)));
    else if (!_exists(b.r + 1, b.c, b.r + 1, b.c + 1, lines)) lines.add(_toLine(Move(b.r + 1, b.c, b.r + 1, b.c + 1)));
    else if (!_exists(b.r, b.c, b.r + 1, b.c, lines)) lines.add(_toLine(Move(b.r, b.c, b.r + 1, b.c)));
    else if (!_exists(b.r, b.c + 1, b.r + 1, b.c + 1, lines)) lines.add(_toLine(Move(b.r, b.c + 1, b.r + 1, b.c + 1)));
  }

  // --- UTILITIES ---

  List<Move> _getAllPossibleMoves(List<Line> lines) {
    List<Move> moves = [];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (j < gridSize - 1 && !_exists(i, j, i, j + 1, lines)) moves.add(Move(i, j, i, j + 1));
        if (i < gridSize - 1 && !_exists(i, j, i + 1, j, lines)) moves.add(Move(i, j, i + 1, j));
      }
    }
    return moves;
  }

  bool _exists(int r1, int c1, int r2, int c2, List<Line> lines) =>
      lines.any((l) => (l.r1 == r1 && l.c1 == c1 && l.r2 == r2 && l.c2 == c2) ||
                       (l.r1 == r2 && l.c1 == c2 && l.r2 == r1 && l.c2 == c1));

  int _countSides(Box box, List<Line> lines) {
    int s = 0;
    if (_exists(box.r, box.c, box.r, box.c + 1, lines)) s++;
    if (_exists(box.r + 1, box.c, box.r + 1, box.c + 1, lines)) s++;
    if (_exists(box.r, box.c, box.r + 1, box.c, lines)) s++;
    if (_exists(box.r, box.c + 1, box.r + 1, box.c + 1, lines)) s++;
    return s;
  }

  bool _completesAnyBox(Move m, List<Line> lines, List<Box> boxes) =>
      _getAffectedBoxes(m, boxes).any((box) => _countSides(box, lines) == 3);

  List<Box> _getAffectedBoxes(Move m, List<Box> boxes) => boxes.where((b) {
        if (m.r1 == m.r2) return (b.r == m.r1 || b.r == m.r1 - 1) && b.c == m.c1;
        return b.r == m.r1 && (b.c == m.c1 || b.c == m.c1 - 1);
      }).toList();

  Line _toLine(Move m) => Line(m.r1, m.c1, m.r2, m.c2, Colors.red,
      AnimationController(vsync: vsync, duration: Duration.zero));
}

// Ensure you have a TestVSync or proper ticker provider for the AnimationControllers
class TestVSync implements TickerProvider {
  const TestVSync();
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}