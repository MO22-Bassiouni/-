import 'package:flutter/material.dart';
import '../core.dart';

class PickScreen extends StatefulWidget {
  final String title, hint;
  final String? subtitle;
  final int step;
  final bool bookingsBtn;
  final IconData icon;
  final List<String> items;
  final String Function(String) sub;
  final void Function(BuildContext, String) onPick;
  const PickScreen(
      {super.key,
      required this.title,
      this.subtitle,
      required this.step,
      this.bookingsBtn = false,
      required this.hint,
      required this.icon,
      required this.items,
      required this.sub,
      required this.onPick});
  @override
  State<PickScreen> createState() => _PickState();
}

class _PickState extends State<PickScreen> {
  String q = '';
  @override
  Widget build(BuildContext context) {
    final list = widget.items.where((e) => e.contains(q.trim())).toList();
    return Shell(
      title: widget.title,
      subtitle: widget.subtitle,
      step: widget.step,
      bookingsBtn: widget.bookingsBtn,
      profile: widget.bookingsBtn,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: TextField(
              onChanged: (v) => setState(() => q = v),
              decoration: InputDecoration(
                  hintText: widget.hint,
                  prefixIcon: const Icon(Icons.search_rounded))),
        ),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('مفيش نتائج'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (c, i) => Box(
                    onTap: () => widget.onPick(c, list[i]),
                    child: Row(children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                            color: Theme.of(c)
                                .colorScheme
                                .primary
                                .withOpacity(.12),
                            borderRadius: BorderRadius.circular(14)),
                        child: Icon(widget.icon,
                            color: Theme.of(c).colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(list[i],
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                            Text(widget.sub(list[i]),
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12)),
                          ])),
                      const Icon(Icons.chevron_left_rounded),
                    ]),
                  ),
                ),
        ),
      ]),
    );
  }
}
