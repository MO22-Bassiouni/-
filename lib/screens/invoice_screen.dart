import 'package:flutter/material.dart';
import '../core.dart';
import 'bookings_screen.dart';
import 'map_preview.dart';

// ======================= 7) الفاتورة =======================
class InvoiceScreen extends StatelessWidget {
  final Booking b;
  const InvoiceScreen({super.key, required this.b});
  @override
  Widget build(BuildContext context) {
    const ok = Color(0xFF1F9D63);
    return Shell(
      title: 'الفاتورة',
      subtitle: b.cash
          ? 'ادفع للدكتور كاش لما يوصلك'
          : 'اعرضها على الدكتور لتأكيد الدفع',
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Box(
            pad: const EdgeInsets.all(18),
            child: Column(children: [
              const Icon(Icons.check_circle_rounded, color: ok, size: 56),
              const Text('تم الحجز بنجاح',
                  style: TextStyle(
                      color: ok, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              row('رقم الحجز', '#${b.id}'),
              row('الدكتور', b.docName),
              row('التخصص', b.spec),
              row('اليوم', dayLabel(DateTime.parse(b.day))),
              row('الساعة', fmtHour(b.hour)),
              row('نوع الحجز',
                  b.type == 'home' ? 'زيارة منزلية 🏠' : 'في العيادة 🏥'),
              row('طريقة الدفع',
                  b.cash ? 'كاش عند وصول الدكتور 💵' : payMethods[b.pay]!.$1),
              if (!b.cash) row('الدفع من رقم', b.phone),
              row(b.cash ? 'المبلغ المطلوب' : 'المبلغ', '${b.fee} جنيه'),
              row(b.cash ? 'وقت الحجز' : 'وقت الدفع', b.paidAt, last: true),
            ])),
        if (b.lat != null && b.lng != null) ...[
          const SizedBox(height: 4),
          Text(b.type == 'home' ? 'موقع الزيارة' : 'مكان العيادة',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          MapPreview(lat: b.lat!, lng: b.lng!),
          const SizedBox(height: 10),
          BigBtn(
              'افتح في خرائط جوجل',
              () => openGoogleMaps(context, b.lat!, b.lng!,
                  directions: b.type != 'home'),
              outline: true),
          const SizedBox(height: 14),
        ],
        const SizedBox(height: 8),
        BigBtn('حجوزاتي', () => push(context, const BookingsScreen())),
        const SizedBox(height: 10),
        BigBtn('الرئيسية', () => Navigator.popUntil(context, (r) => r.isFirst),
            outline: true),
      ]),
    );
  }
}
