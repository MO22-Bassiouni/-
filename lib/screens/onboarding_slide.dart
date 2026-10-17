import 'package:flutter/material.dart';
import 'onboarding_item.dart';

class OnboardingSlide extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingSlide({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.14),
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(.25), width: 1.5),
            ),
            child: Center(
              child: Container(
                width: 142,
                height: 142,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(42),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.12),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child:
                    Icon(item.icon, size: 76, color: const Color(0xFF0F8B8D)),
              ),
            ),
          ),
          const SizedBox(height: 38),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(.9),
              fontSize: 16,
              height: 1.9,
            ),
          ),
        ],
      ),
    );
  }
}
