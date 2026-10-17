import 'package:flutter/material.dart';
import '../core.dart';
import 'visit_type_screen.dart';

// ======================= 4) الدكاترة =======================
class DoctorsScreen extends StatelessWidget {
  final String gov, city, spec;
  const DoctorsScreen(
      {super.key, required this.gov, required this.city, required this.spec});
  @override
  Widget build(BuildContext context) {
    // الدكاترة المفعّلين فقط (active) في نفس المحافظة والتخصص، ودكاترة نفس البلد أولاً
    final list = Repo.all
        .where((d) => d.active && d.gov == gov && d.spec == spec)
        .toList()
      ..sort((a, b) => (b.city == city ? 1 : 0) - (a.city == city ? 1 : 0));
    return Shell(
      title: spec,
      subtitle: '📍 $city - $gov',
      step: 4,
      child: list.isEmpty
          ? Center(
              child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.search_off_rounded,
                    size: 64, color: Colors.grey.shade500),
                const SizedBox(height: 10),
                const Text('مفيش دكاترة متاحين في التخصص ده في محافظتك حاليًا',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16)),
              ]),
            ))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (c, i) {
                final d = list[i];
                final pr = Theme.of(c).colorScheme.primary;
                return Box(
                  onTap: () => push(c, VisitTypeScreen(doc: d)),
                  child: Row(children: [
                    DoctorAvatar(d, 62),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(d.name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800)),
                          Text(
                              d.years > 0
                                  ? '${d.spec} • خبرة ${d.years} سنة'
                                  : d.spec,
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12)),
                          const SizedBox(height: 4),
                          Row(children: [
                            Icon(Icons.place_outlined, size: 14, color: pr),
                            Text(' ${d.city}',
                                style: TextStyle(
                                    color: pr,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ]),
                          const SizedBox(height: 4),
                          RatingBadge(doc: d),
                        ])),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFF8A65).withOpacity(.15),
                          borderRadius: BorderRadius.circular(14)),
                      child: Text('${d.fee} ج',
                          style: const TextStyle(
                              color: Color(0xFFE5633D),
                              fontWeight: FontWeight.w800)),
                    ),
                  ]),
                );
              },
            ),
    );
  }
}
