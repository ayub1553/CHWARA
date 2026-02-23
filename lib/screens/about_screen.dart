// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const customFont = 'ChwaraFont';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "دەربارەی پڕۆژە",
          style: TextStyle(fontFamily: customFont, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/logo_CHWARA.png',
                height: 150,
                fit: BoxFit.contain,
                // ignore: unnecessary_underscores
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_not_supported,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "چوارە (Chwara)",
              style: TextStyle(
                fontFamily: customFont,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoCard(
              title: "پێناسەی پڕۆژە",
              content:
                  "ئەم پڕۆژەیە لە لایەن (ئەیوب قانع عەباس) پەرەی پێدراوە، وەک خوێندکاری قۆناغی یەکەم لە بەشی تەکنەلۆژیای زانیاری (IT) لە زانکۆی پۆلیتەکنیکی گەرمیان - کۆلێژی تەکنیکی کفری.\n\nهەڵبژاردنی ناوی (چوارە) ڕەنگدانەوەی شێوازی یارییەکەیە؛ چونکە بنەمای سەرەکی بردنەوە بەندە بە تەواوکردنی هەر چوار لای چوارگۆشەیەک. بەو پێیەی یاریزان تەنها بە کێشانی هێڵی 'چوارەم' خاڵ بەدەست دەهێنێت، ئەم ناوە وەک گوزارشتێکی کوردی بۆ مۆدێلی یارییەکە دیاری کراوە.",
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              title: "تایبەتمەندییە تەکنیکییەکان",
              content:
                  "ئەم یارییە بە زمانی (Dart) و فرەیمۆرکی (Flutter) پەرەی پێدراوە. سیستەمی یارییەکە ڕێگە بە دوو شێوازی جیاواز دەدات: یاری بەرامبەر بە ژیریی دەستکرد (AI) یان یاری دوو کەسی (1vs1) لەسەر هەمان ئامێر.\n\nلە ئێستادا یارییەکە سێ قەبارەی جیاوازی بۆرد (Grid Size) لەخۆ دەگرێت کە بریتین لە (4x4، 6x6، 8x8)، لەگەڵ ئەگەری فراوانکردنی بۆ قەبارەی زیاتر لە وەشانەکانی داهاتوودا. پڕۆژەکە بە شێوەی وێب ئەپڵیکەیشنێکی سەردەمیانە دیزاین کراوە.",
            ),
            const SizedBox(height: 40),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "Ayoob IT",
                style: TextStyle(
                  fontFamily: customFont,
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'ChwaraFont',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontFamily: 'ChwaraFont',
              fontSize: 15,
              height: 1.8,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
