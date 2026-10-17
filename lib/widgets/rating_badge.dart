import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../services/repo.dart';

/// متوسط تقييم الدكتور (نجمة + رقم + عدد التقييمات)
class RatingBadge extends StatelessWidget {
  final Doctor doc;
  const RatingBadge({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final (avg, n) = Repo.stats(doc);
    if (n == 0) {
      return Text('لا توجد تقييمات بعد',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 18),
      const SizedBox(width: 3),
      Text(avg.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      Text('  ($n تقييم)',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
    ]);
  }
}
