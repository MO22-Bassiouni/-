import 'package:flutter/material.dart';
import '../core.dart';
import '../screens/bookings_screen.dart';

class Shell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int? step; // من 1 إلى 4
  final Widget child;
  final bool bookingsBtn, profile;
  const Shell(
      {super.key,
      required this.title,
      this.subtitle,
      this.step,
      required this.child,
      this.bookingsBtn = false,
      this.profile = false});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return Scaffold(
      body: Column(children: [
        Container(
          padding: EdgeInsets.fromLTRB(
              16, MediaQuery.of(context).padding.top + 10, 16, 22),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF0A5B5D), Color(0xFF12A3A5)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (canPop)
                _hb(Icons.arrow_forward_rounded, () => Navigator.pop(context)),
              const Spacer(),
              if (bookingsBtn) ...[
                _hb(Icons.event_note_rounded,
                    () => push(context, const BookingsScreen())),
                const SizedBox(width: 8)
              ],
              if (profile) ...[
                _hb(Icons.person_rounded, () => profileSheet(context)),
                const SizedBox(width: 8)
              ],
              _hb(
                  isDark(context)
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  () => app.toggleTheme(context)),
            ]),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800)),
            if (subtitle != null)
              Text(subtitle!,
                  style: TextStyle(
                      color: Colors.white.withOpacity(.85), fontSize: 14)),
            if (step != null) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                    value: step! / 4,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    color: const Color(0xFFFF8A65)),
              ),
            ],
          ]),
        ),
        Expanded(child: child),
      ]),
    );
  }

  Widget _hb(IconData i, VoidCallback f) => Material(
        color: Colors.white.withOpacity(.18),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: f,
            child: SizedBox(
                width: 42, height: 42, child: Icon(i, color: Colors.white))),
      );
}
