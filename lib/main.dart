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
          theme: ThemeData(useMaterial3: true),
          home: HomePage(), // or your actual home screen
        );
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  final String question = "أسئلة ثقافية";
  final List<String> answers = ["London", "Paris", "Berlin", "Madrid"];

  @override
  Widget build(BuildContext context) {
    var ScreenWidth = MediaQuery.of(context).size.width;

    return ConfirmExitPopScope(
      title: "تنبيه",
      message: "هل تريد الخروج من التطبيق",
      confirmText: "نعم",
      cancelText: "لا",
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          // appBar: AppBar(title: Text("S")),
          body: Stack(
            children: [
              SizedBox.expand(child: Constants.backGroundMain()),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    spaceV20,

                    TransparentBorderedButton(
                      text: '$question',
                      width: ScreenWidth,
                      onPressed: () {
                        print('Button pressed!');
                      },
                      // Optional customizations:
                      borderRadius: 30.0,
                      // More rounded corners
                      borderWidth: 1.5,
                      // Thinner border
                      padding: const EdgeInsets.all(16),
                      textStyle: mainStyleMW,
                    ),

                    spaceV20,
                    spaceV20,
                    spaceV20,
                    spaceV20,
                    TransparentBorderedButton(
                      width: 222,

                      text: ' ${Constants.Play}',
                      onPressed: () {
                        print('Button pressed!');
                        Get.to(() => QuizScreen());
                      },
                      // Optional customizations:
                      borderRadius: 30.0,
                      // More rounded corners
                      borderWidth: 1.5,
                      // Thinner border
                      padding: const EdgeInsets.all(16),
                      textStyle: mainStyleMW,
                    ),
                    spaceV20,

                    TransparentBorderedButton(
                      width: 222,

                      text: ' ${Constants.ResetGame}',
                      onPressed: () {
                        print('Button pressed!');
                      },
                      // Optional customizations:
                      borderRadius: 30.0,
                      // More rounded corners
                      borderWidth: 1.5,
                      // Thinner border
                      padding: const EdgeInsets.all(16),
                      textStyle: mainStyleMW,
                    ),
                    spaceV20,

                    TransparentBorderedButton(
                      width: 222,

                      text: 'إضافة نقاط',
                      onPressed: () {
                        print('Button pressed!');
                      },
                      // Optional customizations:
                      borderRadius: 30.0,
                      // More rounded corners
                      borderWidth: 1.5,
                      // Thinner border
                      padding: const EdgeInsets.all(16),
                      textStyle: mainStyleMW,
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
