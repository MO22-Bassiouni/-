import 'package:flutter/material.dart';

/// خانة كلمة المرور مع أيقونة العين (إظهار / إخفاء).
/// بتدير حالة الإظهار بنفسها، فبتشتغل في أي شاشة من غير متغيرات إضافية.
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'كلمة المرور',
    this.errorText,
    this.onChanged,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool visible = false;

  @override
  Widget build(BuildContext context) => TextField(
        controller: widget.controller,
        obscureText: !visible,
        enableSuggestions: false,
        autocorrect: false,
        keyboardType: TextInputType.visiblePassword,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            tooltip: visible ? 'إخفاء كلمة المرور' : 'إظهار كلمة المرور',
            onPressed: () => setState(() => visible = !visible),
            icon: Icon(visible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined),
          ),
          errorText: widget.errorText,
          errorMaxLines: 2,
        ),
      );
}
