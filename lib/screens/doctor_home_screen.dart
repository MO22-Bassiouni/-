import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core.dart';
import 'place_screen.dart';
import 'ratings_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});
  @override
  State<DoctorHomeScreen> createState() => _DocHomeState();
}

class _DocHomeState extends State<DoctorHomeScreen> {
  late Future<List<Booking>> f;
  late Future<List<Rating>> rf;
  List<Booking> last = [];
  bool active = false;
  bool _dialogOpen = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    active = app.myDoc?['active'] == true;
    load();
    // تحديث تلقائي كل 20 ثانية عشان يوصله أي إلغاء، وكمان بيمسح حجوزات اليوم اللي فات
    timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(load);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void load() {
    final id = app.myDoc!['id'];
    app.purgeExpired(); // مسح الحجوزات القديمة والملغية بعد نهاية يومها
    rf = Repo.ratingsFor((id as num).toInt());
    f = Repo.doctorBookings(id);
    f.then((l) {
      last = l;
      notifyCancels(l);
    });
    Repo.doctorStatus(id).then((a) {
      if (mounted) setState(() => active = a);
    });
  }

  // تنبيه الدكتور لما مريض يلغي حجز أو يعدّل ميعاده (مرة واحدة لكل تغيير)
  Future<void> notifyCancels(List<Booking> list) async {
    if (!mounted || _dialogOpen) return;
    final seen = app.p.getStringList('seenCancel') ?? <String>[];
    final cancels =
        list.where((b) => b.cancelled && !seen.contains('${b.id}')).toList();
    final edits = list
        .where((b) =>
            !b.cancelled &&
            b.editVer > 0 &&
            !seen.contains('${b.id}e${b.editVer}'))
        .toList();
    if (cancels.isEmpty && edits.isEmpty) return;
    await app.p.setStringList('seenCancel', [
      ...seen,
      ...cancels.map((b) => '${b.id}'),
      ...edits.map((b) => '${b.id}e${b.editVer}'),
    ]);
    if (!mounted) return;
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.vibrate();
    _dialogOpen = true;
    final lines = <String>[
      for (final b in cancels)
        '• ${b.pName.isEmpty ? 'مريض' : b.pName} لغى حجزه - ${dayLabel(DateTime.parse(b.day))} ${fmtHour(b.hour)}',
      for (final b in edits)
        '• ${b.pName.isEmpty ? 'مريض' : b.pName} عدّل الميعاد\n   ${b.editNote.replaceAll('\n', '\n   ')}',
    ];
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.notifications_active_rounded,
            color: Colors.red, size: 38),
        title: Text(cancels.isNotEmpty && edits.isNotEmpty
            ? 'تنبيه جديد في الحجوزات'
            : cancels.isNotEmpty
                ? (cancels.length == 1
                    ? 'مريض لغى حجزه'
                    : '${cancels.length} مرضى لغوا حجزهم')
                : (edits.length == 1
                    ? 'مريض عدّل ميعاده'
                    : '${edits.length} مرضى عدّلوا مواعيدهم')),
        content: SingleChildScrollView(
          child: Text(lines.join('\n\n'), style: const TextStyle(height: 1.8)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('تمام'))
        ],
      ),
    );
    _dialogOpen = false;
  }

  Widget card(Booking b) {
    final c = b.cancelled;
    return Box(
        child: Column(children: [
      if (c)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
              color: Colors.red.withOpacity(.12),
              borderRadius: BorderRadius.circular(12)),
          child: const Row(children: [
            Icon(Icons.cancel_rounded, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
                child: Text('المريض لغى الحجز ده (هيتمسح آخر اليوم)',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w800))),
          ]),
        ),
      if (!c && b.editVer > 0)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
              color: const Color(0xFFFF8A65).withOpacity(.18),
              borderRadius: BorderRadius.circular(12)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.edit_calendar_rounded, color: Color(0xFFE5633D)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
                    'المريض عدّل الميعاد (${b.editedAt})\n${b.editNote}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, height: 1.6))),
          ]),
        ),
      Builder(builder: (_) {
        final photo =
            b.pPhoto.isNotEmpty ? b.pPhoto : Repo.patientPhoto(b.pPhone);
        final img = photoProvider(photo);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            GestureDetector(
              onTap: img == null
                  ? null
                  : () => showDialog(
                      context: context,
                      builder: (_) => Dialog(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image(image: img, fit: BoxFit.contain)))),
              child: UserAvatar(photo, 56, circle: true),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(b.pName.isEmpty ? 'مريض' : b.pName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800))),
          ]),
        );
      }),
      Row(children: [
        Expanded(child: row('رقم المريض', b.pPhone.isEmpty ? '-' : b.pPhone)),
        if (b.pPhone.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: b.pPhone));
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('تم نسخ الرقم')));
            },
          ),
      ]),
      row('الموعد', '${dayLabel(DateTime.parse(b.day))} - ${fmtHour(b.hour)}'),
      row('نوع الحجز', b.type == 'home' ? 'زيارة منزلية 🏠' : 'في العيادة 🏥'),
      if (!c && b.type == 'home' && b.lat != null && b.lng != null)
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.location_on_rounded),
              label: const Text('موقع بيت المريض'),
              onPressed: () => push(
                  context,
                  PlaceScreen(
                      title: 'موقع بيت المريض',
                      lat: b.lat!,
                      lng: b.lng!,
                      note: b.pName)),
            ),
          ),
        ),
      row(
          'الدفع',
          b.cash
              ? 'كاش عند الزيارة - ${b.fee} ج (لسه ما اتدفعش)'
              : '${payMethods[b.pay]?.$1 ?? b.pay} - ${b.fee} ج'),
      if (!b.cash) row('حوّل من رقم', b.phone),
      row(b.cash ? 'وقت الحجز' : 'وقت الدفع', b.paidAt, last: !c),
      if (c) row('وقت الإلغاء', b.cancelledAt, last: true),
      if (c && !b.cash)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('المريض كان حوّل ${b.fee} ج. لازم ترجّعهاله.',
              style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ),
    ]));
  }

  // كارت تقييمات المرضى للدكتور (بيفتح شاشة التعليقات)
  Widget ratingCard(Map<String, dynamic> d) => FutureBuilder<List<Rating>>(
        future: rf,
        builder: (c, snap) {
          final (avg, n) = Repo.summarize(snap.data ?? const <Rating>[]);
          return Box(
            onTap: () => push(
                context,
                RatingsScreen(
                    docId: (d['id'] as num).toInt(), docName: '${d['name']}')),
            child: Row(children: [
              const Icon(Icons.star_rounded,
                  color: Color(0xFFFFB300), size: 34),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('تقييمات المرضى',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    n == 0
                        ? Text('لا توجد تقييمات بعد',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12))
                        : Row(children: [
                            StarsRow(avg, size: 16),
                            Text('  ${avg.toStringAsFixed(1)} ($n تقييم)',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                          ]),
                  ])),
              const Icon(Icons.chevron_left_rounded),
            ]),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final d = app.myDoc!;
    return Shell(
      title: 'حجوزات المرضى',
      subtitle: '${d['name']}',
      profile: true,
      child: RefreshIndicator(
        onRefresh: () async {
          setState(load);
          await f;
        },
        child: FutureBuilder<List<Booking>>(
          future: f,
          builder: (c, snap) {
            final data = snap.data ?? last;
            final waiting =
                snap.connectionState == ConnectionState.waiting && last.isEmpty;
            String key(Booking b) =>
                '${b.day}${b.hour.toString().padLeft(2, '0')}';
            final list = [...data]..sort((a, b) {
                if (a.cancelled != b.cancelled) {
                  return a.cancelled ? 1 : -1; // الملغي في الآخر
                }
                return key(a).compareTo(key(b));
              });
            return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: (active
                              ? const Color(0xFF1F9D63)
                              : const Color(0xFFFF8A65))
                          .withOpacity(.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(children: [
                      Icon(
                          active
                              ? Icons.check_circle_rounded
                              : Icons.hourglass_top_rounded,
                          color: active
                              ? const Color(0xFF1F9D63)
                              : const Color(0xFFE5633D)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(
                        active
                            ? 'حسابك مفعّل وبيظهر للمرضى'
                            : 'حسابك قيد المراجعة. هيظهر للمرضى بعد التفعيل من الإدارة',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      )),
                    ]),
                  ),
                  ratingCard(d),
                  if (waiting)
                    const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()))
                  else if (list.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(children: [
                        Icon(Icons.event_available_rounded,
                            size: 60, color: Colors.grey.shade500),
                        const SizedBox(height: 8),
                        const Text('مفيش حجوزات لسه',
                            style: TextStyle(fontSize: 16)),
                        Text('اسحب لتحت للتحديث',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12)),
                      ]),
                    )
                  else
                    for (final b in list) card(b),
                ]);
          },
        ),
      ),
    );
  }
}
