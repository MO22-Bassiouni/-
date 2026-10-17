import 'package:flutter/material.dart';
import '../utils/photo.dart';

/// صورة شخص (دكتور / مريض). لو مفيش صورة بيظهر شكل افتراضي.
class UserAvatar extends StatelessWidget {
  final String? photo;
  final double size;
  final bool circle;
  const UserAvatar(this.photo, this.size, {super.key, this.circle = false});

  @override
  Widget build(BuildContext context) {
    final img = photoProvider(photo);
    return ClipRRect(
      borderRadius: BorderRadius.circular(circle ? size / 2 : size / 3),
      child: SizedBox(
        width: size,
        height: size,
        child: img != null
            ? Image(
                image: img,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => _Placeholder(size))
            : _Placeholder(size),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final double size;
  const _Placeholder(this.size);
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF0A6466), Color(0xFF2BBFC1)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft)),
        child: Icon(Icons.person_rounded, color: Colors.white, size: size * .55),
      );
}
