// lib/widgets/auth/social_login_buttons.dart
// (Null 단언 연산자 '!' 추가)
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:js/js.dart' as pjs;
import 'package:js/js_util.dart' as js_util;
import 'dart:html' as html; // 웹 전용 (iOS 빌드 시 오류 발생 가능)
import 'dart:ui_web' as ui_web; // 웹 전용 (iOS 빌드 시 오류 발생 가능)
import 'dart:async';

import '../../providers/auth_provider.dart';

// --- JS 타입 정의 (이전과 동일) ---
@pjs.JS('google.accounts.id') class GoogleAccountsId { /* ... */
  external static void initialize(InitializeOptions options);
  external static void renderButton(html.Element parent, RenderOptions options);
}
@pjs.JS() @pjs.anonymous class InitializeOptions { /* ... */
  external factory InitializeOptions({String client_id, required Function callback});
  external String get client_id;
  external Function get callback;
}
@pjs.JS() @pjs.anonymous class RenderOptions { /* ... */
  external factory RenderOptions({String type, String theme, String size});
  external String get type;
  external String get theme;
  external String get size;
 }
@pjs.JS() @pjs.anonymous class CredentialResponse { /* ... */
  external String get credential;
  external String get select_by;
 }


// --- 위젯 코드 ---
class SocialLoginButtons extends StatefulWidget {
  const SocialLoginButtons({ Key? key }) : super(key: key);

  @override
  State<SocialLoginButtons> createState() => _SocialLoginButtonsState();
}

class _SocialLoginButtonsState extends State<SocialLoginButtons> {
  final String _googleButtonElementId = 'google-signin-button-container';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      ui_web.platformViewRegistry.registerViewFactory(
        _googleButtonElementId,
        (int viewId) => html.DivElement()
          ..id = _googleButtonElementId
          ..style.height = '100%'
          ..style.width = '100%',
      );
    }
  }

  // JavaScript 콜백 함수 (웹 전용 - 이전과 동일)
  void _handleGoogleCredentialResponse(dynamic response) {
    try {
      final String idToken = js_util.getProperty(response, 'credential');
      print("Dart (Web): Received Google ID Token: $idToken");

      if (idToken.isNotEmpty) {
        if (mounted) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          authProvider.processGoogleToken(idToken)
            .then((_) {
              if (mounted && authProvider.isAuthenticated) {
                print("Dart (Web): Google token processed, navigating to /home");
                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
              }
            })
            .catchError((error) {
              print("Dart (Web) Error: Failed to process Google token: $error");
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Google 로그인 처리 실패: $error')),
                );
              }
            });
        }
    } else {
      print("Dart (Web) Error: Received empty credential from Google.");
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google 로그인 실패: 빈 응답')),
        );
      }
    }
  } catch (e) {
     print("Dart (Web) Error: Failed to handle Google credential response: $e");
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google 로그인 응답 처리 오류: $e')),
        );
     }
  }
}

  // Google 버튼 렌더링 함수 (웹 전용, null 단언 연산자 추가)
  void _renderGoogleButton() async {
    if (!mounted) {
      print(">>> _renderGoogleButton called but widget is unmounted.");
      return;
    }
    print(">>> _renderGoogleButton function started (Web).");
    await Future.delayed(Duration(milliseconds: 150));

    if (!mounted) {
      print(">>> Widget unmounted during _renderGoogleButton delay.");
      return;
    }

    try {
      // 라이브러리 로드 확인
      final googleObject = js_util.getProperty(html.window, 'google');
      final accountsObject = (googleObject != null) ? js_util.getProperty(googleObject, 'accounts') : null;
      final googleIdObject = (accountsObject != null) ? js_util.getProperty(accountsObject, 'id') : null;

      if (googleIdObject == null) {
        throw Exception("Google Identity Services library (google.accounts.id) not loaded or not available.");
      }
      print(">>> Google Identity Services library loaded (Web).");

      // HTML 요소 검색
      html.Element? buttonContainer = html.document.getElementById(_googleButtonElementId);

      if (buttonContainer == null) {
         print("Warning: Google Sign-In button container '$_googleButtonElementId' not found initially. Retrying...");
         await Future.delayed(Duration(milliseconds: 300));
         if (!mounted) return;
         buttonContainer = html.document.getElementById(_googleButtonElementId); // 재시도 후 다시 할당
         if (buttonContainer == null) {
            throw Exception("Google Sign-In button container '$_googleButtonElementId' still not found after retry.");
         }
         print(">>> Found button container element after retry (Web).");
      } else {
          print(">>> Found button container element (Web).");
      }

      // --- 수정: Null 단언 연산자 '!' 추가 ---
      // 이 시점에는 buttonContainer가 null이 아님이 보장됨 (위 로직 통과 시)
      buttonContainer!.innerHtml = ''; // 이전 버튼 제거
      // --- 수정 끝 ---

      // Initialize 호출
      js_util.callMethod(googleIdObject, 'initialize', [
        InitializeOptions(
          client_id: "38433169297-p61djmgmeii0d6ihbui35bskcmc04prj.apps.googleusercontent.com", // **실제 웹 클라이언트 ID 확인**
          callback: js_util.allowInterop(_handleGoogleCredentialResponse),
        )
      ]);
      print(">>> Called google.accounts.id.initialize (Web)");

      // Render Button 호출
      js_util.callMethod(googleIdObject, 'renderButton', [
        // --- 수정: Null 단언 연산자 '!' 추가 ---
        buttonContainer, // 여기서도 buttonContainer는 null이 아님
        // --- 수정 끝 ---
        RenderOptions(
          type: 'standard', theme: 'outline', size: 'large',
        )
      ]);
      print(">>> Called google.accounts.id.renderButton (Web)");

    } catch (e) {
       print("Error rendering Google Sign-In button (Web): $e");
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Google 로그인 버튼 표시 오류: $e')),
         );
       }
    }
  }

  @override
  Widget build(BuildContext context) {
     return Column(
      children: [
        // Google 로그인 버튼 (웹/모바일 분기)
        if (kIsWeb)
          SizedBox(
            height: 50,
            width: 300,
            child: HtmlElementView(
              viewType: _googleButtonElementId,
              onPlatformViewCreated: (int viewId) {
                 if (mounted) {
                    print(">>> Platform view created (Web, viewId: $viewId). Calling _renderGoogleButton...");
                    _renderGoogleButton();
                 } else {
                    print(">>> Platform view created but widget is unmounted.");
                 }
              },
            ),
          )
        else
          // 모바일용 Google 로그인 버튼
          OutlinedButton.icon(
            onPressed: () {
               Provider.of<AuthProvider>(context, listen: false).loginWithGoogle();
            },
            icon: SvgPicture.asset(
              'assets/icons/google_logo.svg',
              width: 20, height: 20,
            ),
            label: Text('Google로 계속하기'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87, backgroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
        // 페이스북/애플 버튼 제거됨
      ],
    );
  }
}