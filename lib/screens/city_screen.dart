import 'package:flutter/material.dart';
import '../core.dart';
import 'pick_screen.dart';
import 'spec_screen.dart';

// ======================= 2) البلد / المدينة =======================
class CityScreen extends StatelessWidget {
  final String gov;
  const CityScreen({super.key, required this.gov});
  @override
  Widget build(BuildContext context) => PickScreen(
        title: gov,
        subtitle: 'اختار البلد أو المنطقة',
        step: 2,
        hint: 'ابحث عن بلد أو منطقة...',
        icon: Icons.place_rounded,
        items: egypt[gov]!,
        sub: (_) => gov,
        onPick: (c, city) => push(c, SpecScreen(gov: gov, city: city)),
      );
}
