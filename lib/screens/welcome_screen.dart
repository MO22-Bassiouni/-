import 'package:flutter/material.dart';
import '../core.dart';
import 'account_choice_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Widget _opt(IconData i, String t, String s, VoidCallback f) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(.96),
            borderRadius: BorderRadius.circular(22)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: f,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                      color: const Color(0xFF0F8B8D).withOpacity(.12),
                      borderRadius: BorderRadius.circular(16)),
                  child: Icon(i, color: const Color(0xFF0F8B8D), size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(t,
                          style: const TextStyle(
                              color: Color(0xFF0D2A2B),
                              fontSize: 18,
                              fontWeight: FontWeight.w800)),
                      Text(s,
                          style: const TextStyle(
                              color: Color(0xFF5D7576), fontSize: 12)),
                    ])),
                const Icon(Icons.chevron_left_rounded,
                    color: Color(0xFF5D7576)),
              ]),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
              color: Color(0xFF0A5B5D),
              image: DecorationImage(
                  image: AssetImage('assets/splash_bg.png'),
                  fit: BoxFit.cover)),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const Spacer(),
                Image.asset('assets/splash_logo.png', width: 130, height: 130),
                const Text('صحتك',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('سجّل دخولك كـ',
                    style: TextStyle(
                        color: Colors.white.withOpacity(.85), fontSize: 16)),
                const SizedBox(height: 26),
                _opt(
                    Icons.person_rounded,
                    'مريض',
                    'احجز عند أقرب دكتور',
                    () => push(
                        context, const AccountChoiceScreen(role: 'patient'))),
                _opt(
                    Icons.medical_services_rounded,
                    'دكتور',
                    'سجّل عيادتك واستقبل الحجوزات',
                    () => push(
                        context, const AccountChoiceScreen(role: 'doctor'))),
                const Spacer(),
              ]),
            ),
          ),
        ),
      );
}
