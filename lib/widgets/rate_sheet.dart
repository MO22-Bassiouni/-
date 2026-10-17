import 'package:flutter/material.dart';
import '../core.dart';

/// نافذة تقييم الدكتور (نجوم + تعليق اختياري). بترجّع true لو المريض أرسل التقييم.
Future<bool?> showRateSheet(BuildContext c,
        {required int docId, required String docName}) =>
    showModalBottomSheet<bool>(
        context: c,
        isScrollControlled: true,
        builder: (_) => RateSheet(docId: docId, docName: docName));

class RateSheet extends StatefulWidget {
  final int docId;
  final String docName;
  const RateSheet({super.key, required this.docId, required this.docName});
  @override
  State<RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends State<RateSheet> {
  late int stars;
  late final TextEditingController note;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    final old = Repo.myRating(widget.docId, app.userPhone);
    stars = old?.stars ?? 0;
    note = TextEditingController(text: old?.comment ?? '');
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final m = ScaffoldMessenger.of(context);
    if (stars == 0) {
      m.showSnackBar(const SnackBar(content: Text('اختار عدد النجوم الأول')));
      return;
    }
    setState(() => busy = true);
    final now = DateTime.now();
    await Repo.addRating(Rating(now.millisecondsSinceEpoch, widget.docId,
        stars, app.userName, app.userPhone, note.text.trim(), stampNow(now)));
    app.refresh();
    if (!mounted) return;
    Navigator.pop(context, true);
    m.showSnackBar(const SnackBar(content: Text('شكرًا على تقييمك 🌟')));
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
            22, 22, 22, 22 + MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('قيّم ${widget.docName}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            StarsRow(stars.toDouble(),
                size: 40, onChanged: (v) => setState(() => stars = v)),
            const SizedBox(height: 14),
            TextField(
              controller: note,
              maxLines: 3,
              maxLength: 200,
              decoration: const InputDecoration(
                  labelText: 'اكتب تعليقك (اختياري)',
                  prefixIcon: Icon(Icons.rate_review_outlined)),
            ),
            const SizedBox(height: 8),
            BigBtn(busy ? 'جاري الإرسال...' : 'إرسال التقييم',
                busy ? null : submit),
          ]),
        ),
      );
}
