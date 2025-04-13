import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_project/utils/Constants.dart';
import 'package:quiz_project/widgets/TransparentBorderedButton.dart';
import 'package:quiz_project/widgets/confirm_exit_pop_scope.dart';

import 'QuizScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ScreenUtilInit(
      designSize: Size(375, 812), // typical iPhone 11 design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          // or MaterialApp
          debugShowCheckedModeBanner: false,
          title: 'Your App',
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            fontFamily: 'Cairo',
            colorSchemeSeed: Colors.deepPurple,
          ),          home: HomePage(), // or your actual home screen
        );
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ConfirmExitPopScope(
      title: "تنبيه",
      message: "هل تريد الخروج من التطبيق",
      confirmText: "نعم",
      cancelText: "لا",
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
                            horizontal: 24.w, vertical: 32.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _menuButton(
                              icon: Icons.play_arrow,
                              label: Constants.Play,
                              onPressed: () => Get.to(() => QuizScreen()),
                            ),
                            SizedBox(height: 20.h),
                            _menuButton(
                              icon: Icons.refresh,
                              label: Constants.ResetGame,
                              onPressed: () => print("Reset Game pressed"),
                            ),
                            SizedBox(height: 20.h),
                            _menuButton(
                              icon: Icons.add_circle_outline,
                              label: "إضافة نقاط",
                              onPressed: () => print("Add points pressed"),
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
