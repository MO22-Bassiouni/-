import 'package:flutter/material.dart';
import '../core.dart';
import 'city_screen.dart';
import 'pick_screen.dart';

// ======================= 1) المحافظة =======================
class GovScreen extends StatelessWidget {
  const GovScreen({super.key});
  @override
  Widget build(BuildContext context) => PickScreen(
        title: 'أهلاً ${app.userName.split(' ').first} 👋',
        subtitle: 'اختار محافظتك عشان نوصلك لأقرب دكتور',
        step: 1,
        bookingsBtn: true,
        hint: 'ابحث عن محافظة...',
        icon: Icons.location_city_rounded,
        items: egypt.keys.toList(),
        sub: (g) => '${egypt[g]!.length} مدينة ومنطقة',
        onPick: (c, g) => push(c, CityScreen(gov: g)),
      );
}
