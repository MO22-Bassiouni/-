import 'package:flutter/material.dart';
import '../core.dart';
import 'onboarding_item.dart';
import 'onboarding_slide.dart';
import 'welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _finishing = false;

  final List<OnboardingItem> _items = const [
    OnboardingItem(
      icon: Icons.search_rounded,
      title: 'دكتورك المناسب بسهولة',
      description:
          'ابحث عن الدكتور حسب التخصص والمحافظة والمنطقة، وشوف بيانات العيادة وسعر الكشف ومواعيد العمل.',
    ),
    OnboardingItem(
      icon: Icons.calendar_month_rounded,
      title: 'احجز في الوقت المناسب',
      description:
          'اختار الدكتور والميعاد المتاح، وحدد إذا كنت هتزور العيادة أو تحتاج زيارة منزلية لو الخدمة متاحة.',
    ),
    OnboardingItem(
      icon: Icons.event_available_rounded,
      title: 'تابع حجوزاتك بسهولة',
      description:
          'راجع تفاصيل حجزك وبيانات الدكتور من التطبيق. ولو أنت دكتور، تقدر تسجل عيادتك وتتابع الحجوزات.',
    ),
  ];

  Future<void> _finishOnboarding() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    await app.p.setBool('onboardingSeen', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const WelcomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage == _items.length - 1) {
      _finishOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF0A5B5D),
          image: DecorationImage(
            image: AssetImage('assets/splash_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Image.asset('assets/splash_logo.png',
                        width: 42, height: 42),
                    const SizedBox(width: 10),
                    const Text(
                      'صحتك',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        'تخطي',
                        style: TextStyle(
                          color: Colors.white.withOpacity(.9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (_, index) =>
                      OnboardingSlide(item: _items[index]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _items.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFFFF8A65)
                          : Colors.white.withOpacity(.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      SizedBox(
                        width: 112,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOutCubic,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withOpacity(.6),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('السابق'),
                        ),
                      )
                    else
                      const SizedBox(width: 112),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: FilledButton(
                          onPressed: _finishing ? null : _nextPage,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8A65),
                            foregroundColor: const Color(0xFF173536),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _currentPage == _items.length - 1
                                ? 'ابدأ الاستخدام'
                                : 'التالي',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
