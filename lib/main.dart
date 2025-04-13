import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:quiz_project/utils/Constants.dart';
import 'package:quiz_project/widgets/TransparentBorderedButton.dart';
import 'package:quiz_project/widgets/confirm_exit_pop_scope.dart';

import 'QuizScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(useMaterial3: true),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  Widget _Image() {
    return Lottie.asset("assets/images/b.json", fit: BoxFit.fitHeight);
    // return Lottie.network("https://assets6.lottiefiles.com/private_files/lf30_vcrqm9l2.json");
  }

  final String question = "أسئلة ثقافية";
  final List<String> answers = ["London", "Paris", "Berlin", "Madrid"];

  @override
  Widget build(BuildContext context) {
    var ScreenWidth = MediaQuery.of(context).size.width;

    return ConfirmExitPopScope(
      title: "S",
      message: "S",
      confirmText: "S",
      cancelText: "S",
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          // appBar: AppBar(title: Text("S")),
          body: Stack(
            children: [
              SizedBox.expand(child: _Image()),
        
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
