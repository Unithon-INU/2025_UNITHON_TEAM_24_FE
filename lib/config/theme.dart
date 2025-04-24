import 'package:flutter/material.dart';

final appTheme = ThemeData(
  primarySwatch: Colors.blue,
  primaryColor: Color(0xFF2196F3),
  hintColor: Color(0xFF90CAF9),
  cardColor: Colors.white,
  scaffoldBackgroundColor: Colors.white,

  // fontFamily: 'NotoSansKR', // <-- 삭제 또는 주석 처리

  // textTheme에서도 fontFamily 제거
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      // fontFamily: 'NotoSansKR', // 제거
      fontSize: 28.0,
      fontWeight: FontWeight.bold,
      color: Color(0xFF1976D2),
    ),
    headlineMedium: TextStyle(
      // fontFamily: 'NotoSansKR', // 제거
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: Color(0xFF1976D2),
    ),
    headlineSmall: TextStyle(
      // fontFamily: 'NotoSansKR', // 제거
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: Color(0xFF1976D2),
    ),
    titleLarge: TextStyle(
      // fontFamily: 'NotoSansKR', // 제거
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1976D2),
    ),
    titleMedium: TextStyle(
      // fontFamily: 'NotoSansKR', // 제거
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1976D2),
    ),
    bodyLarge: TextStyle(
      // fontFamily: 'NotoSansKR', // 제거
      fontSize: 16.0,
      color: Colors.black87,
    ),
    bodyMedium: TextStyle(
      // fontFamily: 'NotoSansKR', // 제거
      fontSize: 14.0,
      color: Colors.black87,
    ),
    bodySmall: TextStyle(
      // fontFamily: 'NotoSansKR', // 제거
      fontSize: 12.0,
      color: Colors.black54,
    ),
  ),

  // 나머지 테마 설정은 유지
  appBarTheme: AppBarTheme(
    color: Color(0xFF2196F3),
    elevation: 0,
    // titleTextStyle 등에서도 fontFamily 제거 고려
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      // textStyle 등에서도 fontFamily 제거 고려
      foregroundColor: Colors.white,
      backgroundColor: Color(0xFF2196F3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Color(0xFF2196F3), width: 2.0),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
  ),
  cardTheme: CardTheme(
    elevation: 2.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Color(0xFF64B5F6)),
);