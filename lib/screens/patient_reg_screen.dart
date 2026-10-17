import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core.dart';
import 'gov_screen.dart';

class PatientRegScreen extends StatefulWidget {
  const PatientRegScreen({super.key});
  @override
  State<PatientRegScreen> createState() => _PatientRegState();
}

class _PatientRegState extends State<PatientRegScreen> {
  final n = TextEditingController(),
      ph = TextEditingController(),
      pw = TextEditingController();
  bool submitted = false;

  String? get eName =>
      n.text.trim().length >= 3 ? null : 'اكتب الاسم (3 حروف على الأقل)';
  String? get ePhone => RegExp(r'^01[0-9]{9}$').hasMatch(ph.text.trim())
      ? null
      : 'اكتب رقم موبايل صحيح من 11 رقم ويبدأ بـ 01';
  String? get ePassword =>
      pw.text.length >= 6 ? null : 'كلمة المرور لازم تكون 6 أحرف على الأقل';
  bool get ok => eName == null && ePhone == null && ePassword == null;
  String? vis(String? error) => (submitted && error != null) ? error : null;

  @override
  void dispose() {
    n.dispose();
    ph.dispose();
    pw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Shell(
        title: 'بياناتك',
        subtitle: 'اسمك ورقمك هيظهروا للدكتور وقت الحجز بس',
        child: ListView(padding: const EdgeInsets.all(16), children: [
          const SizedBox(height: 10),
          TextField(
            controller: n,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'الاسم',
              prefixIcon: const Icon(Icons.person_outline_rounded),
              errorText: vis(eName),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ph,
            keyboardType: TextInputType.phone,
            maxLength: 11,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'رقم الموبايل',
              prefixIcon: const Icon(Icons.phone_rounded),
              counterText: '',
              errorText: vis(ePhone),
            ),
          ),
          const SizedBox(height: 12),
          PasswordField(
            controller: pw,
            label: 'كلمة المرور (6 أحرف على الأقل)',
            onChanged: (_) => setState(() {}),
            errorText: vis(ePassword),
          ),
          const SizedBox(height: 16),
          BigBtn('تسجيل حساب', () async {
            setState(() => submitted = true);
            if (!ok) return;
            final prefs = await SharedPreferences.getInstance();
            final raw = prefs.getString('patientAccounts');
            final accounts =
                raw == null ? <dynamic>[] : jsonDecode(raw) as List;
            accounts.removeWhere((a) =>
                '${a['name']}'.trim().toLowerCase() ==
                n.text.trim().toLowerCase());
            accounts.add({
              'name': n.text.trim(),
              'phone': ph.text.trim(),
              'password': pw.text
            });
            await prefs.setString('patientAccounts', jsonEncode(accounts));
            app.setPatient(n.text.trim(), ph.text.trim());
            Repo.registerPatient(n.text.trim(), ph.text.trim());
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const GovScreen()),
                (r) => false);
          }),
        ]),
      );
}
