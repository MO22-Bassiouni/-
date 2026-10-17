import 'package:flutter/material.dart';
import '../utils/helpers.dart';

class Box extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets pad;
  const Box(
      {super.key,
      required this.child,
      this.onTap,
      this.pad = const EdgeInsets.all(14)});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark(context) ? .3 : .06),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: Padding(padding: pad, child: child)),
        ),
      );
}
