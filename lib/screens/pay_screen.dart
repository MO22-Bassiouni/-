import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../core.dart';
import 'invoice_screen.dart';

// ======================= 6) الدفع =======================
class PayScreen extends StatefulWidget {
  final Doctor doc;
  final String day;
  final int hour;
  final String type;
  final LatLng? pos;
  const PayScreen(
      {super.key,
      required this.doc,
      required this.day,
      required this.hour,
      this.type = 'clinic',
      this.pos});
  @override
  State<PayScreen> createState() => _PayState();
}

class _PayState extends State<PayScreen> {
  late String m;
  final ctl = TextEditingController();
  bool sending = false;
  List<String> get avail =>
      payMethods.keys.where((k) => widget.doc.numberFor(k) != null).toList();
  bool get valid => RegExp(r'^01[0-9]{9}$').hasMatch(ctl.text.trim());

  @override
  void initState() {
    super.initState();
    m = avail.isNotEmpty ? avail.first : 'vf';
  }

  @override
  void dispose() {
    ctl.dispose();
    super.dispose();
  }

  Future<void> confirm() async {
    final d = widget.doc;
    final n = DateTime.now();
    final b = Booking(
      1000 + n.millisecondsSinceEpoch % 900000,
      d.id,
      d.name,
      d.spec,
      d.fee,
      widget.day,
      widget.hour,
      m,
      ctl.text.trim(),
      stampNow(n),
      pName: app.userName,
      pPhone: app.userPhone,
      type: widget.type,
      lat: widget.type == 'home' ? widget.pos?.latitude : d.lat,
      lng: widget.type == 'home' ? widget.pos?.longitude : d.lng,
    );
    setState(() => sending = true);
    final ok = await app.add(b);
    if (!mounted) return;
    setState(() => sending = false);
    if (!ok) {
      await showDialog(
        context: context,
        builder: (c) => AlertDialog(
          icon: const Icon(Icons.event_busy_rounded,
              color: Colors.red, size: 38),
          title: const Text('عذرًا'),
          content: const Text(
              'هذا الميعاد محجوز بالفعل. ارجع واختار ميعاد تاني.',
              textAlign: TextAlign.center),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c), child: const Text('حاضر'))
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
      return;
    }
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => InvoiceScreen(b: b)),
        (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.doc;
    final pr = Theme.of(context).colorScheme.primary;
    return Shell(
      title: 'الدفع',
      subtitle: 'ادفع كشف ${d.name}',
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Box(
            child: Column(children: [
          row('الدكتور', d.name),
          row('الموعد',
              '${dayLabel(DateTime.parse(widget.day))} - ${fmtHour(widget.hour)}'),
          row('نوع الحجز',
              widget.type == 'home' ? 'زيارة منزلية 🏠' : 'في العيادة 🏥'),
          row('المبلغ', '${d.fee} جنيه', last: true),
        ])),
        const SizedBox(height: 4),
        if (avail.isEmpty)
          const Padding(
              padding: EdgeInsets.all(20),
              child: Text('الدكتور ده لسه مضافش وسيلة دفع. تواصل مع العيادة.',
                  textAlign: TextAlign.center))
        else ...[
          const Text('اختار طريقة الدفع',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          for (final k in avail)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: cardColor(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: m == k ? pr : Colors.transparent, width: 2),
              ),
              child: ListTile(
                onTap: () => setState(() => m = k),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                leading: Icon(payMethods[k]!.$2, color: pr, size: 30),
                title: Text(payMethods[k]!.$1,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: Icon(
                    m == k
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: pr),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: const Color(0xFFFF8A65).withOpacity(.15),
                borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Expanded(
                  child: Text(
                      'حوّل ${d.fee} جنيه على ${payMethods[m]!.$1} للدكتور:\n${d.numberFor(m)}\nوبعدها اكتب الرقم اللي حوّلت منه 👇',
                      style: const TextStyle(
                          height: 1.7, fontWeight: FontWeight.w600))),
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: d.numberFor(m)!));
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('تم النسخ')));
                },
              ),
            ]),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: ctl,
            keyboardType: TextInputType.phone,
            maxLength: 11,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
                labelText: 'الرقم اللي حوّلت منه',
                prefixIcon: Icon(Icons.phone_rounded),
                counterText: ''),
          ),
          const SizedBox(height: 12),
          BigBtn(sending ? 'جاري التأكيد...' : 'تأكيد الحجز',
              (!valid || sending) ? null : confirm),
        ],
      ]),
    );
  }
}
