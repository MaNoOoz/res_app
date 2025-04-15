import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const spaceV20 = SizedBox(height: 20);
const spaceV10 = SizedBox(height: 10);
const spaceH20 = SizedBox(width: 20);
const spaceH10 = SizedBox(width: 10);


// const String font = "NotoSansArabic-Regular";
const String font = "IBMPlexSansArabic";
// Material color palette
const Color APPBAR_COLOR = Color(0xFF1E88E5); // Blue 600
const Color PRIMARY_COLOR = Color(0xFF42A5F5); // Blue 400
const Color SECONDARY_COLOR = Color(0xFF90CAF9); // Blue 200
const Color ACCENT_COLOR = Color(0xFF00E5FF); // Cyan A400
const Color DANGER_COLOR = Color(0xFFE53935); // Red 600
const Color SUCCESS_COLOR = Color(0xFF43A047); // Green 600
const Color WARNING_COLOR = Color(0xFFFFA000); // Amber 700
const Color TEXT_PRIMARY = Color(0xFF212121); // Dark text
const Color TEXT_SECONDARY = Color(0xFF757575); // Secondary text
const Color WHITE = Colors.white;
const Color BACKGROUND_GRADIENT_TOP = Color(0xFFe3f2fd);
const Color BACKGROUND_GRADIENT_BOTTOM = Color(0xFFbbdefb);

// Titles / Headings
final TextStyle mainStyleTB = TextStyle(
  fontFamily: font,
  fontSize: 28.sp,
  fontWeight: FontWeight.bold,
  color: WHITE,
);

final TextStyle mainStyleT1 = TextStyle(
  fontFamily: font,
  fontSize: 24.sp,
  fontWeight: FontWeight.w600,
  color: TEXT_PRIMARY,
);

final TextStyle mainStyleT2 = TextStyle(
  fontFamily: font,
  fontSize: 22.sp,
  fontWeight: FontWeight.w600,
  color: PRIMARY_COLOR,
);

final TextStyle mainStyleT3 = TextStyle(
  fontFamily: font,
  fontSize: 20.sp,
  fontWeight: FontWeight.w500,
  color: SECONDARY_COLOR,
);

final TextStyle mainStyleT4 = TextStyle(
  fontFamily: font,
  fontSize: 18.sp,
  fontWeight: FontWeight.w500,
  color: PRIMARY_COLOR,
);

// Body / Labels
final TextStyle mainStyleLW = TextStyle(
  fontFamily: font,
  fontSize: 13.sp,
  color: WHITE,
);

final TextStyle mainStyleMW = TextStyle(
  fontFamily: font,
  fontSize: 18.sp,
  fontWeight: FontWeight.w500,
  color: WHITE,
);

final TextStyle mainStyleLB = TextStyle(
  fontFamily: font,
  fontSize: 13.sp,
  color: TEXT_PRIMARY,
);

final TextStyle mainStyleBG = TextStyle(
  fontFamily: font,
  fontSize: 12.sp,
  color: TEXT_SECONDARY,
);

final TextStyle mainStyleBB = TextStyle(
  fontFamily: font,
  fontSize: 14.sp,
  fontWeight: FontWeight.w600,
  color: WHITE,
);

