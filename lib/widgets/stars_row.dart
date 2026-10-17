import 'package:flutter/material.dart';

/// نجوم التقييم. لو onChanged موجودة بتبقى قابلة للضغط (لاختيار التقييم).
class StarsRow extends StatelessWidget {
  final double rating;
  final double size;
  final ValueChanged<int>? onChanged;
  const StarsRow(this.rating, {super.key, this.size = 20, this.onChanged});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFB300);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (int i = 1; i <= 5; i++)
        GestureDetector(
          onTap: onChanged == null ? null : () => onChanged!(i),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: onChanged == null ? 0 : 3),
            child: Icon(
              rating >= i
                  ? Icons.star_rounded
                  : rating >= i - .5
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded,
              color: gold,
              size: size,
            ),
          ),
        ),
    ]);
  }
}
