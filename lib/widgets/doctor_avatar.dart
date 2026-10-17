import 'package:flutter/material.dart';
import '../models/doctor.dart';
import 'user_avatar.dart';

class DoctorAvatar extends StatelessWidget {
  final Doctor doc;
  final double size;
  const DoctorAvatar(this.doc, this.size, {super.key});

  @override
  Widget build(BuildContext context) => UserAvatar(doc.photo, size);
}
