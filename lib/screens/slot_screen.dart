import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../core.dart';
import 'invoice_screen.dart';
import 'pay_screen.dart';

// ======================= 5) اليوم والميعاد =======================
class SlotScreen extends StatefulWidget {
  final Doctor doc;
  final Booking? editing;
  final String type;
  final LatLng? pos;
  const SlotScreen(
      {super.key,
      required this.doc,
      this.editing,
      this.type = 'clinic',
      this.pos});
  @override
  State<SlotScreen> createState() => _SlotState();
}

class _SlotState extends State<SlotScreen> {
  String? day;
  int? hour;
  List<Booking> taken = [];
  bool saving = false;

  @override
  void initState() {
    super.initState();
    day = widget.editing?.day;
    hour = widget.editing?.hour;
    refreshTaken();
  }

  Future<void> refreshTaken() async {
    final t = await Repo.activeBookingsFor(widget.doc.id);
    if (mounted) setState(() => taken = t);
  }

  bool busy(int h) => taken
      .any((b) => b.day == day && b.hour == h && b.id != widget.editing?.id);

  void showBusy() {
    final m = ScaffoldMessenger.of(context);
    m.hideCurrentSnackBar();
    m.showSnackBar(const SnackBar(
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      content: Text('عذرًا، هذا الميعاد محجوز بالفعل. اختار ميعاد تاني',
          style: TextStyle(fontWeight: FontWeight.w700)),
    ));
  }

  Future<void> takenDialog() async {
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.event_busy_rounded, color: Colors.red, size: 38),
        title: const Text('عذرًا'),
        content: const Text('هذا الميعاد محجوز بالفعل. اختار ميعاد تاني.',
            textAlign: TextAlign.center),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('حاضر'))
        ],
      ),
    );
  }

  Future<void> onContinue() async {
    final d = widget.doc;
    setState(() => saving = true);
    final isTaken =
        await Repo.slotTaken(d.id, day!, hour!, excludeId: widget.editing?.id);
    if (!mounted) return;
    if (isTaken) {
      setState(() {
        saving = false;
        hour = null;
      });
      await refreshTaken();
      if (mounted) await takenDialog();
      return;
    }
    if (widget.editing != null) {
      final e = widget.editing!;
      final changed = e.day != day || e.hour != hour;
      if (changed) {
        final before =
            '${dayLabel(DateTime.parse(e.day))} - ${fmtHour(e.hour)}';
        final after =
            '${dayLabel(DateTime.parse(day!))} - ${fmtHour(hour!)}';
        e.day = day!;
        e.hour = hour!;
        // رسالة للدكتور بالتعديل
        e.editVer += 1;
        e.editedAt = stampNow(DateTime.now());
        e.editNote = 'كان: $before\nبقى: $after';
        app.save();
        Repo.sendBooking(e);
      }
      setState(() => saving = false);
      if (!mounted) return;
      if (changed) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تم تعديل الموعد وهيوصل تنبيه للدكتور')));
      }
      Navigator.pop(context);
      return;
    }
    if (widget.type == 'home') {
      // حجز في البيت: مفيش دفع دلوقتي، الدفع كاش لما الدكتور يوصل
      final n = DateTime.now();
      final b = Booking(
        1000 + n.millisecondsSinceEpoch % 900000,
        d.id,
        d.name,
        d.spec,
        d.fee,
        day!,
        hour!,
        'cash',
        '-',
        stampNow(n),
        pName: app.userName,
        pPhone: app.userPhone,
        type: 'home',
        lat: widget.pos?.latitude,
        lng: widget.pos?.longitude,
      );
      final ok = await app.add(b);
      if (!mounted) return;
      if (!ok) {
        setState(() {
          saving = false;
          hour = null;
        });
        await refreshTaken();
        if (mounted) await takenDialog();
        return;
      }
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => InvoiceScreen(b: b)),
          (r) => r.isFirst);
      return;
    }
    setState(() => saving = false);
    push(
        context,
        PayScreen(
            doc: d,
            day: day!,
            hour: hour!,
            type: widget.type,
            pos: widget.pos));
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.doc;
    final pr = Theme.of(context).colorScheme.primary;
    final days = List.generate(21, (i) => DateTime.now().add(Duration(days: i)))
        .where((x) => d.days.contains(x.weekday))
        .take(7)
        .toList();
    final hours = [for (int h = d.from; h < d.to; h++) h];
    Widget chip(String t, bool on, VoidCallback f) => ChoiceChip(
          label: Text(t,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: on ? Colors.white : null)),
          selected: on,
          onSelected: (_) => f(),
          selectedColor: pr,
          showCheckmark: false,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        );
    Widget hourChip(int h) {
      if (busy(h)) {
        return ChoiceChip(
          label: Text(fmtHour(h),
              style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.red,
                  fontWeight: FontWeight.w700)),
          selected: false,
          onSelected: (_) => showBusy(),
          showCheckmark: false,
          backgroundColor: Colors.red.withOpacity(.08),
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.red.withOpacity(.4)),
              borderRadius: BorderRadius.circular(14)),
        );
      }
      return chip(fmtHour(h), hour == h, () => setState(() => hour = h));
    }

    final isHome = widget.type == 'home' && widget.editing == null;
    final ready = day != null && hour != null && !saving;
    return Shell(
      title: widget.editing != null ? 'تعديل الموعد' : 'اختار الموعد',
      subtitle: d.name,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Box(
            child: Row(children: [
          DoctorAvatar(d, 56),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(d.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16)),
                Text('${d.spec} • ${d.city}',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 2),
                RatingBadge(doc: d),
              ])),
          Text('${d.fee} ج',
              style: const TextStyle(
                  color: Color(0xFFE5633D),
                  fontWeight: FontWeight.w800,
                  fontSize: 16)),
        ])),
        if (isHome)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                color: pr.withOpacity(.12),
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Icon(Icons.payments_outlined, color: pr),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                      'حجز في البيت: مفيش دفع دلوقتي. هتدفع ${d.fee} جنيه كاش للدكتور لما يوصلك.',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, height: 1.5))),
            ]),
          ),
        if (widget.editing != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                color: const Color(0xFFFF8A65).withOpacity(.15),
                borderRadius: BorderRadius.circular(14)),
            child: const Row(children: [
              Icon(Icons.notifications_active_outlined,
                  color: Color(0xFFE5633D)),
              SizedBox(width: 10),
              Expanded(
                  child: Text('لو غيّرت الميعاد، الدكتور هيوصله تنبيه بالتعديل.',
                      style: TextStyle(fontWeight: FontWeight.w600))),
            ]),
          ),
        const SizedBox(height: 6),
        const Text('اليوم',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final x in days)
            chip(
                dayLabel(x),
                day == isoDay(x),
                () => setState(() {
                      day = isoDay(x);
                      hour = null;
                    })),
        ]),
        if (day != null) ...[
          const SizedBox(height: 18),
          const Text('الساعة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('الساعات المشطوبة بالأحمر محجوزة',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final h in hours) hourChip(h)]),
        ],
        const SizedBox(height: 24),
        BigBtn(
          saving
              ? 'جاري التأكيد...'
              : widget.editing != null
                  ? 'حفظ التعديل'
                  : isHome
                      ? 'تأكيد الحجز (الدفع عند الزيارة)'
                      : 'متابعة للدفع',
          ready ? onContinue : null,
        ),
      ]),
    );
  }
}
