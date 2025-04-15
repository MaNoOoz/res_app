import 'package:double_tap_to_exit/double_tap_to_exit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:quiz_project/quiz_controller.dart';
import 'package:quiz_project/utils/Constants.dart';
import 'package:share_plus/share_plus.dart'; // Add this in pubspec.yaml
import 'package:url_launcher/url_launcher.dart';

import 'AdController.dart';
import 'QuizScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _initServices() async {
    await GetStorage.init();
    await dotenv.load(fileName: ".env");
    await MobileAds.instance.initialize();
    Get.put(AdController());
    Get.put(QuizController());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Your App',
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                fontFamily: 'Cairo',
                colorSchemeSeed: Colors.deepPurple,
              ),
              home: const HomePage(),
            );
          },
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _shareApp() {
    Share.share(
      "https://play.google.com/store/apps/details?id=com.manoooz.quiz1"
      "جرب هذا التطبيق الرائع! 🎉",
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoubleTapToExit(
      child: Scaffold(
        body: Stack(
          children: [
            // Background layer
            SizedBox.expand(child: Constants.backGroundMain()),

            // Gradient overlay for readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Main UI content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "أسئلة ثقافية",
                      style: mainStyleMW.copyWith(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30.h),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 32.h,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _menuButton(
                              icon: Icons.play_arrow,
                              label: Constants.Play,
                              onPressed: () async {
                                print("1. Resetting game...");
                                Get.find<QuizController>().resetGame();

                                print("2. Navigating to QuizScreen...");
                                Get.to(() => const QuizScreen());
                              },
                            ),
                            SizedBox(height: 20.h),
                            _menuButton(
                              icon: Icons.share,
                              label: Constants.SHAREGame,
                              onPressed: () => _shareApp(),
                            ),
                            SizedBox(height: 20.h),
                            _menuButton(
                              icon: Icons.apps,
                              label: Constants.OtherGames,
                              onPressed: () async => await _launchUrl(Uri.parse(
                                  "https://play.google.com/store/apps/dev?id=8389389659889758696")),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          textStyle: mainStyleMW.copyWith(fontSize: 18.sp),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 4,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
        ),
        icon: Icon(icon, size: 24.sp),
        label: Text(label),
        onPressed: onPressed,
      ),
    );
  }
}
