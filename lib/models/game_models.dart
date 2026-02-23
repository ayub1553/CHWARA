// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:math';

import 'package:chwara/main.dart';
import 'package:flutter/material.dart';

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
        lines.any((l) => l.r1 == r1 && l.c1 == c1 && l.r2 == r2 && l.c2 == c2);
    return has(r, c, r, c + 1) &&
        has(r + 1, c, r + 1, c + 1) &&
        has(r, c, r + 1, c) &&
        has(r, c + 1, r + 1, c + 1);
  }
}
class DotsAI {
  final int gridSize;
  DotsAI(this.gridSize);

  Line? getBestMove(List<Line> currentLines, List<Box> boxes) {
    List<Move> allPossible = [];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (j < gridSize - 1 && !_exists(i, j, i, j + 1, currentLines))
          allPossible.add(Move(i, j, i, j + 1));
        if (i < gridSize - 1 && !_exists(i, j, i + 1, j, currentLines))
          allPossible.add(Move(i, j, i + 1, j));
      }
    }

    if (allPossible.isEmpty) return null;


    for (var move in allPossible) {
      if (_completesAnyBox(move, currentLines, boxes)) {
        return _toLine(move);
      }
    }

    List<Move> safeMoves = allPossible.where((m) {
      return !_isDangerous(m, currentLines, boxes);
    }).toList();

    if (safeMoves.isNotEmpty) {
      return _toLine(safeMoves[Random().nextInt(safeMoves.length)]);
    }

    allPossible.sort(
      (a, b) => _countResultingThrees(
        a,
        currentLines,
        boxes,
      ).compareTo(_countResultingThrees(b, currentLines, boxes)),
    );

    return _toLine(allPossible.first);
  }


  bool _exists(int r1, int c1, int r2, int c2, List<Line> lines) =>
      lines.any((l) => l.r1 == r1 && l.c1 == c1 && l.r2 == r2 && l.c2 == c2);

  bool _completesAnyBox(Move m, List<Line> lines, List<Box> boxes) {
    return _getAffectedBoxes(
      m,
      boxes,
    ).any((box) => _countSides(box, lines) == 3);
  }

  bool _isDangerous(Move m, List<Line> lines, List<Box> boxes) {
    return _getAffectedBoxes(
      m,
      boxes,
    ).any((box) => _countSides(box, lines) == 2);
  }

  int _countResultingThrees(Move m, List<Line> lines, List<Box> boxes) {
    return _getAffectedBoxes(
      m,
      boxes,
    ).where((box) => _countSides(box, lines) == 2).length;
  }

  int _countSides(Box box, List<Line> lines) {
    int sides = 0;
    if (_exists(box.r, box.c, box.r, box.c + 1, lines)) sides++;
    if (_exists(box.r + 1, box.c, box.r + 1, box.c + 1, lines)) sides++;
    if (_exists(box.r, box.c, box.r + 1, box.c, lines)) sides++;
    if (_exists(box.r, box.c + 1, box.r + 1, box.c + 1, lines)) sides++;
    return sides;
  }

  List<Box> _getAffectedBoxes(Move m, List<Box> boxes) {
    return boxes.where((b) {
      if (m.r1 == m.r2) {
        return (b.r == m.r1 || b.r == m.r1 - 1) && b.c == m.c1;
      } else {
        return b.r == m.r1 && (b.c == m.c1 || b.c == m.c1 - 1);
      }
    }).toList();
  }

  Line _toLine(Move m) => Line(
    m.r1,
    m.c1,
    m.r2,
    m.c2,
    Colors.red,
    AnimationController(vsync: const TestVSync(), duration: Duration.zero),
  );
}
