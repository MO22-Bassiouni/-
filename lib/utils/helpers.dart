import 'package:flutter/material.dart';
import '../config.dart';

String fmtHour(int h) =>
    '${h % 12 == 0 ? 12 : h % 12}:00 ${h < 12 ? 'ص' : 'م'}';
String isoDay(DateTime d) => d.toIso8601String().substring(0, 10);
String dayLabel(DateTime d) => '${dayNames[d.weekday - 1]} ${d.day}/${d.month}';
String stampNow(DateTime n) =>
    '${n.day}/${n.month}/${n.year} - ${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
bool isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;
Color cardColor(BuildContext c) =>
    isDark(c) ? const Color(0xFF142526) : Colors.white;

void push(BuildContext c, Widget w) => Navigator.push(
    c,
    PageRouteBuilder(
      pageBuilder: (_, a, __) => w,
      transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween(begin: const Offset(-0.15, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: a, child: child)),
    ));
