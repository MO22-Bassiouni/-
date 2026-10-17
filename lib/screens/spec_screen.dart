import 'package:flutter/material.dart';
import '../core.dart';
import 'doctors_screen.dart';

// ======================= 3) التخصص =======================
class SpecScreen extends StatelessWidget {
  final String gov, city;
  const SpecScreen({super.key, required this.gov, required this.city});
  @override
  Widget build(BuildContext context) {
    final pr = Theme.of(context).colorScheme.primary;
    return Shell(
      title: 'اختار التخصص',
      subtitle: '📍 $city - $gov',
      step: 3,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15),
        itemCount: specs.length,
        itemBuilder: (c, i) {
          final s = specs[i];
          final n = Repo.all
              .where((d) => d.active && d.gov == gov && d.spec == s.$1)
              .length;
          return Container(
            decoration: BoxDecoration(
              color: cardColor(c),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(isDark(c) ? .3 : .06),
                    blurRadius: 14,
                    offset: const Offset(0, 5))
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () =>
                    push(c, DoctorsScreen(gov: gov, city: city, spec: s.$1)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                                pr.withOpacity(.25),
                                pr.withOpacity(.08)
                              ],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(s.$2, color: pr, size: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(s.$1,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center),
                      Text(n == 0 ? 'لا يوجد أطباء' : '$n دكتور',
                          style: TextStyle(
                              fontSize: 11, color: n == 0 ? Colors.grey : pr)),
                    ]),
              ),
            ),
          );
        },
      ),
    );
  }
}
