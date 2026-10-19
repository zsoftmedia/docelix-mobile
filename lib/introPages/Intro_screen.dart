import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();

  int currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      'image': 'assets/img1.jpg',
      'title': 'Fractional shares',
      'description': 'Instead of having to buy an entire share, invest any amount you want.',
    },
    {
      'image': 'assets/img2.jpg',
      'title': 'Invest with ease',
      'description':
          'Discover simple and convenient ways to manage your investments.',
    },
    {
      'image': 'assets/img3.jpg',
      'title': 'Start investing',
      'description':
          'Take control of your financial future and start investing today.',
    },
  ];

  /// Keep intro as a readable centered column (not full tablet width).
  double _introMaxWidth(ResponsiveMetrics rs) {
    if (rs.isPhone) return rs.width;
    if (rs.isLandscape) {
      return rs.isLargeTablet ? 720.0 : 640.0;
    }
    if (rs.isCompactTablet) return 520.0;
    if (rs.isLargeTablet) return 560.0;
    return 540.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> nextPage() async {
    if (currentPage < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final box = GetStorage();
      box.write('intro_completed', true);
      Get.offNamed('/SplashScreen');
    }
  }

  void skipIntro() {
    final box = GetStorage();
    box.write('intro_completed', true);
    Get.offNamed('/SplashScreen');
  }

  Widget _buildIllustration(ResponsiveMetrics rs, String image) {
    final maxImage = rs.isPhone
        ? rs.wp(0.85)
        : (rs.isLandscape ? 360.0 : 420.0);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxImage,
          maxHeight: rs.isLandscape ? rs.hp(0.55) : rs.hp(0.42),
        ),
        child: Image.asset(image, width: double.infinity, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildCopy(ResponsiveMetrics rs, Map<String, String> page) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          page['title']!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: rs.sp(rs.isPhone ? 20 : 24),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF252525),
          ),
        ),
        SizedBox(height: rs.s(12)),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Text(
            page['description']!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: rs.sp(rs.isPhone ? 14 : 16),
              height: 1.5,
              color: const Color(0xFF555555),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage(ResponsiveMetrics rs, Map<String, String> page) {
    final hPad = rs.isPhone ? 25.0 : rs.s(28);

    // Landscape tablet+: illustration | copy side-by-side (less empty vertical gap).
    if (rs.isTabletOrLarger && rs.isLandscape) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: rs.s(16)),
        child: Row(
          children: [
            Expanded(flex: 5, child: _buildIllustration(rs, page['image']!)),
            SizedBox(width: rs.s(24)),
            Expanded(flex: 4, child: _buildCopy(rs, page)),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        children: [
          SizedBox(height: rs.s(24)),
          Expanded(flex: 6, child: _buildIllustration(rs, page['image']!)),
          Expanded(flex: 3, child: _buildCopy(rs, page)),
        ],
      ),
    );
  }

  Widget _buildFooter(ResponsiveMetrics rs) {
    final hPad = rs.isPhone ? 25.0 : rs.s(28);

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, rs.s(24)),
      child: Row(
        children: [
          SizedBox(
            width: rs.s(64),
            child: GestureDetector(
              onTap: skipIntro,
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: rs.sp(13),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF555555),
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) {
                final isSelected = currentPage == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.symmetric(horizontal: rs.s(3)),
                  width: isSelected ? rs.s(13) : rs.s(6),
                  height: rs.s(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFe46025)
                        : const Color(0xFF0b4268),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ),
          SizedBox(
            width: rs.s(88),
            child: GestureDetector(
              onTap: nextPage,
              child: Align(
                alignment: Alignment.centerRight,
                child: currentPage == pages.length - 1
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: rs.s(14),
                          vertical: rs.s(8),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFe46025),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: rs.sp(12),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.arrow_forward,
                        size: rs.s(22),
                        color: const Color(0xFF333333),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final maxWidth = _introMaxWidth(rs);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: pages.length,
                    onPageChanged: (index) {
                      setState(() => currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return _buildPage(rs, pages[index]);
                    },
                  ),
                ),
                _buildFooter(rs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
