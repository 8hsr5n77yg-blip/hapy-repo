import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.book, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 20),
            const Text(
              'hapy·记账',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.title,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'v1.0.0',
              style: TextStyle(fontSize: 16, color: AppColors.subtitle),
            ),
            const SizedBox(height: 24),
            const Text(
              '轻量级 · 无广告 · 隐私优先',
              style: TextStyle(fontSize: 14, color: AppColors.subtitle),
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () {},
              child: const Text('用户协议与隐私政策',
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}
