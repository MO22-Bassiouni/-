import 'package:flutter/material.dart';
import '../core.dart';

// تقييمات دكتور (بيشوفها المرضى وهما بيحجزوا، والدكتور نفسه)
class RatingsScreen extends StatefulWidget {
  final int docId;
  final String docName;
  const RatingsScreen({super.key, required this.docId, required this.docName});
  @override
  State<RatingsScreen> createState() => _RatingsState();
}

class _RatingsState extends State<RatingsScreen> {
  late Future<List<Rating>> f = Repo.ratingsFor(widget.docId);

  @override
  Widget build(BuildContext context) => Shell(
        title: 'التقييمات',
        subtitle: widget.docName,
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              f = Repo.ratingsFor(widget.docId);
            });
            await f;
          },
          child: FutureBuilder<List<Rating>>(
            future: f,
            builder: (c, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = snap.data!;
              final (avg, n) = Repo.summarize(list);
              return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    Box(
                      pad: const EdgeInsets.all(18),
                      child: Column(children: [
                        Text(n == 0 ? '-' : avg.toStringAsFixed(1),
                            style: const TextStyle(
                                fontSize: 44, fontWeight: FontWeight.w800)),
                        StarsRow(avg, size: 26),
                        const SizedBox(height: 6),
                        Text(n == 0 ? 'لا توجد تقييمات بعد' : '$n تقييم',
                            style: TextStyle(color: Colors.grey.shade600)),
                      ]),
                    ),
                    for (final r in list)
                      Box(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                const Icon(Icons.account_circle_outlined,
                                    size: 22),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(
                                        r.pName.isEmpty
                                            ? 'مريض'
                                            : r.pName.split(' ').first,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800))),
                                StarsRow(r.stars.toDouble(), size: 16),
                              ]),
                              if (r.comment.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(r.comment,
                                    style: const TextStyle(height: 1.6)),
                              ],
                              const SizedBox(height: 6),
                              Text(r.at,
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 11)),
                            ]),
                      ),
                  ]);
            },
          ),
        ),
      );
}
