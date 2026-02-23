// ignore_for_file: deprecated_member_use

import 'package:chwara/screens/about_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/storage_service.dart';
import 'game_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

String toKurdishNumbers(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const kurdish = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], kurdish[i]);
  }
  return input;
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _p1Controller = TextEditingController(
    text: "یاریزانی یەکەم",
  );
  final TextEditingController _p2Controller = TextEditingController(
    text: "یاریزانی دووەم",
  );

  bool isAiMode = false;
  int _selectedGridSize = 4;

  List<String> history = [];
  Map<String, dynamic> stats = {};
  bool showWinsView = true;
  static const primaryBlue = Color(0xFF2196F3);

  static const backgroundGrey = Color(0xFFF8F9FA);
  int _textIndex = 0;
  Timer? _timer;

  final List<String> _tips = [
    "خاڵەکان ببەستەوە و چوارەکەت داگیر بکە",
    "لێرەدا زیرەکی بڕیار دەدات نەک بەخت",
    "یەک هێڵ ، یەک خانە ، یەک براوە!",
    "خەتێک بۆ کێبڕکێ ، چوارەیەک بۆ بردنەوە",
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _textIndex = (_textIndex + 1) % _tips.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await StorageService.getData();
    setState(() {
      history = data['history'];
      stats = data['stats'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
  appBar: AppBar(
  elevation: 0,
  centerTitle: true,
  backgroundColor: Colors.transparent,
  foregroundColor: Colors.white,
  
  // Red to Blue Gradient
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFFFF416C), // Vibrant Red
          Color(0xFF396AFC), // Deep Blue
        ],
      ),
    ),
  ),

  title: const Text(
    "چوارە",
    style: TextStyle(
      fontWeight: FontWeight.w900,
      letterSpacing: 1.2,
      fontSize: 24,
    ),
  ),

  // Leaderboard Icon
  leading: Padding(
    padding: const EdgeInsets.only(left: 16.0),
    child: Builder(
      builder: (ctx) => IconButton(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        icon: const Icon(Icons.leaderboard),
        onPressed: () => Scaffold.of(ctx).openDrawer(),
      ),
    ),
  ),

  // Info Icon with Slide-from-LEFT Transition
  actions: [
    Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: IconButton(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        icon: const Icon(Icons.info_outline),
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (context, animation, secondaryAnimation) => const AboutScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // Offset(-1.0, 0.0) makes it start from the LEFT edge
                const begin = Offset(-1.0, 0.0); 
                const end = Offset.zero;
                const curve = Curves.easeOutCubic;

                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        },
      ),
    ),
  ],


),    drawer: _buildDrawer(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo_CHWARA.png',
                  width: 300,
                ),
              ),
             
              SizedBox(
                height: 40,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    _tips[_textIndex],
                    key: ValueKey<int>(_textIndex),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildInputCard(),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showGeneralDialog<bool>(
          context: context,
          barrierDismissible: true,
          barrierLabel: '',
          barrierColor: Colors.black54,
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (ctx, anim1, anim2) => const SizedBox(),
          transitionBuilder: (ctx, anim1, anim2, child) {
            final curve = CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutBack,
            );

            return FadeTransition(
              opacity: anim1,
              child: ScaleTransition(
                scale: curve,
                child: Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.redAccent,
                            size: 44,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          content,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(
                                  "نەخێر",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(
                                  "بەڵێ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: primaryBlue.withOpacity(0.7)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    var entries = stats.entries.toList();
    entries.sort(
      (a, b) => showWinsView
          ? b.value['wins'].compareTo(a.value['wins'])
          : b.value['points'].compareTo(a.value['points']),
    );
    return DefaultTabController(
      length: 2,
      child: Drawer(
        backgroundColor: Colors.grey[50],
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 50, bottom: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryBlue, Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "چالاکییەکان",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Builder(
                          builder: (tabCtx) {
                            return IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white24,
                              ),
                              icon: const Icon(
                                Icons.delete_sweep_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                int currentTab = DefaultTabController.of(
                                  tabCtx,
                                ).index;
                                bool confirm = await _showConfirmDialog(
                                  "ئایا دڵنیای؟",
                                  currentTab == 0
                                      ? "مێژووی یاریەکان بسڕیتەوە؟"
                                      : "ڕیزبەندیەکان بسڕیتەوە؟",
                                );
                                if (confirm) {
                                  if (currentTab == 0) {
                                    await StorageService.resetHistory();
                                  } else {
                                    await StorageService.resetStats();
                                  }
                                  if (mounted) {
                                    _loadData();
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      labelColor: primaryBlue,
                      unselectedLabelColor: Colors.white,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      tabs: [
                        Tab(text: "مێژوو"),
                        Tab(text: "ڕیزبەندی"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  history.isEmpty
                      ? _buildEmptyState("هیچ یاریەک نەکراوە")
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: history.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            List<String> parts = history[i].split('|');

                            if (parts.length < 4) {
                              return ListTile(
                                title: Text(toKurdishNumbers(history[i])),
                              );
                            }

                            String rawWinner = parts[0];
                            String cleanName = rawWinner
                                .replaceAll(RegExp(r'\[.*?\]'), '')
                                .replaceAll('بردیەوە', '')
                                .replaceAll('!', '')
                                .trim();

                            String playerNames = parts[1];
                            String gSize = parts[2];
                            String fullDateTime = parts[3];

                            List<String> dateTimeParts = fullDateTime.split(
                              ' ',
                            );
                            String dateOnly = dateTimeParts[0];
                            String timeOnly = dateTimeParts.length > 1
                                ? dateTimeParts[1].substring(0, 5)
                                : "";

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  dividerColor: Colors.transparent,
                                ),
                                child: ExpansionTile(
                                  leading: const Icon(
                                    Icons.history_rounded,
                                    color: primaryBlue,
                                  ),
                                  title: Text(
                                    playerNames,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "براوە: $cleanName",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(15),
                                          bottomRight: Radius.circular(15),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          _buildInfoRow(
                                            Icons.grid_4x4,
                                            "قەبارەی یاری:",
                                            toKurdishNumbers("${gSize}x$gSize"),
                                          ),
                                          const SizedBox(height: 8),

                                          _buildInfoRow(
                                            Icons.calendar_today,
                                            "بەروار:",
                                            toKurdishNumbers(dateOnly),
                                          ),
                                          const SizedBox(height: 8),
                                          _buildInfoRow(
                                            Icons.access_time,
                                            "کات:",
                                            toKurdishNumbers(timeOnly),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SegmentedButton<bool>(
                          showSelectedIcon: false,
                          style: SegmentedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            selectedBackgroundColor: primaryBlue,
                            selectedForegroundColor: Colors.white,
                          ),
                          segments: const [
                            ButtonSegment(
                              value: true,
                              label: Text("بردنەوە"),
                              icon: Icon(Icons.emoji_events_outlined),
                            ),
                            ButtonSegment(
                              value: false,
                              label: Text("خاڵ"),
                              icon: Icon(Icons.bolt_rounded),
                            ),
                          ],
                          selected: {showWinsView},
                          onSelectionChanged: (v) =>
                              setState(() => showWinsView = v.first),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: entries.isEmpty
                            ? _buildEmptyState("هیچ داتایەک نییە")
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: entries.length,
                                itemBuilder: (context, i) {
                                  final e = entries[i];
                                  bool isTop3 = i < 3;
                                  return Card(
                                    elevation: 0,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    color: isTop3
                                        ? primaryBlue.withOpacity(0.05)
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: isTop3
                                            ? primaryBlue.withOpacity(0.2)
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: _buildRankBadge(i),
                                      title: Text(
                                        e.key,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Text(
                                        showWinsView
                                            ? "${toKurdishNumbers(e.value['wins'].toString())} بردنەوە"
                                            : "${toKurdishNumbers(e.value['points'].toString())} خاڵ",
                                        style: const TextStyle(
                                          color: primaryBlue,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge(int index) {
    Color bgColor;
    if (index == 0) {
      bgColor = const Color(0xFFFFD700);
    } else if (index == 1) {
      bgColor = const Color(0xFFC0C0C0);
    } else if (index == 2) {
      bgColor = const Color(0xFFCD7F32);
    } else {
      bgColor = Colors.grey[200]!;
    }

    return CircleAvatar(
      radius: 16,
      backgroundColor: bgColor,
      child: Text(
        toKurdishNumbers((index + 1).toString()),
        style: TextStyle(
          color: index < 3 ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    final sizes = {4: "٤ x ٤", 6: "٦ x ٦", 8: "٨ x ٨"};

    OutlineInputBorder buildBorder(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: 1.5),
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _p1Controller,
            decoration: InputDecoration(
              labelText: "ناوی یاریزانی یەکەم",
              hintText: "یاریزانی یەکەم",
              prefixIcon: const Icon(
                Icons.person_rounded,
                color: Colors.blueAccent,
              ),
              enabledBorder: buildBorder(Colors.grey.shade200),
              focusedBorder: buildBorder(Colors.blueAccent),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _p2Controller,
            enabled: !isAiMode,
            decoration: InputDecoration(
              labelText: isAiMode ? "زیرەکی دەستکرد" : "ناوی یاریزانی دووەم",
              hintText: isAiMode ? "کۆمپیوتەر" : "یاریزانی دووەم",
              prefixIcon: Icon(
                isAiMode
                    ? Icons.smart_toy_outlined
                    : Icons.person_outline_rounded,
                color: isAiMode ? Colors.grey : Colors.indigoAccent,
              ),
              disabledBorder: buildBorder(Colors.grey.shade100),
              enabledBorder: buildBorder(Colors.grey.shade200),
              focusedBorder: buildBorder(Colors.indigoAccent),
              filled: true,
              fillColor: isAiMode ? Colors.grey[50] : Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "یاریکردن لەگەڵ زیرەکی دەستکرد",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Switch.adaptive(
                value: isAiMode,
                onChanged: (v) => setState(() {
                  isAiMode = v;
                  if (v) _p2Controller.clear();
                }),
              ),
            ],
          ),
          const SizedBox(height: 50),
          const Divider(height: 32, thickness: 1),
          const Text(
            "قەبارەی چوارەکە دیاری بکە",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: sizes.entries.map((e) {
              final isSelected = _selectedGridSize == e.key;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGridSize = e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blueAccent : Colors.grey[50],
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blueAccent
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        e.value,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          GestureDetector(
            onTap: () {
              final p1 = _p1Controller.text.trim().isEmpty
                  ? "یاریزانی یەکەم"
                  : _p1Controller.text.trim();
              final p2 = isAiMode
                  ? "زیرەکی دەستکرد"
                  : (_p2Controller.text.trim().isEmpty
                        ? "یاریزانی دووەم"
                        : _p2Controller.text.trim());

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => GameScreen(
                    gridSize: _selectedGridSize,
                    p1Name: p1,
                    p2Name: p2,
                    isVsAi: isAiMode,
                  ),
                ),
              ).then((_) => _loadData());
            },
            child: Container(
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.indigoAccent],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                "دەستپێکردن",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
