import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:shared_preferences/shared_preferences.dart';
import '../core.dart';
import 'doctor_home_screen.dart';
import 'map_pick_screen.dart';
import 'map_preview.dart';

class DoctorRegScreen extends StatefulWidget {
  const DoctorRegScreen({super.key});
  @override
  State<DoctorRegScreen> createState() => _DocRegState();
}

class _DocRegState extends State<DoctorRegScreen> {
  final name = TextEditingController(),
      fee = TextEditingController(),
      years = TextEditingController();
  final vf = TextEditingController(),
      ip = TextEditingController(),
      addr = TextEditingController(),
      password = TextEditingController();
  String? spec, gov, city;
  final Set<int> days = {};
  int from = 10, to = 18;
  bool busy = false;
  bool shown = false; // بيتفعّل لما يدوس "تسجيل" والبيانات ناقصة
  LatLng? pos;

  // ---------- رسائل الأخطاء (null = الخانة سليمة) ----------
  String? get eName => name.text.trim().length >= 3
      ? null
      : 'اكتب اسم الدكتور (3 حروف على الأقل)';
  String? get eSpec => spec != null ? null : 'اختار التخصص';
  String? get eGov => gov != null ? null : 'اختار المحافظة';
  String? get eCity => city != null ? null : 'اختار البلد / المنطقة';
  String? get eAddr =>
      addr.text.trim().isNotEmpty ? null : 'اكتب عنوان العيادة بالتفصيل';
  String? get ePos => pos != null ? null : 'لازم تحدد مكان العيادة على الخريطة';
  String? get eFee => (int.tryParse(fee.text.trim()) ?? 0) > 0
      ? null
      : 'اكتب سعر الكشف (أرقام بس)';
  String? get eVf {
    final v = vf.text.trim();
    if (v.isEmpty) return null;
    return RegExp(r'^01[0-9]{9}$').hasMatch(v)
        ? null
        : 'الرقم لازم يكون 11 رقم ويبدأ بـ 01 (انت كاتب ${v.length})';
  }

  String? get ePay => (vf.text.trim().isNotEmpty || ip.text.trim().isNotEmpty)
      ? null
      : 'لازم تكتب رقم فودافون كاش أو عنوان انستا باي';
  String? get eDays => days.isNotEmpty ? null : 'اختار يوم شغل واحد على الأقل';
  String? get eHours =>
      from < to ? null : 'وقت البداية لازم يكون قبل وقت النهاية';
  String? get ePassword =>
      password.text.length >= 6 ? null : 'اكتب كلمة مرور 6 أحرف على الأقل';

  bool get ok => [
        eName,
        eSpec,
        eGov,
        eCity,
        eAddr,
        ePos,
        eFee,
        eVf,
        ePay,
        eDays,
        eHours,
        ePassword
      ].every((e) => e == null);

  // الأخطاء بتظهر بعد الضغط على تسجيل، أو فورًا لو الحقل متكتب غلط
  String? vis(String? e, {bool live = false}) =>
      (e != null && (shown || live)) ? e : null;

  Future<void> submit() async {
    setState(() => busy = true);
    final res = await Repo.registerDoctor({
      'name': name.text.trim(),
      'password': password.text,
      'spec': spec,
      'gov': gov,
      'city': city,
      'fee': int.parse(fee.text.trim()),
      'years': int.tryParse(years.text.trim()) ?? 0,
      'days': (days.toList()..sort()),
      'from': from,
      'to': to,
      'vf': vf.text.trim(),
      'ip': ip.text.trim(),
      'addr': addr.text.trim(),
      'lat': pos!.latitude,
      'lng': pos!.longitude,
    });
    if (!mounted) return;
    setState(() => busy = false);
    if (res == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تعذر الإرسال. تأكد من الإنترنت وجرّب تاني')));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final rawAccounts = prefs.getString('doctorAccounts');
    final accounts =
        rawAccounts == null ? <dynamic>[] : jsonDecode(rawAccounts) as List;
    accounts.removeWhere((a) =>
        '${a['name']}'.trim().toLowerCase() == name.text.trim().toLowerCase());
    accounts.add(
        {'name': name.text.trim(), 'password': password.text, 'doctor': res});
    await prefs.setString('doctorAccounts', jsonEncode(accounts));
    app.setDoctor(res);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
        (r) => false);
  }

  void onRegister() {
    if (!ok) {
      setState(() => shown = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('في بيانات ناقصة أو غلط، راجع الرسائل الحمرا')));
      return;
    }
    submit();
  }

  Future<void> pickLoc() async {
    final p = await Navigator.push<LatLng>(
        context,
        MaterialPageRoute(
            builder: (_) =>
                MapPickScreen(title: 'حدد مكان العيادة', start: pos)));
    if (p != null) setState(() => pos = p);
  }

  Widget tf(String l, TextEditingController c, IconData i,
          {TextInputType? kb, int? max, String? error}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          keyboardType: kb,
          maxLength: max,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
              labelText: l,
              prefixIcon: Icon(i),
              counterText: '',
              errorText: error,
              errorMaxLines: 2),
        ),
      );

  Widget dd<T>(String l, T? v, List<T> items, String Function(T) t,
          void Function(T?) f,
          {String? error}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<T>(
          key: ValueKey('$l|$v|${error != null}'),
          value: v,
          isExpanded: true,
          decoration:
              InputDecoration(labelText: l, errorText: error, errorMaxLines: 2),
          items: [
            for (final i in items)
              DropdownMenuItem<T>(value: i, child: Text(t(i)))
          ],
          onChanged: f,
        ),
      );

  Widget h(String t) => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Text(t,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      );

  Widget errLine(String? e) => e == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 4, right: 4, left: 4),
          child: Row(children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.red, size: 16),
            const SizedBox(width: 6),
            Expanded(
                child: Text(e,
                    style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600))),
          ]),
        );

  @override
  void dispose() {
    name.dispose();
    fee.dispose();
    years.dispose();
    vf.dispose();
    ip.dispose();
    addr.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = [for (int i = 6; i <= 23; i++) i];
    return Shell(
      title: 'تسجيل دكتور',
      subtitle: apiBase.isEmpty
          ? 'بعد التسجيل هتظهر للمرضى على طول'
          : 'بعد التسجيل حسابك هيتراجع وبعدها يظهر للمرضى',
      child: ListView(padding: const EdgeInsets.all(16), children: [
        tf('اسم الدكتور', name, Icons.person_outline_rounded,
            error: vis(eName)),
        dd<String>('التخصص', spec, [for (final s in specs) s.$1], (x) => x,
            (v) => setState(() => spec = v),
            error: vis(eSpec)),
        dd<String>(
            'المحافظة',
            gov,
            egypt.keys.toList(),
            (x) => x,
            (v) => setState(() {
                  gov = v;
                  city = null;
                }),
            error: vis(eGov)),
        if (gov != null)
          dd<String>('البلد / المنطقة', city, egypt[gov]!.toSet().toList(),
              (x) => x, (v) => setState(() => city = v),
              error: vis(eCity)),
        h('مكان العيادة'),
        tf('عنوان العيادة بالتفصيل (شارع، علامة مميزة، دور)', addr,
            Icons.location_on_outlined,
            error: vis(eAddr)),
        BigBtn(
            pos == null
                ? 'حدد مكان العيادة على الخريطة'
                : 'تم تحديد الموقع ✅ (اضغط للتغيير)',
            pickLoc,
            outline: true),
        errLine(vis(ePos)),
        if (pos != null) ...[
          const SizedBox(height: 10),
          MapPreview(lat: pos!.latitude, lng: pos!.longitude),
        ],
        h('سعر الكشف والخبرة'),
        tf('سعر الكشف (جنيه)', fee, Icons.payments_outlined,
            kb: TextInputType.number, max: 5, error: vis(eFee)),
        tf('سنين الخبرة (اختياري)', years, Icons.workspace_premium_outlined,
            kb: TextInputType.number, max: 2),
        h('الرقم اللي هتستقبل عليه فلوس الكشف'),
        tf('رقم فودافون كاش', vf, Icons.phone_android,
            kb: TextInputType.phone, max: 11, error: vis(eVf, live: true)),
        tf('عنوان انستا باي', ip, Icons.account_balance_wallet_outlined),
        errLine(vis(ePay)),
        if (ePay == null || !shown)
          Text('لازم تكتب واحد منهم على الأقل',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        h('أيام الشغل'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (int i = 0; i < 7; i++)
            FilterChip(
              label: Text(dayNames[i]),
              selected: days.contains(i + 1),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              onSelected: (s) =>
                  setState(() => s ? days.add(i + 1) : days.remove(i + 1)),
            ),
        ]),
        errLine(vis(eDays)),
        h('ساعات الشغل'),
        Row(children: [
          Expanded(
              child: dd<int>('من', from, hours, fmtHour,
                  (v) => setState(() => from = v!))),
          const SizedBox(width: 10),
          Expanded(
              child: dd<int>(
                  'إلى', to, hours, fmtHour, (v) => setState(() => to = v!))),
        ]),
        errLine(vis(eHours, live: true)),
        const SizedBox(height: 8),
        PasswordField(
          controller: password,
          label: 'كلمة المرور (6 أحرف على الأقل)',
          onChanged: (_) => setState(() {}),
          errorText: vis(ePassword),
        ),
        const SizedBox(height: 12),
        BigBtn(busy ? 'جاري الإرسال...' : 'تسجيل', busy ? null : onRegister),
        const SizedBox(height: 16),
      ]),
    );
  }
}
