import 'package:flutter/material.dart';
import '../core.dart';
import 'invoice_screen.dart';
import 'place_screen.dart';
import 'slot_screen.dart';

// ======================= 8) حجوزاتي (تعديل / إلغاء / مكان العيادة / تقييم) =======================
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  Widget _rateBtn(BuildContext context, int docId, String docName) {
    final done = Repo.myRating(docId, app.userPhone) != null;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.star_rounded, color: Color(0xFFFFB300)),
        label: Text(done ? 'عدّل تقييمك للدكتور' : 'قيّم الدكتور'),
        onPressed: () => showRateSheet(context, docId: docId, docName: docName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final list = app.bookings;
          final visits = app.visitsToRate;
          return Shell(
            title: 'حجوزاتي',
            subtitle: 'عدّل أو الغي مواعيدك',
            child: (list.isEmpty && visits.isEmpty)
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.event_busy_rounded,
                        size: 64, color: Colors.grey.shade500),
                    const SizedBox(height: 8),
                    const Text('مفيش حجوزات لسه',
                        style: TextStyle(fontSize: 16)),
                  ]))
                : ListView(padding: const EdgeInsets.all(16), children: [
                    for (final b in list.reversed)
                      Box(
                          child: Column(children: [
                        row(b.docName,
                            b.cash ? 'الدفع عند الزيارة 💵' : 'مدفوع ✅'),
                        row('الموعد',
                            '${dayLabel(DateTime.parse(b.day))} - ${fmtHour(b.hour)} • ${b.type == 'home' ? 'بيت' : 'عيادة'}',
                            last: true),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                              child: OutlinedButton(
                                  onPressed: () =>
                                      push(context, InvoiceScreen(b: b)),
                                  child: const Text('الفاتورة'))),
                          const SizedBox(width: 8),
                          Expanded(
                              child: OutlinedButton(
                            onPressed: () {
                              final i =
                                  Repo.all.indexWhere((d) => d.id == b.docId);
                              if (i >= 0) {
                                push(context,
                                    SlotScreen(doc: Repo.all[i], editing: b));
                              }
                            },
                            child: const Text('تعديل'),
                          )),
                          const SizedBox(width: 8),
                          Expanded(
                              child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red),
                            onPressed: () async {
                              final yes = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('إلغاء الحجز؟'),
                                  content: const Text(
                                      'الدكتور هيتبلّغ إنك لغيت الحجز.'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(c, false),
                                        child: const Text('لا')),
                                    TextButton(
                                        onPressed: () => Navigator.pop(c, true),
                                        child: const Text('نعم، الغي')),
                                  ],
                                ),
                              );
                              if (yes == true) app.cancel(b.id);
                            },
                            child: const Text('إلغاء'),
                          )),
                        ]),
                        if (b.lat != null && b.lng != null) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.location_on_rounded),
                              label: Text(b.type == 'home'
                                  ? 'موقع الزيارة'
                                  : 'مكان العيادة'),
                              onPressed: () => push(
                                  context,
                                  PlaceScreen(
                                      title: b.type == 'home'
                                          ? 'موقع الزيارة'
                                          : 'مكان العيادة',
                                      lat: b.lat!,
                                      lng: b.lng!,
                                      note: b.docName)),
                            ),
                          ),
                        ],
                        // التقييم بيظهر بعد ما ميعاد الكشف يبدأ
                        if (b.started) ...[
                          const SizedBox(height: 8),
                          _rateBtn(context, b.docId, b.docName),
                        ],
                      ])),
                    if (visits.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      const Text('زيارات سابقة - قيّم الدكتور',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      for (final v in visits)
                        Box(
                            child: Column(children: [
                          row('${v['docName']}', '${v['spec']}'),
                          row('الزيارة',
                              dayLabel(DateTime.parse('${v['day']}')),
                              last: true),
                          const SizedBox(height: 8),
                          _rateBtn(context, (v['docId'] as num).toInt(),
                              '${v['docName']}'),
                        ])),
                    ],
                  ]),
          );
        },
      );
}
