import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/booking.dart';
import '../models/doctor.dart';
import '../models/rating.dart';
import '../state/app_state.dart';

// لو apiBase فاضي: الدكاترة اللي بتسجلهم من شاشة "دكتور" بيتحفظوا على الموبايل ويظهروا للمرضى فورًا.
// لو apiBase مكتوب: GET {apiBase}/doctors بيرجّع JSON array.
// الحجوزات بتتبعت POST على {apiBase}/bookings. لو الميعاد محجوز السيرفر يرجّع 409.
// الإلغاء: POST {apiBase}/bookings/{id}/cancel وبيغيّر status إلى cancelled.
// ملحوظة: الحجوزات القديمة والملغية بتتفلتر على التطبيق (Booking.expired) وبتتمسح من الجهاز مع بداية اليوم الجديد.
// ويُفضّل السيرفر كمان يمسحهم نهاية اليوم.
class Repo {
  static List<Doctor> all = [];
  static List<Map<String, dynamic>> _localRaw = [];

  static Future<void> _saveLocal() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('localDocs', jsonEncode(_localRaw));
  }

  static Future<void> load() async {
    await loadRatings();
    await loadPatientPhotos();
    if (apiBase.isNotEmpty) {
      try {
        final r = await http
            .get(Uri.parse('$apiBase/doctors'))
            .timeout(const Duration(seconds: 12));
        if (r.statusCode == 200) {
          all = (jsonDecode(utf8.decode(r.bodyBytes)) as List)
              .map((e) => Doctor.fromJson(e))
              .toList();
          return;
        }
      } catch (_) {}
      return;
    }
    try {
      final p = await SharedPreferences.getInstance();
      final s = p.getString('localDocs');
      _localRaw = s == null
          ? []
          : (jsonDecode(s) as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
      all = _localRaw.map((e) => Doctor.fromJson(e)).toList();
    } catch (_) {
      _localRaw = [];
      all = [];
    }
  }

  // بيرجّع false لو السيرفر قال إن الميعاد محجوز (409)
  static Future<bool> sendBooking(Booking b) async {
    if (apiBase.isEmpty) return true;
    try {
      final r = await http.post(Uri.parse('$apiBase/bookings'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(b.toJson()));
      if (r.statusCode == 409) return false;
    } catch (_) {}
    return true;
  }

  static Future<void> cancelBooking(int id) async {
    if (apiBase.isEmpty) return;
    try {
      await http.post(Uri.parse('$apiBase/bookings/$id/cancel'));
    } catch (_) {}
  }

  // الحجوزات الفعّالة (غير الملغية وغير المنتهية) لدكتور معين: من الجهاز + من السيرفر
  static Future<List<Booking>> activeBookingsFor(int docId) async {
    final m = <int, Booking>{};
    final cancelledIds = <int>{};
    for (final b in app.allBookings) {
      if (b.docId != docId) continue;
      if (b.cancelled) {
        cancelledIds.add(b.id);
      } else if (!b.expired) {
        m[b.id] = b;
      }
    }
    if (apiBase.isNotEmpty) {
      try {
        final r = await http
            .get(Uri.parse('$apiBase/doctors/$docId/bookings'))
            .timeout(const Duration(seconds: 12));
        if (r.statusCode == 200) {
          for (final e in (jsonDecode(utf8.decode(r.bodyBytes)) as List)) {
            final b = Booking.fromJson(Map<String, dynamic>.from(e));
            if (!b.cancelled && !b.expired && !cancelledIds.contains(b.id)) {
              m.putIfAbsent(b.id, () => b);
            }
          }
        }
      } catch (_) {}
    }
    return m.values.toList();
  }

  static Future<bool> slotTaken(int docId, String day, int hour,
      {int? excludeId}) async {
    final l = await activeBookingsFor(docId);
    return l.any((b) => b.day == day && b.hour == hour && b.id != excludeId);
  }

  static Future<void> registerPatient(String name, String phone) async {
    if (apiBase.isEmpty) return;
    try {
      await http.post(Uri.parse('$apiBase/patients'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': name, 'phone': phone}));
    } catch (_) {}
  }

  // تسجيل دكتور جديد.
  // بدون API: بيتحفظ محليًا ومفعّل على طول. مع API: بيتحفظ في الداشبورد بحالة active=false لحد ما تفعّله.
  static Future<Map<String, dynamic>?> registerDoctor(
      Map<String, dynamic> d) async {
    if (apiBase.isEmpty) {
      final doc = {
        ...d,
        'id': 100 + DateTime.now().millisecondsSinceEpoch % 1000000,
        'active': true
      };
      _localRaw.add(doc);
      all.add(Doctor.fromJson(doc));
      await _saveLocal();
      return doc;
    }
    try {
      final r = await http
          .post(Uri.parse('$apiBase/doctors/register'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(d))
          .timeout(const Duration(seconds: 15));
      if (r.statusCode == 200 || r.statusCode == 201) {
        return {
          ...d,
          ...(jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>)
        };
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> doctorStatus(dynamic id) async {
    if (apiBase.isEmpty) return app.myDoc?['active'] == true;
    try {
      final r = await http
          .get(Uri.parse('$apiBase/doctors/$id'))
          .timeout(const Duration(seconds: 12));
      if (r.statusCode == 200) {
        return (jsonDecode(utf8.decode(r.bodyBytes)) as Map)['active'] == true;
      }
    } catch (_) {}
    return app.myDoc?['active'] == true;
  }

  // حجوزات الدكتور (بدون الحجوزات القديمة / الملغية اللي عدّى عليها يوم)
  static Future<List<Booking>> doctorBookings(dynamic id) async {
    if (apiBase.isEmpty) {
      return app.allBookings
          .where((b) => b.docId == id && !b.expired)
          .toList();
    }
    try {
      final r = await http
          .get(Uri.parse('$apiBase/doctors/$id/bookings'))
          .timeout(const Duration(seconds: 12));
      if (r.statusCode == 200) {
        return (jsonDecode(utf8.decode(r.bodyBytes)) as List)
            .map((e) => Booking.fromJson(Map<String, dynamic>.from(e)))
            .where((b) => !b.expired)
            .toList();
      }
    } catch (_) {}
    return [];
  }

  // ======================= الصور =======================
  // الصورة بتتحفظ base64. مع API: POST {apiBase}/doctors/{id}/photo و {apiBase}/patients/photo
  static Future<void> updateDoctorPhoto(dynamic id, String photo) async {
    final i = (id as num).toInt();
    final ri = _localRaw.indexWhere((e) => (e['id'] as num).toInt() == i);
    if (ri >= 0) {
      _localRaw[ri]['photo'] = photo;
      await _saveLocal();
    }
    final di = all.indexWhere((d) => d.id == i);
    if (di >= 0) all[di] = all[di].copyWith(photo: photo);
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('doctorAccounts');
      if (raw != null) {
        final accs = jsonDecode(raw) as List;
        for (final a in accs) {
          final d = a['doctor'];
          if (d is Map && (d['id'] as num?)?.toInt() == i) d['photo'] = photo;
        }
        await prefs.setString('doctorAccounts', jsonEncode(accs));
      }
    } catch (_) {}
    if (apiBase.isNotEmpty) {
      try {
        await http
            .post(Uri.parse('$apiBase/doctors/$i/photo'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'photo': photo}))
            .timeout(const Duration(seconds: 20));
      } catch (_) {}
    }
  }

  // صور المرضى (بالموبايل) عشان تظهر للدكتور في الحجز
  static Map<String, String> _patientPhotos = {};

  static String patientPhoto(String phone) => _patientPhotos[phone] ?? '';

  static Future<void> loadPatientPhotos() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString('patientAccounts');
      final m = <String, String>{};
      if (raw != null) {
        for (final a in (jsonDecode(raw) as List)) {
          final pic = '${a['photo'] ?? ''}';
          if (pic.isNotEmpty) m['${a['phone']}'] = pic;
        }
      }
      _patientPhotos = m;
    } catch (_) {
      _patientPhotos = {};
    }
  }

  static Future<void> updatePatientPhoto(
      String name, String phone, String photo) async {
    if (photo.isEmpty) {
      _patientPhotos.remove(phone);
    } else {
      _patientPhotos[phone] = photo;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('patientAccounts');
      if (raw != null) {
        final accs = jsonDecode(raw) as List;
        for (final a in accs) {
          if ('${a['phone']}' == phone &&
              '${a['name']}'.trim().toLowerCase() ==
                  name.trim().toLowerCase()) {
            a['photo'] = photo;
          }
        }
        await prefs.setString('patientAccounts', jsonEncode(accs));
      }
    } catch (_) {}
    if (apiBase.isNotEmpty) {
      try {
        await http
            .post(Uri.parse('$apiBase/patients/photo'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'phone': phone, 'photo': photo}))
            .timeout(const Duration(seconds: 20));
      } catch (_) {}
    }
  }

  // ======================= التقييمات =======================
  // بدون API: بتتحفظ على الجهاز وبتظهر لكل المستخدمين على نفس الجهاز.
  // مع API: POST {apiBase}/doctors/{id}/ratings (body = Rating.toJson)
  //         GET  {apiBase}/doctors/{id}/ratings => قايمة تقييمات
  //         وفي GET /doctors ضيف rating (المتوسط) و ratingCount لكل دكتور.
  static List<Rating> _ratings = [];

  static Future<void> loadRatings() async {
    try {
      final p = await SharedPreferences.getInstance();
      final s = p.getString('ratings');
      _ratings = s == null
          ? []
          : (jsonDecode(s) as List)
              .map((e) => Rating.fromJson(Map<String, dynamic>.from(e)))
              .toList();
    } catch (_) {
      _ratings = [];
    }
  }

  static Future<void> _saveRatings() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        'ratings', jsonEncode(_ratings.map((e) => e.toJson()).toList()));
  }

  static (double, int) summarize(Iterable<Rating> l) {
    final list = l.toList();
    if (list.isEmpty) return (0.0, 0);
    final sum = list.fold<int>(0, (a, r) => a + r.stars);
    return (sum / list.length, list.length);
  }

  // متوسط تقييم دكتور (للقوايم)
  static (double, int) stats(Doctor d) => apiBase.isEmpty
      ? summarize(_ratings.where((r) => r.docId == d.id))
      : (d.rating, d.ratingCount);

  // تقييم المريض الحالي لدكتور (لو قيّمه قبل كده)
  static Rating? myRating(int docId, String phone) {
    for (final r in _ratings) {
      if (r.docId == docId && r.pPhone == phone) return r;
    }
    return null;
  }

  static Future<List<Rating>> ratingsFor(int docId) async {
    if (apiBase.isNotEmpty) {
      try {
        final r = await http
            .get(Uri.parse('$apiBase/doctors/$docId/ratings'))
            .timeout(const Duration(seconds: 12));
        if (r.statusCode == 200) {
          final l = (jsonDecode(utf8.decode(r.bodyBytes)) as List)
              .map((e) => Rating.fromJson(Map<String, dynamic>.from(e)))
              .toList()
            ..sort((a, b) => b.id.compareTo(a.id));
          return l;
        }
      } catch (_) {}
    }
    return _ratings.where((r) => r.docId == docId).toList()
      ..sort((a, b) => b.id.compareTo(a.id));
  }

  // المريض الواحد له تقييم واحد لكل دكتور (لو قيّم تاني بيتعدّل)
  static Future<void> addRating(Rating r) async {
    _ratings.removeWhere((x) => x.docId == r.docId && x.pPhone == r.pPhone);
    _ratings.add(r);
    await _saveRatings();
    if (apiBase.isNotEmpty) {
      try {
        await http
            .post(Uri.parse('$apiBase/doctors/${r.docId}/ratings'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(r.toJson()))
            .timeout(const Duration(seconds: 15));
      } catch (_) {}
      await load(); // تحديث المتوسطات من السيرفر
    }
  }
}
