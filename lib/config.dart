import 'package:flutter/material.dart';

// ======================= الإعدادات =======================
// رابط الـ API بتاع الداشبورد. سيبه فاضي = كل حاجة بتتحفظ على الموبايل (بدون دكاترة تجريبية).
// مثال: 'https://your-domain.com/api'
const apiBase = '';
const payMethods = {
  'vf': ('فودافون كاش', Icons.phone_android),
  'ip': ('انستا باي', Icons.account_balance_wallet),
};
const dayNames = [
  'الاثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت',
  'الأحد'
];
const specs = <(String, IconData)>[
  ('باطنة', Icons.medical_services_outlined),
  ('أطفال', Icons.child_care),
  ('نساء وتوليد', Icons.pregnant_woman),
  ('قلب', Icons.favorite_border),
  ('عظام', Icons.accessibility_new),
  ('جلدية', Icons.face_retouching_natural),
  ('أسنان', Icons.mood),
  ('عيون', Icons.visibility_outlined),
  ('أنف وأذن وحنجرة', Icons.hearing),
  ('مخ وأعصاب', Icons.psychology),
  ('مسالك بولية', Icons.water_drop_outlined),
  ('جراحة عامة', Icons.healing),
  ('صدر', Icons.air),
  ('سكر وغدد', Icons.bloodtype_outlined),
  ('نفسي', Icons.self_improvement),
  ('تغذية', Icons.restaurant_menu),
  ('علاج طبيعي', Icons.directions_run),
  ('أورام', Icons.volunteer_activism),
  ('كلى', Icons.opacity),
  ('أشعة وتحاليل', Icons.biotech),
];
