import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


const spaceV20 = SizedBox(height: 20);
const spaceV10 = SizedBox(height: 10);
const spaceH20 = SizedBox(width: 20);
const spaceH10 = SizedBox(width: 10);
const Color APPBAR_COLOR = Color(0xc7ec390a);
const Color TXT_COLOR = Color(0xdd210909);
const Color TXT_COLOR2 = Color(0xa1210909);

const TextStyle mainStyleTW = TextStyle(
  fontFamily: "DG Sahabah Bold",
  fontSize: 34,
  color: Colors.white,
);
const TextStyle mainStyleTB = TextStyle(fontFamily: "NotoSansArabic-Regular", fontSize: 40, color: Colors.black87);
const TextStyle mainStyleT1 = TextStyle(fontFamily: "NotoSansArabic-Regular", fontSize: 40, color: Colors.black87);
const TextStyle mainStyleT2 = TextStyle(fontFamily: "NotoSansArabic-Regular", fontSize: 34, color: TXT_COLOR);
const TextStyle mainStyleT4 = TextStyle(fontFamily: "NotoSansArabic-Regular", fontSize: 20, color: TXT_COLOR);
const TextStyle mainStyleT3 = TextStyle(fontFamily: "NotoSansArabic-Regular", fontSize: 34, color: TXT_COLOR2);
const TextStyle mainStyleLB = TextStyle(fontFamily: "NotoSansArabic-Regular", fontSize: 14, color: Colors.black87);
const TextStyle mainStyleLW = TextStyle(fontFamily: "NotoSansArabic-Regular", fontSize: 14, color: Colors.white);
const TextStyle mainStyleMW = TextStyle(fontFamily: "NotoSansArabic-Regular", fontSize: 30, color: Colors.white);
const TextStyle mainStyleBG = TextStyle(fontFamily: "NotoSansArabic-Regular", fontSize: 12, color: TXT_COLOR);
const TextStyle mainStyleBB = TextStyle(fontFamily: "NotoSansArabic-Regular", fontSize: 14, color: Colors.white);

class Constants {
  /// Games Types
  static String FINGERBATTEL = 'فريقين';
  static String ResetGame = 'إعادة اللعبة';
  static String Play = 'إلعب';
  static String ADVANCE = 'مخصص';
  static String SPIN_GAME = 'روليت';
  static String RACE_GAME = 'سباق';

  /// Games Icons // todo
  static String PlAY_LOGO = 'assets/images/play.png';

  static TextStyle mainStyleText = const TextStyle(fontFamily: "DG Sahabah Bold");
  static ButtonStyle mainStyleButton = ElevatedButton.styleFrom(backgroundColor: Colors.green);
  static String LoadingMessage = "إنتظر من فضلك";

  static Color mainColor = const Color(0xff0c3622);

  static ThemeData darkTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.black87,
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.black38,
        disabledColor: Colors.grey,
      ),
      colorScheme: const ColorScheme.dark().copyWith(secondary: Colors.red));

  static ThemeData lightTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.white10,
      // appBarTheme: ,
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.green,
        disabledColor: Colors.grey,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.pink));

  static Future<void> landscapeMode() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    var hid = await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.bottom,
    ]);
  }

  static Future<void> portraitMode() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  static Future<void> hidKeyboard() async {
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
  }

}
