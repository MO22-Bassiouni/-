import '../utils/helpers.dart';

class Booking {
  final int id, docId, fee;
  final String docName, spec, pay, phone, paidAt;
  String day; // yyyy-MM-dd
  int hour;
  final String pName, pPhone;
  String pPhoto; // صورة المريض (لو السيرفر بيبعتها). مش بتتخزن مع الحجز عشان الحجم
  final String type; // 'clinic' أو 'home'
  final double? lat, lng; // clinic = مكان العيادة ، home = بيت المريض
  String status; // 'active' أو 'cancelled'
  String cancelledAt; // نص للعرض
  String cancelledDate; // yyyy-MM-dd: يوم الإلغاء (عشان يتمسح اخر اليوم)
  // لما المريض يعدّل الميعاد: رسالة للدكتور (كان / بقى) + رقم التعديل
  String editNote;
  String editedAt;
  int editVer;
  Booking(this.id, this.docId, this.docName, this.spec, this.fee, this.day,
      this.hour, this.pay, this.phone, this.paidAt,
      {this.pName = '',
      this.pPhone = '',
      this.pPhoto = '',
      this.type = 'clinic',
      this.lat,
      this.lng,
      this.status = 'active',
      this.cancelledAt = '',
      this.cancelledDate = '',
      this.editNote = '',
      this.editedAt = '',
      this.editVer = 0});

  bool get cash => pay == 'cash'; // حجز بيت: الدفع كاش عند وصول الدكتور
  bool get cancelled => status == 'cancelled';

  /// ميعاد الحجز بالظبط (اليوم + الساعة)
  DateTime get startsAt => DateTime.parse(day).add(Duration(hours: hour));

  /// الميعاد بدأ / عدّى: وقتها المريض يقدر يقيّم الدكتور
  bool get started => !startsAt.isAfter(DateTime.now());

  /// الحجز "منتهي" ويتمسح أوتوماتيك مع بداية اليوم الجديد:
  /// - الحجز العادي: لما يعدّي يوم الحجز.
  /// - الحجز الملغي: لما يعدّي اليوم اللي اتلغى فيه.
  bool get expired {
    final today = isoDay(DateTime.now());
    if (cancelled) {
      final d = cancelledDate.isNotEmpty ? cancelledDate : day;
      return d.compareTo(today) < 0;
    }
    return day.compareTo(today) < 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'docId': docId,
        'docName': docName,
        'spec': spec,
        'fee': fee,
        'day': day,
        'hour': hour,
        'pay': pay,
        'phone': phone,
        'paidAt': paidAt,
        'pName': pName,
        'pPhone': pPhone,
        'type': type,
        'lat': lat,
        'lng': lng,
        'status': status,
        'cancelledAt': cancelledAt,
        'cancelledDate': cancelledDate,
        'editNote': editNote,
        'editedAt': editedAt,
        'editVer': editVer
      };
  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
      (j['id'] as num).toInt(),
      (j['docId'] as num).toInt(),
      '${j['docName']}',
      '${j['spec']}',
      (j['fee'] as num).toInt(),
      '${j['day']}',
      (j['hour'] as num).toInt(),
      '${j['pay']}',
      '${j['phone']}',
      '${j['paidAt']}',
      pName: j['pName'] ?? '',
      pPhone: j['pPhone'] ?? '',
      pPhoto: '${j['pPhoto'] ?? ''}',
      type: j['type'] ?? 'clinic',
      lat: (j['lat'] as num?)?.toDouble(),
      lng: (j['lng'] as num?)?.toDouble(),
      status: '${j['status'] ?? 'active'}',
      cancelledAt: '${j['cancelledAt'] ?? ''}',
      cancelledDate: '${j['cancelledDate'] ?? ''}',
      editNote: '${j['editNote'] ?? ''}',
      editedAt: '${j['editedAt'] ?? ''}',
      editVer: ((j['editVer'] ?? 0) as num).toInt());
}
