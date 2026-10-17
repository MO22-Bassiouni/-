import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core.dart';
import 'doctor_home_screen.dart';
import 'gov_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({super.key, required this.role});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final name = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  bool submitted = false;

  String? get nameError =>
      name.text.trim().isEmpty ? 'اكتب الاسم المسجل به' : null;
  String? get passwordError =>
      password.text.isEmpty ? 'اكتب كلمة المرور' : null;

  Future<void> login() async {
    setState(() => submitted = true);
    if (nameError != null || passwordError != null) return;
    setState(() => busy = true);
    final p = await SharedPreferences.getInstance();
    final key = widget.role == 'patient' ? 'patientAccounts' : 'doctorAccounts';
    final raw = p.getString(key);
    final accounts = raw == null ? <dynamic>[] : jsonDecode(raw) as List;
    Map<String, dynamic>? account;
    for (final item in accounts) {
      final a = Map<String, dynamic>.from(item as Map);
      if ('${a['name']}'.trim().toLowerCase() ==
              name.text.trim().toLowerCase() &&
          '${a['password']}' == password.text) {
        account = a;
        break;
      }
    }
    if (!mounted) return;
    setState(() => busy = false);
    if (account == null) {
      setState(() => submitted = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('الاسم أو كلمة المرور غير صحيحة، أو الحساب غير مسجل')));
      return;
    }
    if (widget.role == 'patient') {
      app.setPatient('${account['name']}', '${account['phone']}',
          photo: '${account['photo'] ?? ''}');
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const GovScreen()), (r) => false);
    } else {
      final doc = Map<String, dynamic>.from(account['doctor'] as Map);
      app.setDoctor(doc);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
          (r) => false);
    }
  }

  @override
  void dispose() {
    name.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Shell(
        title: 'تسجيل الدخول',
        subtitle: widget.role == 'patient' ? 'دخول المريض' : 'دخول الدكتور',
        child: ListView(padding: const EdgeInsets.all(16), children: [
          const SizedBox(height: 20),
          TextField(
            controller: name,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'الاسم المسجل به',
              prefixIcon: const Icon(Icons.person_outline),
              errorText: submitted ? nameError : null,
            ),
          ),
          const SizedBox(height: 14),
          PasswordField(
            controller: password,
            onChanged: (_) => setState(() {}),
            errorText: submitted ? passwordError : null,
          ),
          const SizedBox(height: 20),
          BigBtn(busy ? 'جاري الدخول...' : 'دخول', busy ? null : login),
        ]),
      );
}
