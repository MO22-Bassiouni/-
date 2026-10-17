import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking.dart';
import '../services/repo.dart';
import '../utils/helpers.dart';

class AppState extends ChangeNotifier {
  ThemeMode mode = ThemeMode.system;
  List<Booking> allBookings = []; // كل الحجوزات المحفوظة على الجهاز
  // زيارات خلصت (الحجز اتمسح بعد يومه) عشان المريض يقدر يقيّم الدكتور
  List<Map<String, dynamic>> visits = [];
  late SharedPreferences p;
  String role = '', userName = '', userPhone = '', userPhoto = '';
  Map<String, dynamic>? myDoc;

  // حجوزات المريض الحالي بس (من غير الملغي أو المنتهي)
  List<Booking> get bookings => allBookings
      .where((b) => b.pPhone == userPhone && !b.cancelled && !b.expired)
      .toList();

  // زيارات سابقة لسه المريض ما قيّمهاش
  List<Map<String, dynamic>> get visitsToRate => visits
      .where((v) =>
          v['pPhone'] == userPhone &&
          Repo.myRating((v['docId'] as num).toInt(), userPhone) == null)
      .toList()
      .reversed
      .toList();

  // هل المريض الحالي حجز عند الدكتور ده قبل كده (حجز فعّال أو زيارة سابقة)؟
  // لو آه: بتظهر له نافذة التقييم لما يحجز تاني
  bool hasVisited(int docId) =>
      visits.any((v) => v['docId'] == docId && v['pPhone'] == userPhone) ||
      allBookings.any((b) =>
          b.docId == docId && b.pPhone == userPhone && !b.cancelled);

  Future<void> init() async {
    p = await SharedPreferences.getInstance();
    final m = p.getString('mode');
    mode = m == 'dark'
        ? ThemeMode.dark
        : m == 'light'
            ? ThemeMode.light
            : ThemeMode.system;
    role = p.getString('role') ?? '';
    userName = p.getString('uname') ?? '';
    userPhone = p.getString('uphone') ?? '';
    userPhoto = p.getString('uphoto') ?? '';
    try {
      final vs = p.getString('visits');
      if (vs != null) {
        visits = (jsonDecode(vs) as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {
      visits = [];
    }
    try {
      final md = p.getString('myDoc');
      if (md != null) myDoc = Map<String, dynamic>.from(jsonDecode(md));
    } catch (_) {
      myDoc = null;
    }
    try {
      final b = p.getString('bk');
      if (b != null) {
        allBookings = (jsonDecode(b) as List)
            .map((e) => Booking.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      allBookings = [];
    }
    purgeExpired();
    if (role == 'doctor' && myDoc == null) role = '';
  }

  void toggleTheme(BuildContext c) {
    final dark = Theme.of(c).brightness == Brightness.dark;
    mode = dark ? ThemeMode.light : ThemeMode.dark;
    p.setString('mode', dark ? 'light' : 'dark');
    notifyListeners();
  }

  void _persist() =>
      p.setString('bk', jsonEncode(allBookings.map((e) => e.toJson()).toList()));

  void save() {
    _persist();
    notifyListeners();
  }

  /// بيمسح الحجوزات اللي عدّى عليها اليوم (القديمة + الملغية بعد نهاية يوم الإلغاء).
  /// بيتنادى عند فتح التطبيق وكل ما شاشة الدكتور تتحدّث.
  /// بيرجّع true لو مسح حاجة.
  bool purgeExpired() {
    final gone = allBookings.where((b) => b.expired).toList();
    if (gone.isEmpty) return false;
    // الحجوزات اللي خلصت (مش الملغية) بتتسجل كزيارة سابقة عشان المريض يقيّم الدكتور
    for (final b in gone) {
      if (!b.cancelled && b.pPhone.isNotEmpty) {
        visits.removeWhere(
            (v) => v['docId'] == b.docId && v['pPhone'] == b.pPhone);
        visits.add({
          'docId': b.docId,
          'docName': b.docName,
          'spec': b.spec,
          'day': b.day,
          'pPhone': b.pPhone,
        });
      }
    }
    if (visits.length > 30) visits.removeRange(0, visits.length - 30);
    allBookings.removeWhere((b) => b.expired);
    _persist();
    p.setString('visits', jsonEncode(visits));
    return true;
  }

  // بيرجّع false لو الميعاد اتحجز قبل كده
  Future<bool> add(Booking b) async {
    if (await Repo.slotTaken(b.docId, b.day, b.hour)) return false;
    allBookings.add(b);
    save();
    final ok = await Repo.sendBooking(b);
    if (!ok) {
      allBookings.removeWhere((x) => x.id == b.id);
      save();
      return false;
    }
    return true;
  }

  void setPatient(String n, String ph, {String photo = ''}) {
    role = 'patient';
    userName = n;
    userPhone = ph;
    userPhoto = photo;
    p.setString('role', role);
    p.setString('uname', n);
    p.setString('uphone', ph);
    p.setString('uphoto', photo);
    notifyListeners();
  }

  // تغيير صورة المريض (قيمة فاضية = حذف الصورة)
  Future<void> setPatientPhoto(String photo) async {
    userPhoto = photo;
    await p.setString('uphoto', photo);
    await Repo.updatePatientPhoto(userName, userPhone, photo);
    notifyListeners();
  }

  // تغيير صورة الدكتور (بتظهر للمرضى فورًا)
  Future<void> setDoctorPhoto(String photo) async {
    if (myDoc == null) return;
    myDoc = {...myDoc!, 'photo': photo};
    await p.setString('myDoc', jsonEncode(myDoc));
    await Repo.updateDoctorPhoto(myDoc!['id'], photo);
    notifyListeners();
  }

  void refresh() => notifyListeners();

  void setDoctor(Map<String, dynamic> d) {
    role = 'doctor';
    myDoc = d;
    p.setString('role', role);
    p.setString('myDoc', jsonEncode(d));
    notifyListeners();
  }

  void logout() {
    role = '';
    userName = '';
    userPhone = '';
    userPhoto = '';
    myDoc = null;
    for (final k in ['role', 'uname', 'uphone', 'uphoto', 'myDoc']) {
      p.remove(k);
    }
    notifyListeners();
  }

  // إلغاء الحجز: بيفضل متسجل بحالة cancelled لحد نهاية اليوم عشان الدكتور يتبلّغ،
  // وبعدها بيتمسح أوتوماتيك (purgeExpired). والميعاد بيتفتح لمريض تاني فورًا.
  void cancel(int id) {
    final now = DateTime.now();
    for (final b in allBookings) {
      if (b.id == id) {
        b.status = 'cancelled';
        b.cancelledAt = stampNow(now);
        b.cancelledDate = isoDay(now);
      }
    }
    save();
    Repo.cancelBooking(id);
  }
}

final app = AppState();
