
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
      "image": "assets/img1.jpg",
      "title": "Fractional shares",
      "description":
      "Instead of having to buy an entire share, invest any amount you want.",
    },
    {
      "image": "assets/img2.jpg",
      "title": "Invest with ease",
      "description":
      "Discover simple and convenient ways to manage your investments.",
    },
    {
      "image": "assets/img3.jpg",
      "title": "Start investing",
      "description":
      "Take control of your financial future and start investing today.",
    },
  ];

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
      // Save intro completion
      final box = GetStorage();

      box.write('intro_completed', true);

      // Navigate to Login
      Get.offNamed('/SplashScreen');
    }
  }

  void skipIntro() {
    final box = GetStorage();

    box.write('intro_completed', true);

    Get.offNamed('/SplashScreen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [

            // ==============================
            // INTRO PAGES
            // ==============================
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,

                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },

                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [

                        const SizedBox(height: 25),

                        // ==============================
                        // IMAGE
                        // ==============================
                        Expanded(
                          flex: 6,
                          child: Center(
                            child: Image.asset(
                              pages[index]["image"]!,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        // ==============================
                        // TITLE + DESCRIPTION
                        // ==============================
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              Text(
                                pages[index]["title"]!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF252525),
                                ),
                              ),

                              const SizedBox(height: 12),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  pages[index]["description"]!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.5,
                                    color: Color(0xFF555555),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ==============================
            // BOTTOM NAVIGATION
            // ==============================
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 25),
              child: Row(
                children: [

                  // ==============================
                  // SKIP
                  // ==============================
                  SizedBox(
                    width: 55,
                    child: GestureDetector(
                      onTap: skipIntro,
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF555555),
                        ),
                      ),
                    ),
                  ),

                  // ==============================
                  // PAGE INDICATORS
                  // ==============================
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pages.length,
                            (index) {
                          final bool isSelected =
                              currentPage == index;

                          return AnimatedContainer(
                            duration:
                            const Duration(milliseconds: 250),

                            margin: const EdgeInsets.symmetric(
                              horizontal: 3,
                            ),

                            width: isSelected ? 13 : 6,
                            height: 6,

                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFe46025)
                                  : const Color(0xFF0b4268),
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // ==============================
                  // NEXT ARROW
                  // ==============================
                  SizedBox(
                    width: 80,
                    child: GestureDetector(
                      onTap: nextPage,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: currentPage == pages.length - 1
                            ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFe46025),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Submit",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        )
                            : const Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ),
                  /*SizedBox(
                    width: 55,
                    child: GestureDetector(
                      onTap: nextPage,
                      child: const Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ),*/
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}