import 'package:flutter/material.dart';
import '../core.dart';
import '../widgets/beat_painter.dart';
import 'doctor_home_screen.dart';
import 'gov_screen.dart';
import 'onboarding_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2400))
    ..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => app.role == 'patient'
              ? const GovScreen()
              : app.role == 'doctor'
                  ? const DoctorHomeScreen()
                  : (app.p.getBool('onboardingSeen') ?? false)
                      ? const WelcomeScreen()
                      : const OnboardingScreen(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logo = CurvedAnimation(
        parent: c, curve: const Interval(0, .45, curve: Curves.elasticOut));
    final text = CurvedAnimation(
        parent: c, curve: const Interval(.35, .7, curve: Curves.easeOut));
    final beat = CurvedAnimation(
        parent: c, curve: const Interval(.4, 1, curve: Curves.easeInOut));
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF0A5B5D),
          image: DecorationImage(
              image: AssetImage('assets/splash_bg.png'), fit: BoxFit.cover),
        ),
        child: Stack(children: [
          Center(
            child: AnimatedBuilder(
              animation: c,
              builder: (_, __) =>
                  Column(mainAxisSize: MainAxisSize.min, children: [
                Transform.scale(
                  scale: logo.value.clamp(0.0, 1.2),
                  child: Image.asset('assets/splash_logo.png',
                      width: 190, height: 190),
                ),
                const SizedBox(height: 26),
                Opacity(
                  opacity: text.value,
                  child: Transform.translate(
                    offset: Offset(0, 16 * (1 - text.value)),
                    child: Column(children: [
                      const Text('صحتك',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 44,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('احجز دكتورك أونلاين في أي مكان في مصر',
                          style: TextStyle(
                              color: Colors.white.withOpacity(.85),
                              fontSize: 15)),
                    ]),
                  ),
                ),
                const SizedBox(height: 34),
                CustomPaint(
                    size: const Size(220, 56),
                    painter: BeatPainter(beat.value)),
              ]),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
                child: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                  strokeWidth: 3, color: Colors.white.withOpacity(.8)),
            )),
          ),
        ]),
      ),
    );
  }
}
