import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../core.dart';
import 'map_pick_screen.dart';
import 'ratings_screen.dart';
import 'slot_screen.dart';

// ======================= نوع الحجز: عيادة / بيت =======================
class VisitTypeScreen extends StatefulWidget {
  final Doctor doc;
  const VisitTypeScreen({super.key, required this.doc});
  @override
  State<VisitTypeScreen> createState() => _VisitTypeState();
}

class _VisitTypeState extends State<VisitTypeScreen> {
  Doctor get doc => widget.doc;

  bool get canRate => app.hasVisited(doc.id);
  bool get rated => Repo.myRating(doc.id, app.userPhone) != null;

  @override
  void initState() {
    super.initState();
    // لو المريض زار الدكتور قبل كده ولسه ما قيّمهوش: نطلب منه التقييم وهو جاي يحجز تاني
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && canRate && !rated) rate();
    });
  }

  Future<void> rate() async {
    await showRateSheet(context, docId: doc.id, docName: doc.name);
    if (mounted) setState(() {});
  }

  Widget _opt(BuildContext c, IconData i, String t, String s, VoidCallback f) {
    final pr = Theme.of(c).colorScheme.primary;
    return Box(
      onTap: f,
      pad: const EdgeInsets.all(18),
      child: Row(children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
              color: pr.withOpacity(.12),
              borderRadius: BorderRadius.circular(16)),
          child: Icon(i, color: pr, size: 30),
        ),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          Text(s, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ])),
        const Icon(Icons.chevron_left_rounded),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) => Shell(
        title: 'نوع الحجز',
        subtitle: doc.name,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Box(
            onTap: () => push(
                context, RatingsScreen(docId: doc.id, docName: doc.name)),
            child: Row(children: [
              DoctorAvatar(doc, 62),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(doc.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    Text(doc.spec,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                    const SizedBox(height: 4),
                    RatingBadge(doc: doc),
                  ])),
              const Icon(Icons.chevron_left_rounded),
            ]),
          ),
          if (canRate)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.star_rounded, color: Color(0xFFFFB300)),
                  label: Text(rated ? 'عدّل تقييمك للدكتور' : 'قيّم الدكتور'),
                  onPressed: rate,
                ),
              ),
            ),
          _opt(
              context,
              Icons.local_hospital_rounded,
              'حجز في العيادة',
              doc.addr.isEmpty ? '${doc.city} - ${doc.gov}' : doc.addr,
              () => push(context, SlotScreen(doc: doc))),
          _opt(context, Icons.home_rounded, 'حجز في البيت',
              'هتحدد موقع بيتك والدفع كاش لما الدكتور يوصلك', () async {
            final p = await Navigator.push<LatLng>(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const MapPickScreen(title: 'حدد موقع بيتك')));
            if (p != null && context.mounted) {
              push(context, SlotScreen(doc: doc, type: 'home', pos: p));
            }
          }),
        ]),
      );
}
