import 'package:flutter/material.dart';
import '../core.dart';
import 'doctor_reg_screen.dart';
import 'login_screen.dart';
import 'patient_reg_screen.dart';

class AccountChoiceScreen extends StatelessWidget {
  final String role;
  const AccountChoiceScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final patient = role == 'patient';
    return Shell(
      title: patient ? 'حساب المريض' : 'حساب الدكتور',
      subtitle: 'اختار هتكمل إزاي',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          BigBtn(
              'لدي حساب بالفعل', () => push(context, LoginScreen(role: role))),
          const SizedBox(height: 14),
          BigBtn(
              'ليس لدي حساب - تسجيل لأول مرة',
              () => push(context,
                  patient ? const PatientRegScreen() : const DoctorRegScreen()),
              outline: true),
        ]),
      ),
    );
  }
}
