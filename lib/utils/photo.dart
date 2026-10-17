import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final Map<String, Uint8List> _photoCache = {};

/// بيحوّل قيمة الصورة (رابط http أو base64) لـ ImageProvider. بيرجّع null لو مفيش صورة.
ImageProvider? photoProvider(String? s) {
  if (s == null || s.trim().isEmpty) return null;
  if (s.startsWith('http')) return NetworkImage(s);
  try {
    if (_photoCache.length > 40) _photoCache.clear();
    final bytes = _photoCache.putIfAbsent(
        s, () => base64Decode(s.contains(',') ? s.split(',').last : s));
    return MemoryImage(bytes);
  } catch (_) {
    return null;
  }
}

/// بيفتح معرض الصور / ملفات الجهاز ويرجّع الصورة مصغّرة كـ base64 (أو null لو لغى).
Future<String?> pickPhoto() async {
  try {
    final x = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85);
    if (x == null) return null;
    final bytes = await x.readAsBytes();
    // تصغير لحجم صغير عشان التخزين يبقى خفيف على كل الأجهزة
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 300);
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) return base64Encode(bytes);
    return base64Encode(data.buffer.asUint8List());
  } catch (_) {
    return null;
  }
}
