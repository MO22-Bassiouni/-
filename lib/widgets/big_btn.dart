import 'package:flutter/material.dart';

class BigBtn extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool outline;
  final Color? color;
  const BigBtn(this.text, this.onTap,
      {super.key, this.outline = false, this.color});
  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: outline
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: c, width: 1.5),
                  foregroundColor: c,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))),
              onPressed: onTap,
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)))
          : FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: c,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))),
              onPressed: onTap,
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800))),
    );
  }
}
